import 'dart:async';

/// "Something changed in the chats" - fired when this user sends a message or
/// starts a conversation, so every conversations list (kept alive in its tab)
/// reloads instead of showing the list it loaded at app start.
class ChatActivity {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get changes => _controller.stream;

  void notifyChanged() {
    if (!_controller.isClosed) _controller.add(null);
  }
}
