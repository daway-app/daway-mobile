import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/chat_activity.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/inquiry_thread_resolver.dart';
import '../../domain/usecases/chat_usecases.dart';
import 'chat_state.dart';

/// One conversation, for patient and pharmacy alike. A conversation can span
/// several inquiries (the backend keeps one per medicine), so the thread is
/// the messages of all of them merged by time; new messages go to one target
/// inquiry.
///
/// Opened with either [inquiryIds] (from a conversations list, newest first),
/// or — patient only — a [pharmacyId] (+ optional [medicineId]) whose
/// inquiries are looked up. With a [medicineId] the target is that
/// medicine's inquiry, started by the first message if there is none.
class ChatCubit extends Cubit<ChatState> {
  static const pollInterval = Duration(seconds: 5);

  List<int> _inquiryIds;
  int? _targetId;
  final int? pharmacyId;
  final int? medicineId;
  final GetChatMessagesUseCase _getMessagesUseCase;
  final SendChatMessageUseCase _sendMessageUseCase;
  final UploadChatImageUseCase _uploadImageUseCase;
  final InquiryThreadResolver? _resolver;
  final ChatActivity? _activity;

  Timer? _poll;

  ChatCubit({
    List<int> inquiryIds = const [],
    this.pharmacyId,
    this.medicineId,
    required GetChatMessagesUseCase getMessagesUseCase,
    required SendChatMessageUseCase sendMessageUseCase,
    required UploadChatImageUseCase uploadImageUseCase,
    InquiryThreadResolver? resolver,
    ChatActivity? activity,
  })  : _inquiryIds = List.of(inquiryIds),
        _targetId = inquiryIds.isEmpty ? null : inquiryIds.first,
        _getMessagesUseCase = getMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _uploadImageUseCase = uploadImageUseCase,
        _resolver = resolver,
        _activity = activity,
        super(const ChatLoading()) {
    load();
  }

  /// A patient can start a conversation with a pharmacy by sending its
  /// first message, with or without a medicine.
  bool get _canStartThread => pharmacyId != null && _resolver != null;

