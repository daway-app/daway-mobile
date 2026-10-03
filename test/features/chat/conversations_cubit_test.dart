import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/chat/domain/chat_activity.dart';
import 'package:daway_app/features/chat/domain/entities/chat_conversation.dart';
import 'package:daway_app/features/chat/presentation/cubit/conversations_cubit.dart';
import 'package:daway_app/features/chat/presentation/cubit/conversations_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _Source implements ConversationsSource {
  int calls = 0;
  List<ChatConversation> result = const [];

  @override
  Future<ApiResult<List<ChatConversation>>> call() async {
    calls++;
    return Success(result);
  }
}

ChatConversation _conversation(String title) => ChatConversation(
      title: title,
      lastText: 'x',
      inquiryIds: const [1],
      lastActivity: DateTime(2026, 10, 3),
    );

void main() {
  test('reloads when a chat reports activity, keeping the search text', () async {
    final source = _Source();
    final activity = ChatActivity();
    final cubit = ConversationsCubit(source, activity: activity);
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);
    expect(source.calls, 1);

    cubit.searchChanged('الشفاء');
    source.result = [_conversation('صيدلية الشفاء')];
    activity.notifyChanged();
    await Future<void>.delayed(Duration.zero);

    expect(source.calls, 2);
    final state = cubit.state as ConversationsLoaded;
    expect(state.conversations, hasLength(1));
    expect(state.query, 'الشفاء');
  });

  test('search ignores hamza and ta marbuta spellings', () async {
    final source = _Source()..result = [_conversation('صيدلية الأمل'), _conversation('الشفاء')];
    final cubit = ConversationsCubit(source);
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    cubit.searchChanged('صيدليه الامل');

    expect((cubit.state as ConversationsLoaded).visible.map((c) => c.title), ['صيدلية الأمل']);
  });
}
