import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../domain/entities/chat_conversation.dart';
import '../cubit/conversations_cubit.dart';
import '../cubit/conversations_state.dart';

/// The "الاستشارات / الاستفسارات" list, identical for patient and pharmacy:
/// a title, a search box, and one row per conversation (avatar box and name
/// on the right, unread count on the left). Needs a [ConversationsCubit] above it.
class ConversationsView extends StatefulWidget {
  final String title;
  final String description;
  final String emptyText;

  /// Extra widgets shown at the left of the title row (e.g. a menu button).
  final List<Widget> actions;

  const ConversationsView({
    super.key,
    required this.title,
    required this.description,
    required this.emptyText,
    this.actions = const [],
  });

  @override
  State<ConversationsView> createState() => _ConversationsViewState();
}

class _ConversationsViewState extends State<ConversationsView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.authScreenTitle,
                  ),
                ),
                ...widget.actions,
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              widget.description,
              textAlign: TextAlign.right,
              style: AppTextStyles.authScreenSubtitle,
            ),
            SizedBox(height: 24.h),
            AppTextField(
              controller: _searchController,
              hintText: 'البحث',
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.search, color: AppColors.mainTeal),
              onChanged: context.read<ConversationsCubit>().searchChanged,
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: BlocBuilder<ConversationsCubit, ConversationsState>(
                builder: (context, state) {
                  return switch (state) {
                    ConversationsLoading() => const Center(child: CircularProgressIndicator()),
                    ConversationsLoadFailure(:final message) => ProfileLoadError(
                        message: message,
                        onRetry: () => context.read<ConversationsCubit>().load(),
                      ),
                    ConversationsLoaded(:final visible) when visible.isEmpty => Center(
                        child: Text(
                          state.conversations.isEmpty
                              ? widget.emptyText
                              : 'لا توجد نتائج مطابقة لبحثك',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.sp, color: AppColors.grey, height: 1.6),
                        ),
                      ),
                    ConversationsLoaded(:final visible) => RefreshIndicator(
                        onRefresh: () => context.read<ConversationsCubit>().refresh(),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: visible.length,
                          separatorBuilder: (_, _) =>
                              Divider(height: 1, color: AppColors.cardBorder),
                          itemBuilder: (context, index) => _ConversationRow(
                            conversation: visible[index],
                            onReturn: () => context.read<ConversationsCubit>().refresh(),
                          ),
                        ),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onReturn;

  const _ConversationRow({required this.conversation, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.of(context).pushNamed(
          Routes.chatScreen,
          arguments: {
            'inquiryIds': conversation.inquiryIds,
            'title': conversation.title,
          },
        );
        onReturn();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          children: [
            // First child = right edge: avatar box, then the name.
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.permissionIconBg,
                border: Border.all(color: AppColors.iconBlueBorder),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.person_outline, color: AppColors.mainTeal, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16.sp, color: AppColors.textDark),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    conversation.lastText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            if (conversation.unreadCount > 0)
              Container(
                width: 26.w,
                height: 26.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.mainTeal, shape: BoxShape.circle),
                child: Text(
                  '${conversation.unreadCount}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.white),
                ),
              )
            else
              SizedBox(width: 26.w),
          ],
        ),
      ),
    );
  }
}
