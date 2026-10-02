import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/star_rating.dart';
import '../cubit/rate_experience_cubit.dart';
import '../cubit/rate_experience_state.dart';
import '../widgets/patient_sub_screen_header.dart';

/// "قيم تجربتك معنا" — no exact spacing/typography was handed over for this
/// one (just the design screenshots), so it follows this app's existing
/// card/spacing conventions rather than measured values.
class RateExperienceScreen extends StatelessWidget {
  final int pharmacyId;
  final String pharmacyName;

  const RateExperienceScreen({
    super.key,
    required this.pharmacyId,
    required this.pharmacyName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RateExperienceCubit>(param1: pharmacyId),
      child: _RateExperienceView(pharmacyName: pharmacyName),
    );
  }
}

class _RateExperienceView extends StatefulWidget {
  final String pharmacyName;

  const _RateExperienceView({required this.pharmacyName});

  @override
  State<_RateExperienceView> createState() => _RateExperienceViewState();
}

class _RateExperienceViewState extends State<_RateExperienceView> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<RateExperienceCubit, RateExperienceState>(
          listenWhen: (previous, current) =>
              (current.submitted && !previous.submitted) ||
              (current.errorMessage != null && current.errorMessage != previous.errorMessage),
          listener: (context, state) {
            if (state.submitted) {
              AppSnackbar.show(context, 'شكراً لتقييمك');
              Navigator.of(context).maybePop();
            } else if (state.errorMessage != null) {
              AppSnackbar.show(context, state.errorMessage!);
            }
          },
          builder: (context, state) {
            final cubit = context.read<RateExperienceCubit>();
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PatientSubScreenHeader(
                    title: 'قيم تجربتك معنا',
                    description: 'شاركنا برأيك بالتطبيق وصيدلية ${widget.pharmacyName}',
                  ),
                  SizedBox(height: 24.h),
                  _RatingCard(
                    title: 'تقييم التطبيق',
                    subtitle: 'كيف كانت تجربتك مع التطبيق؟',
                    rating: state.appRating,
                    onChanged: cubit.appRatingChanged,
                  ),
                  SizedBox(height: 16.h),
                  _RatingCard(
                    title: 'تقييم الصيدلية',
                    subtitle: 'كيف كانت تجربتك مع الصيدلية؟',
                    rating: state.pharmacyRating,
                    onChanged: cubit.pharmacyRatingChanged,
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: AppTextField(
                      controller: _notesController,
                      onChanged: cubit.notesChanged,
                      hintText: 'ملاحظات اضافية',
                      maxLines: 4,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  AppCustomButton(
                    text: 'إرسال التقييم',
                    isLoading: state.isSubmitting,
                    onPressed: cubit.submit,
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 1★–2★ read as a bad experience, 3★ middling, 4★–5★ good — only the 1★
/// "سيء" (red) case was in the design, so the rest of this scale/colour
/// mapping is inferred, not confirmed.
const _ratingLabels = {1: 'سيء', 2: 'ضعيف', 3: 'متوسط', 4: 'جيد', 5: 'ممتاز'};

Color _ratingColor(int stars) {
  if (stars <= 2) return AppColors.error;
  if (stars == 3) return AppColors.warning;
  return AppColors.success;
}

class _RatingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int rating;
  final ValueChanged<int> onChanged;

  const _RatingCard({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, textAlign: TextAlign.right, style: AppTextStyles.addressCardTitle),
          SizedBox(height: 4.h),
          Text(subtitle, textAlign: TextAlign.right, style: AppTextStyles.cardDescription),
          SizedBox(height: 16.h),
          Center(
            child: StarRating(rating: rating.toDouble(), size: 32, onRatingChanged: onChanged),
          ),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              rating == 0 ? 'اضغط على نجمة لتقييم' : _ratingLabels[rating]!,
              style: rating == 0
                  ? AppTextStyles.mutedCaption
                  : TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: _ratingColor(rating),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
