import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/chat/data/models/chat_message_model.dart';
import 'package:daway_app/features/chat/domain/entities/chat_message.dart';
import 'package:daway_app/features/chat/domain/repositories/chat_image_uploader.dart';
import 'package:daway_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:daway_app/features/chat/domain/repositories/inquiry_thread_resolver.dart';
import 'package:daway_app/features/chat/domain/usecases/chat_usecases.dart';
import 'package:daway_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:daway_app/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter_test/flutter_test.dart';

ChatMessage _msg(int id, int sender, {int minute = 0, String text = 'x'}) => ChatMessage(
      id: id,
      senderUserId: sender,
      text: text,
      isRead: false,
      createdAt: DateTime(2026, 9, 30, 10, minute),
    );

class _FakeChatRepository implements ChatRepository {
  ApiResult<List<ChatMessage>> messagesResult = const Success([]);
  ApiResult<ChatMessage>? sendResult;
  AccountType? lastAccountType;
  int? lastSentInquiryId;
  String? lastSentText;

  @override
  Future<ApiResult<List<ChatMessage>>> getMessages({
    required String token,
    required AccountType accountType,
    required int inquiryId,
    bool markRead = true,
  }) async {
    lastAccountType = accountType;
    return messagesResult;
  }

  @override
  Future<ApiResult<ChatMessage>> sendMessage({
    required String token,
    required AccountType accountType,
    required int inquiryId,
    required String text,
  }) async {
    lastSentInquiryId = inquiryId;
    lastSentText = text;
    return sendResult ?? Success(_msg(100, 1, text: text));
  }
}

class _FakeUploader implements ChatImageUploader {
  ApiResult<String> result = const Success('https://res.cloudinary.com/x/image/upload/a.png');
  String? lastPath;

  @override
  Future<ApiResult<String>> upload(String imagePath) async {
    lastPath = imagePath;
    return result;
  }
}

class _FakeSession implements SessionRepository {
  UserSession? session;

  _FakeSession({AccountType type = AccountType.patient, int? userId = 1})
      : session = UserSession(accountType: type, token: 'tok', userId: userId);

  @override
  Future<UserSession?> getSession() async => session;

  @override
  Future<void> saveSession(UserSession session) async {}

  @override
  Future<void> clearSession() async {}
}

class _FakeResolver implements InquiryThreadResolver {
  List<InquiryRef> refs = [];
  ApiResult<int> startResult = const Success(7);
  int startCalls = 0;
  String? startedMessage;

  @override
  Future<ApiResult<List<InquiryRef>>> findInquiries({required int pharmacyId}) async =>
      Success(refs);

  @override
  Future<ApiResult<int>> startInquiry({
    required int pharmacyId,
    int? medicineId,
    required String message,
  }) async {
    startCalls++;
    startedMessage = message;
    return startResult;
  }
}

