import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_filter_chip.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../domain/entities/inquiry.dart';
import '../cubit/pharmacy_inquiries_cubit.dart';
import '../cubit/pharmacy_inquiries_state.dart';
import '../helpers/notifications_navigation.dart';
import '../widgets/inquiry_card.dart';
import '../widgets/pharmacy_side_menu.dart';

class PharmacyInquiriesScreen extends StatelessWidget {
  const PharmacyInquiriesScreen({super.key});

  Future<void> _updateStatus(
    BuildContext context,
    int inquiryId,
    InquiryStatus status,
  ) async {
    final error = await context.read<PharmacyInquiriesCubit>().updateStatus(
      inquiryId,
      status,
    );
    if (error != null && context.mounted) {
      AppSnackbar.show(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'استفسارات المرضى',
          style: AppTextStyles.screenTitle.copyWith(
            color: AppColors.mainTeal,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppColors.mainTeal),
            onPressed: () => openNotifications(context),
          ),
        ],
      ),
      drawer: const PharmacySideMenu(),
      body: SafeArea(
        child: BlocBuilder<PharmacyInquiriesCubit, PharmacyInquiriesState>(
          builder: (context, state) {
            return switch (state) {
              PharmacyInquiriesLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              PharmacyInquiriesLoadFailure(:final message) => ProfileLoadError(
                message: message,
                onRetry: () => context.read<PharmacyInquiriesCubit>().load(),
              ),
              PharmacyInquiriesLoaded() => _buildLoaded(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, PharmacyInquiriesLoaded state) {
    final filtered = state.filteredInquiries;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'إدارة استفسارات المرضى والرد عليها',
                style: AppTextStyles.cardDescription,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 16.h),
              StatCardRow(
                cards: [
                  StatCard(
                    icon: Icons.add_circle_outline,
                    color: AppColors.success,
                    value: '${state.newCount}',
                    label: 'جديدة',
                  ),
                  StatCard(
                    icon: Icons.chat_bubble_outline,
                    color: AppColors.primaryTeal,
                    value: '${state.answeredCount}',
                    label: 'تم الرد',
                  ),
                  StatCard(
                    icon: Icons.check_circle_outline,
                    color: AppColors.grey,
                    value: '${state.closedCount}',
                    label: 'مغلقة',
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    AppFilterChip(
                      label: 'الكل',
                      selected: state.filter == InquiryStatusFilter.all,
                      onTap: () => context
                          .read<PharmacyInquiriesCubit>()
                          .filterChanged(InquiryStatusFilter.all),
                    ),
                    SizedBox(width: 8.w),
                    AppFilterChip(
                      label: 'جديدة',
                      color: AppColors.success,
                      selected: state.filter == InquiryStatusFilter.newInquiry,
                      onTap: () => context
                          .read<PharmacyInquiriesCubit>()
                          .filterChanged(InquiryStatusFilter.newInquiry),
                    ),
                    SizedBox(width: 8.w),
                    AppFilterChip(
                      label: 'تم الرد',
                      color: AppColors.primaryTeal,
                      selected: state.filter == InquiryStatusFilter.answered,
                      onTap: () => context
                          .read<PharmacyInquiriesCubit>()
                          .filterChanged(InquiryStatusFilter.answered),
                    ),
                    SizedBox(width: 8.w),
                    AppFilterChip(
                      label: 'مغلقة',
                      color: AppColors.grey,
                      selected: state.filter == InquiryStatusFilter.closed,
                      onTap: () => context
                          .read<PharmacyInquiriesCubit>()
                          .filterChanged(InquiryStatusFilter.closed),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد استفسارات مطابقة',
                    style: AppTextStyles.cardDescription,
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final inquiry = filtered[index];
                    return InquiryCard(
                      inquiry: inquiry,
                      isUpdating: state.updatingIds.contains(inquiry.id),
                      onMarkAnswered: () => _updateStatus(
                        context,
                        inquiry.id,
                        InquiryStatus.answered,
                      ),
                      onClose: () => _updateStatus(
                        context,
                        inquiry.id,
                        InquiryStatus.closed,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
