import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/image_source_picker.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../domain/entities/chat_message.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';

/// Arguments to open a chat: the [inquiryIds] of a conversation (newest
/// first), or — patient only — the [pharmacyId] (and [medicineId] to be able
/// to start one).
class ChatArgs {
  final List<int> inquiryIds;
  final int? pharmacyId;
  final int? medicineId;
  final String title;
  final String? subtitle;

  const ChatArgs({
    this.inquiryIds = const [],
    this.pharmacyId,
    this.medicineId,
    required this.title,
    this.subtitle,
  });

  factory ChatArgs.fromMap(Map<String, dynamic> map) => ChatArgs(
        inquiryIds: [for (final id in (map['inquiryIds'] as List?) ?? const []) id as int],
        pharmacyId: map['pharmacyId'] as int?,
        medicineId: map['medicineId'] as int?,
        title: map['title'] as String,
        subtitle: map['subtitle'] as String?,
      );
}

/// The inquiry thread between a patient and a pharmacy — the same screen for
/// both sides. Mine on the right in the main colour ("أنت: 9:41 م" under it),
/// the other side on the left in the light one.
class ChatScreen extends StatelessWidget {
  final ChatArgs args;

  const ChatScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatCubit>(param1: args),
      child: _ChatView(args: args),
    );
  }
}

class _ChatView extends StatefulWidget {
  final ChatArgs args;

  const _ChatView({required this.args});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
    context.read<ChatCubit>().startPolling();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendText(BuildContext context) async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    final error = await context.read<ChatCubit>().send(text: text);
    if (!context.mounted) return;
    if (error != null) {
      AppSnackbar.show(context, error);
      return;
    }
    _controller.clear();
    _scrollToEnd();
  }

  Future<void> _sendImage(BuildContext context) async {
    final cubit = context.read<ChatCubit>();
    final file = await pickImageFromSourceSheet(context);
    if (file == null || !context.mounted) return;
    final error = await cubit.send(imagePath: file.path);
    if (!context.mounted) return;
    if (error != null) {
      AppSnackbar.show(context, error);
      return;
    }
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(title: widget.args.title, subtitle: widget.args.subtitle),
            Divider(height: 1, color: AppColors.cardBorder),
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listenWhen: (previous, current) =>
                    current is ChatLoaded &&
                    (previous is! ChatLoaded ||
                        previous.messages.length != current.messages.length),
                listener: (context, state) => _scrollToEnd(),
                builder: (context, state) {
                  return switch (state) {
                    ChatLoading() => const Center(child: CircularProgressIndicator()),
                    ChatLoadFailure(:final message) => ProfileLoadError(
                        message: message,
                        onRetry: () => context.read<ChatCubit>().load(),
                      ),
                    ChatLoaded(:final messages, :final canSend) when messages.isEmpty =>
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Center(
                          child: Text(
                            canSend
                                ? 'اكتب رسالتك للبدء بالمحادثة.'
                                : 'لا توجد رسائل مع ${widget.args.title} بعد.\n'
                                    'افتح صفحة دواء واضغط «اسأل الصيدلية» لبدء المراسلة.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14.sp, color: AppColors.grey, height: 1.6),
                          ),
                        ),
                      ),
                    ChatLoaded(:final messages) => _MessagesList(
                        messages: messages,
                        controller: _scrollController,
                      ),
                  };
                },
              ),
            ),
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is! ChatLoaded || !state.canSend) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
                  child: Row(
                    children: [
                      // First = right edge: the 336x56 message box with the
                      // send arrow inside it, then the "+" (image) button.
                      SizedBox(
                        width: 336.w,
                        height: 56.h,
                        child: AppTextField(
                          controller: _controller,
                          hintText: 'اكتب رسالة',
                          maxLines: 1,
                          fillColor: Colors.white,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendText(context),
                          icon: _SendIcon(
                            isLoading: state.isSending,
                            onTap: () => _sendText(context),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _AttachButton(onTap: state.isSending ? null : () => _sendImage(context)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _Header({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBackButton(onTap: () => Navigator.of(context).maybePop()),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16.sp, color: AppColors.textDark),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              subtitle!,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController controller;

  const _MessagesList({required this.messages, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final previous = index == 0 ? null : messages[index - 1];
        final newDay = previous == null || !_sameDay(previous.createdAt, message.createdAt);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (newDay) _DayChip(date: message.createdAt),
            _Bubble(message: message),
          ],
        );
      },
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayChip extends StatelessWidget {
  final DateTime date;

  const _DayChip({required this.date});

  String get _label {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(_label, style: TextStyle(fontSize: 12.sp, color: AppColors.textDark)),
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${time.hour < 12 ? 'ص' : 'م'}';
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;

  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    final textColor = mine ? Colors.white : AppColors.textDark;
    final time = _formatTime(message.createdAt);
    final imageOnly = message.imageUrl != null &&
        (message.text.isEmpty || message.text.trim() == message.imageUrl);

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        // Start = right edge under RTL: mine on the right, theirs on the left.
        crossAxisAlignment: mine ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 280.w),
            child: Container(
              // A picture on its own has no bubble: just the image.
              padding: imageOnly
                  ? EdgeInsets.zero
                  : EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: imageOnly
                  ? null
                  : BoxDecoration(
                      color: mine ? AppColors.mainTeal : AppColors.permissionIconBg,
                      border: mine ? null : Border.all(color: AppColors.iconBlueBorder),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (message.imageUrl != null)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: (message.text.isEmpty || message.imageUrl == message.text.trim())
                            ? 0
                            : 8.h,
                      ),
                      child: GestureDetector(
                        onTap: () => _openImage(context, message.imageUrl!),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: Image.network(
                            message.imageUrl!,
                            fit: BoxFit.cover,
                            width: imageOnly ? 240.w : null,
                            loadingBuilder: (context, child, progress) => progress == null
                                ? child
                                : SizedBox(
                                    height: 160.h,
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                            errorBuilder: (context, error, stackTrace) => Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: textColor,
                                size: 32.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (message.text.isNotEmpty && message.imageUrl != message.text.trim())
                    Text(
                      message.text,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 14.sp, color: textColor, height: 1.4),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            mine ? 'أنت: $time' : time,
            style: TextStyle(fontSize: 11.sp, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

/// Full-screen, pinch-to-zoom view of a picture from the chat.
void _openImage(BuildContext context, String url) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator(color: Colors.white)),
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image_outlined, color: Colors.white, size: 48),
            ),
          ),
        ),
      ),
    ),
  );
}

class _SendIcon extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _SendIcon({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isLoading ? null : onTap,
      icon: isLoading
          ? SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          // Icons.send mirrors itself under RTL, so the arrow points left.
          : Icon(Icons.send, color: AppColors.mainTeal, size: 22.sp),
    );
  }
}

class _AttachButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AttachButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.permissionIconBg,
          border: Border.all(color: AppColors.iconBlueBorder),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(Icons.add, color: AppColors.mainTeal, size: 24.sp),
      ),
    );
  }
}