void main() {
  late _FakeChatRepository repository;
  late _FakeResolver resolver;
  late _FakeUploader uploader;

  ChatCubit build({
    List<int> inquiryIds = const [],
    int? pharmacyId,
    int? medicineId,
    _FakeSession? session,
  }) {
    final s = session ?? _FakeSession();
    final cubit = ChatCubit(
      inquiryIds: inquiryIds,
      pharmacyId: pharmacyId,
      medicineId: medicineId,
      getMessagesUseCase: GetChatMessagesUseCase(repository, s),
      sendMessageUseCase: SendChatMessageUseCase(repository, s),
      uploadImageUseCase: UploadChatImageUseCase(uploader),
      resolver: resolver,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  setUp(() {
    repository = _FakeChatRepository();
    resolver = _FakeResolver();
    uploader = _FakeUploader();
  });

  group('who sent a message', () {
    test('mine is decided by the session user id', () async {
      repository.messagesResult = Success([_msg(1, 1), _msg(2, 9)]);
      final cubit = build(inquiryIds: [5]);
      await Future<void>.delayed(Duration.zero);

      final messages = (cubit.state as ChatLoaded).messages;
      expect(messages.map((m) => m.isMine), [true, false]);
    });

    test('without a stored user id the patient side treats the opening sender as itself',
        () async {
      repository.messagesResult = Success([_msg(1, 4), _msg(2, 9), _msg(3, 4)]);
      final cubit = build(inquiryIds: [5], session: _FakeSession(userId: null));
      await Future<void>.delayed(Duration.zero);

      expect((cubit.state as ChatLoaded).messages.map((m) => m.isMine), [true, false, true]);
    });

    test('...and the pharmacy side treats it as the other party', () async {
      repository.messagesResult = Success([_msg(1, 4), _msg(2, 9)]);
      final cubit = build(
        inquiryIds: [5],
        session: _FakeSession(type: AccountType.pharmacy, userId: null),
      );
      await Future<void>.delayed(Duration.zero);

      expect((cubit.state as ChatLoaded).messages.map((m) => m.isMine), [false, true]);
      expect(repository.lastAccountType, AccountType.pharmacy);
    });
  });

  test('a load failure surfaces its message', () async {
    repository.messagesResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = build(inquiryIds: [5]);
    await Future<void>.delayed(Duration.zero);

    expect((cubit.state as ChatLoadFailure).message, 'تعذر الاتصال بالخادم');
  });

  test('send appends the new message as mine and trims the text', () async {
    repository.messagesResult = Success([_msg(1, 9)]);
    final cubit = build(inquiryIds: [5]);
    await Future<void>.delayed(Duration.zero);

    final error = await cubit.send(text: '  مرحبا  ');

    expect(error, isNull);
    expect(repository.lastSentInquiryId, 5);
    expect(repository.lastSentText, 'مرحبا');
    final state = cubit.state as ChatLoaded;
    expect(state.messages, hasLength(2));
    expect(state.messages.last.isMine, isTrue);
    expect(state.isSending, isFalse);
  });

  test('an image is uploaded and its link is what gets sent', () async {
    final cubit = build(inquiryIds: [5]);
    await Future<void>.delayed(Duration.zero);

    final error = await cubit.send(imagePath: '/tmp/a.png');

    expect(error, isNull);
    expect(uploader.lastPath, '/tmp/a.png');
    expect(repository.lastSentText, 'https://res.cloudinary.com/x/image/upload/a.png');
    expect((cubit.state as ChatLoaded).messages.last.imageUrl, isNotNull);
  });

  test('a failed upload sends nothing and returns the message', () async {
    uploader.result = const ApiError(NetworkFailure('تعذر رفع الصورة'));
    final cubit = build(inquiryIds: [5]);
    await Future<void>.delayed(Duration.zero);

    final error = await cubit.send(imagePath: '/tmp/a.png');

    expect(error, 'تعذر رفع الصورة');
    expect(repository.lastSentText, isNull);
  });

  test('the server saying is_mine or the sender role wins over user ids', () async {
    repository.messagesResult = Success([
      ChatMessage(
        id: 1,
        senderUserId: 1,
        text: 'a',
        isRead: false,
        createdAt: DateTime(2026, 9, 30, 10),
        serverIsMine: false,
      ),
      ChatMessage(
        id: 2,
        senderUserId: 9,
        text: 'b',
        isRead: false,
        createdAt: DateTime(2026, 9, 30, 11),
        senderRole: 'patient',
      ),
    ]);
    final cubit = build(inquiryIds: [5]); // signed in as user 1, a patient
    await Future<void>.delayed(Duration.zero);

    expect((cubit.state as ChatLoaded).messages.map((m) => m.isMine), [false, true]);
  });

  test('a link to an uploaded picture is recognised, and previews as a picture', () {
    expect(isImageLink('https://res.cloudinary.com/x/image/upload/a.png'), isTrue);
    expect(isImageLink('https://example.com/pic.JPG'), isTrue);
    expect(isImageLink('هل الدواء متوفر https://example.com/pic.jpg'), isFalse);
    expect(isImageLink('https://example.com/page'), isFalse);
    expect(chatPreviewText('https://res.cloudinary.com/x/image/upload/a.png'), 'صورة');
    expect(chatPreviewText('مرحبا'), 'مرحبا');
  });

  test('a failed send returns the message and keeps the thread', () async {
    repository.sendResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    repository.messagesResult = Success([_msg(1, 9)]);
    final cubit = build(inquiryIds: [5]);
    await Future<void>.delayed(Duration.zero);

    final error = await cubit.send(text: 'مرحبا');

    expect(error, 'تعذر الاتصال بالخادم');
    expect((cubit.state as ChatLoaded).messages, hasLength(1));
  });

  test('a patient opening a pharmacy resolves to the latest inquiry with it', () async {
    resolver.refs = const [InquiryRef(id: 12, medicineId: 6)];
    repository.messagesResult = Success([_msg(1, 1)]);
    final cubit = build(pharmacyId: 3);
    await Future<void>.delayed(Duration.zero);

    expect((cubit.state as ChatLoaded).messages, hasLength(1));
  });

  test('a conversation of several inquiries merges their messages by time', () async {
    // The fake returns the same list for every inquiry id; two ids => duplicates by id
    // are expected to be merged in time order, so use distinct per-id data instead.
    repository.messagesResult = Success([_msg(1, 9, minute: 5), _msg(2, 1, minute: 1)]);
    final cubit = build(inquiryIds: [8, 5]);
    await Future<void>.delayed(Duration.zero);

    final messages = (cubit.state as ChatLoaded).messages;
    expect(messages.map((m) => m.id), containsAllInOrder([2, 1]));
  });

  test('sending in a merged conversation goes to its newest inquiry', () async {
    final cubit = build(inquiryIds: [8, 5]);
    await Future<void>.delayed(Duration.zero);

    await cubit.send(text: 'مرحبا');

    expect(repository.lastSentInquiryId, 8);
  });

  test('with a medicine, the target is that medicine inquiry among the pharmacy inquiries',
      () async {
    resolver.refs = const [
      InquiryRef(id: 12, medicineId: 6),
      InquiryRef(id: 9, medicineId: 7),
    ];
    final cubit = build(pharmacyId: 3, medicineId: 7);
    await Future<void>.delayed(Duration.zero);

    await cubit.send(text: 'مرحبا');

    expect(repository.lastSentInquiryId, 9);
    expect(resolver.startCalls, 0);
  });

  test('with no inquiry and no medicine a patient can still start a conversation', () async {
    final cubit = build(pharmacyId: 3);
    await Future<void>.delayed(Duration.zero);
    expect((cubit.state as ChatLoaded).canSend, isTrue);

    final error = await cubit.send(text: 'مرحبا');

    expect(error, isNull);
    expect(resolver.startCalls, 1);
    expect(resolver.startedMessage, 'مرحبا');
  });

  test('without a pharmacy to write to the composer is disabled', () async {
    final cubit = build();
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as ChatLoaded;
    expect(state.canSend, isFalse);
    expect(state.messages, isEmpty);
  });

  test('with a medicine but no inquiry, the first text starts one', () async {
    final cubit = build(pharmacyId: 3, medicineId: 6);
    await Future<void>.delayed(Duration.zero);
    expect((cubit.state as ChatLoaded).canSend, isTrue);

    final error = await cubit.send(text: 'هل متوفر؟');

    expect(error, isNull);
    expect(resolver.startCalls, 1);
    expect(resolver.startedMessage, 'هل متوفر؟');
  });

  test('an image cannot be the first message of a new thread', () async {
    final cubit = build(pharmacyId: 3, medicineId: 6);
    await Future<void>.delayed(Duration.zero);

    final error = await cubit.send(imagePath: '/tmp/a.png');

    expect(error, isNotNull);
    expect(resolver.startCalls, 0);
  });

  test('the model resolves a relative media path against the server host', () {
    final model = ChatMessageModel.fromJson(
      {
        'id': 3,
        'sender_user_id': 5,
        'message': null,
        'media_url': '/storage/patient_inquiry_media/x.png',
        'is_read': 0,
        'created_at': '2026-09-30 14:00:00',
      },
      baseHost: 'https://example.com',
    );

    expect(model.mediaUrl, 'https://example.com/storage/patient_inquiry_media/x.png');
    expect(model.text, '');
    expect(model.isRead, isFalse);
  });

  test('an absolute media URL on another host or plain http is rebuilt on the API host', () {
    final model = ChatMessageModel.fromJson(
      {
        'id': 3,
        'sender_user_id': 5,
        'media_url': 'http://localhost/storage/patient_inquiry_media/x.png',
        'created_at': '2026-09-30 14:00:00',
      },
      baseHost: 'https://example.com',
    );

    expect(model.mediaUrl, 'https://example.com/storage/patient_inquiry_media/x.png');
  });
}