  Future<void> load() async {
    emit(const ChatLoading());

    if (_inquiryIds.isEmpty && pharmacyId != null && _resolver != null) {
      final found = await _resolver.findInquiries(pharmacyId: pharmacyId!);
      if (isClosed) return;
      switch (found) {
        case Success(:final data):
          _inquiryIds = [for (final ref in data) ref.id];
          final forMedicine = data.where((ref) => ref.medicineId == medicineId);
          _targetId = medicineId != null
              ? (forMedicine.isEmpty ? null : forMedicine.first.id)
              : (data.isEmpty ? null : data.first.id);
        case ApiError(:final failure):
          emit(ChatLoadFailure(failure.message));
          return;
      }
    }

    if (_inquiryIds.isEmpty && _targetId == null) {
      emit(ChatLoaded(const [], canSend: _canStartThread));
      return;
    }

    final result = await _fetchAll();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(ChatLoaded(data, canSend: _targetId != null || _canStartThread));
      case ApiError(:final failure):
        emit(ChatLoadFailure(failure.message));
    }
  }

  /// The messages of every inquiry of the conversation, merged oldest first.
  Future<ApiResult<List<ChatMessage>>> _fetchAll() async {
    final ids = {..._inquiryIds, ?_targetId}.toList();
    final results = await Future.wait([for (final id in ids) _getMessagesUseCase(id)]);

    final merged = <ChatMessage>[];
    for (final result in results) {
      switch (result) {
        case Success(:final data):
          merged.addAll(data);
        case ApiError():
          return result;
      }
    }
    merged.sort((a, b) {
      final byTime = a.createdAt.compareTo(b.createdAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
    return Success(merged);
  }

  /// Refreshes the thread every [pollInterval] while the screen is open (the
  /// backend has no socket; new messages are picked up by polling).
  void startPolling() {
    _poll ??= Timer.periodic(pollInterval, (_) => refresh());
  }

  void stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  /// Silent reload: keeps the list on screen and only swaps it if the thread
  /// changed. Errors are ignored — the next tick retries.
  Future<void> refresh() async {
    final current = state;
    if (current is! ChatLoaded || current.isSending) return;
    if (_inquiryIds.isEmpty && _targetId == null) return;

    final result = await _fetchAll();
    if (isClosed) return;
    final latest = state;
    if (latest is! ChatLoaded || latest.isSending) return;
    if (result case Success(:final data)) {
      final changed = data.length != latest.messages.length ||
          (data.isNotEmpty && data.last.id != latest.messages.last.id);
      if (changed) emit(latest.copyWith(messages: data));
    }
  }

  /// Sends [text], or the image at [imagePath]: a picture is uploaded first
  /// and its link is what gets sent. Returns null on success, or a
  /// user-facing error message.
  Future<String?> send({String? text, String? imagePath}) async {
    final current = state;
    if (current is! ChatLoaded || current.isSending || !current.canSend) return null;
    var trimmed = text?.trim();
    if ((trimmed == null || trimmed.isEmpty) && imagePath == null) return null;

    emit(current.copyWith(isSending: true));

    if (imagePath != null) {
      // A picture can't open a thread (its link would become the inquiry's
      // question); it needs one to exist.
      if (_targetId == null) {
        emit(current.copyWith(isSending: false));
        return 'ابدأ المحادثة بكتابة رسالة أولاً';
      }
      final uploaded = await _uploadImageUseCase(imagePath);
      if (isClosed) return null;
      switch (uploaded) {
        case Success(:final data):
          trimmed = data;
        case ApiError(:final failure):
          emit(current.copyWith(isSending: false));
          return failure.message;
      }
    }

    final targetId = _targetId;
    if (targetId == null) {
      // No inquiry for this medicine yet: the first message must be text (it
      // becomes the inquiry's opening question).
      if (trimmed == null || trimmed.isEmpty || !_canStartThread) {
        emit(current.copyWith(isSending: false));
        return 'ابدأ المحادثة بكتابة رسالة أولاً';
      }
      final started = await _resolver!.startInquiry(
        pharmacyId: pharmacyId!,
        medicineId: medicineId,
        message: trimmed,
      );
      if (isClosed) return null;
      switch (started) {
        case Success(:final data):
          _targetId = data;
          _inquiryIds = [data, ..._inquiryIds];
          _activity?.notifyChanged();
          await load();
          // The question that opened the inquiry may be stored on the
          // inquiry itself rather than as a chat message; if the thread
          // comes back empty, show the question just sent so it doesn't
          // look like it vanished.
          final loaded = state;
          if (loaded is ChatLoaded && loaded.messages.isEmpty) {
            emit(
              loaded.copyWith(
                messages: [
                  ChatMessage(
                    id: -data,
                    senderUserId: 0,
                    text: trimmed,
                    isRead: false,
                    createdAt: DateTime.now(),
                    isMine: true,
                  ),
                ],
              ),
            );
          }
          return null;
        case ApiError(:final failure):
          emit(current.copyWith(isSending: false));
          return failure.message;
      }
    }

    final result = await _sendMessageUseCase(targetId, trimmed!);
    if (isClosed) return null;
    final latest = state;
    if (latest is! ChatLoaded) return null;

    switch (result) {
      case Success(:final data):
        emit(latest.copyWith(messages: _withMessage(latest.messages, data), isSending: false));
        _activity?.notifyChanged();
        return null;
      case ApiError(:final failure):
        emit(latest.copyWith(isSending: false));
        return failure.message;
    }
  }

  List<ChatMessage> _withMessage(List<ChatMessage> messages, ChatMessage message) {
    if (messages.any((m) => m.id == message.id)) return messages;
    return [...messages, message];
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}
