import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/chat_conversation.dart';
import 'conversations_state.dart';

/// The inquiries list of either side: loads [ChatConversation]s from the
/// side's [ConversationsSource] and filters them by the search text.
class ConversationsCubit extends Cubit<ConversationsState> {
  final ConversationsSource _source;

  ConversationsCubit(this._source) : super(const ConversationsLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const ConversationsLoading());
    await refresh();
  }

  /// Reloads without dropping the list back to a spinner (pull-to-refresh,
  /// or returning from a chat).
  Future<void> refresh() async {
    final query = switch (state) {
      ConversationsLoaded(:final query) => query,
      _ => '',
    };
    final result = await _source();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(ConversationsLoaded(data, query: query));
      case ApiError(:final failure):
        emit(ConversationsLoadFailure(failure.message));
    }
  }

  void searchChanged(String query) {
    final current = state;
    if (current is! ConversationsLoaded) return;
    emit(ConversationsLoaded(current.conversations, query: query));
  }
}
