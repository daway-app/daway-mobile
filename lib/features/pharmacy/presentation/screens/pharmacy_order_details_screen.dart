import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/helpers/arabic_plural.dart';
import '../../../../core/helpers/price_formatter.dart';
import '../../../../core/helpers/smart_date_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/entities/pharmacy_order.dart';
import '../widgets/pharmacy_products_header.dart';
import '../widgets/product_status_badge.dart';

/// "تفاصيل الطلب": one order in full — its number, strip and time, each
/// medicine, where it goes, how it is paid — and the two decisions, "قبول
/// الطلب" and "رفض الطلب".
///
/// There is no orders API yet, so accepting and rejecting go to [onAccept] and
/// [onReject], and without them answer "قريباً".
class PharmacyOrderDetailsScreen extends StatelessWidget {
  final PharmacyOrder order;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const PharmacyOrderDetailsScreen({
    super.key,
    required this.order,
    this.onAccept,
    this.onReject,
  });

  /// Pushes the screen for [order] above the dashboard.
  static Future<void> open(BuildContext context, PharmacyOrder order) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PharmacyOrderDetailsScreen(order: order)),
    );
  }

  void _comingSoon(BuildContext context) => AppSnackbar.show(context, 'قريباً');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PharmacyProductsHeader(
                title: 'تفاصيل الطلب',
                subtitle: 'راجع تفاصيل طلب العميل',
                onBack: () => Navigator.of(context).pop(),
              ),
              SizedBox(height: 24.h),
              _SummaryCard(order: order),
              for (final item in order.items) ...[
                SizedBox(height: 16.h),
                _ItemCard(item: item),
              ],
              SizedBox(height: 16.h),
              _DeliveryCard(area: order.area, street: order.deliveryStreet),
              if (order.payment case final payment?) ...[
                SizedBox(height: 16.h),
                _PaymentCard(payment: payment),
              ],
              SizedBox(height: 16.h),
              AppCustomButton(
                text: 'قبول الطلب',
                onPressed: onAccept ?? () => _comingSoon(context),
              ),
              SizedBox(height: 16.h),
              AppCustomButton(
                text: 'رفض الطلب',
                backgroundColor: Colors.white,
                textColor: AppColors.authError,
                borderColor: AppColors.cardBorder,
                onPressed: onReject ?? () => _comingSoon(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A white bordered card, the shell every block of the screen sits in.
class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: child,
    );
  }
}

/// A card's heading: a tinted icon square and the title next to it.
class _CardTitle extends StatelessWidget {
  final String icon;
  final String title;
  final Widget? trailing;

  const _CardTitle({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28.r,
          height: 28.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.permissionIconBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: SvgPicture.asset(
            icon,
            width: 16.r,
            height: 16.r,
            colorFilter: const ColorFilter.mode(AppColors.mainTeal, BlendMode.srcIn),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(child: Text(title, style: AppTextStyles.pharmacyOrderNumber)),
        ?trailing,
      ],
    );
  }
}

/// The order's number, the strip of what is in it, and when it came in.
class _SummaryCard extends StatelessWidget {
  final PharmacyOrder order;

  const _SummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The number is Latin: set left-to-right on its own, so its "#"
          // stays in front of the letters.
          Text(
            '#${order.orderNumber}',
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.end,
            style: AppTextStyles.settingsMutedText,
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.permissionIconBg,
              border: Border.all(color: AppColors.iconBlueBorder),
              borderRadius: BorderRadius.circular(8.r),
            ),
            // RTL order (the first child is rightmost): items, price, area.
            child: Row(
              children: [
                _Cell(
                  glyph: '💊',
                  label: arabicCountedNoun(
                    order.itemsCount,
                    singular: 'دواء',
                    dual: 'دواءان',
                    plural: 'أدوية',
                    one: 'دواء واحد',
                  ),
                ),
                const _CellDivider(),
                _Cell(
                  glyph: '₪',
                  glyphColor: AppColors.mainTeal,
                  label: '${formatPrice(order.total)} ₪',
                  labelStyle: AppTextStyles.pharmacyOrderPrice,
                  labelDirection: TextDirection.ltr,
                ),
                const _CellDivider(),
                _Cell(glyph: '📍', label: order.area),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(smartDate(order.createdAt), style: AppTextStyles.pharmacyOrderTime),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String glyph;
  final Color? glyphColor;
  final String label;
  final TextStyle? labelStyle;
  final TextDirection? labelDirection;

  const _Cell({
    required this.glyph,
    this.glyphColor,
    required this.label,
    this.labelStyle,
    this.labelDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(glyph, style: TextStyle(fontSize: 12.sp, color: glyphColor)),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            textDirection: labelDirection,
            style: labelStyle ?? AppTextStyles.pharmacyOrderSummary,
          ),
        ],
      ),
    );
  }
}

class _CellDivider extends StatelessWidget {
  const _CellDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34.h, color: AppColors.iconBlueBorder);
  }
}

/// One medicine of the order: its picture, name and price, and whether the
/// pharmacy has it.
class _ItemCard extends StatelessWidget {
  final PharmacyOrderItem item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl;
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.permissionIconBg,
              border: Border.all(color: AppColors.iconBlueBorder),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: imageUrl == null || imageUrl.isEmpty
                ? null
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.pharmacyOrderNumber),
                SizedBox(height: 12.h),
                Text(
                  '${formatPrice(item.price)} ₪',
                  textDirection: TextDirection.ltr,
                  style: AppTextStyles.pharmacyOrderPrice.copyWith(fontSize: 14.sp),
                ),
              ],
            ),
          ),
          ProductStatusBadge(
            status: item.isAvailable ? MedicineStatus.available : MedicineStatus.outOfStock,
          ),
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final String area;
  final String? street;

  const _DeliveryCard({required this.area, required this.street});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardTitle(icon: 'assets/icons/map_pin_icon.svg', title: 'عنوان التوصيل'),
          SizedBox(height: 16.h),
          Text(area, style: AppTextStyles.settingsMutedText),
          if (street != null && street!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(street!, style: AppTextStyles.pharmacyOrderSummary.copyWith(fontSize: 14.sp)),
          ],
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PharmacyOrderPayment payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final (label, textColor, tint) = payment.isPaid
        ? ('مدفوع', AppColors.productAvailableText, AppColors.productAvailableTint)
        : ('غير مدفوع', AppColors.statLowStock, AppColors.productLowStockTint);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardTitle(
            icon: 'assets/icons/credit_card_icon.svg',
            title: 'طريقة الدفع',
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(4.r)),
              child: Text(
                label,
                style: AppTextStyles.pharmacyProductBadge.copyWith(color: textColor),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(payment.method, style: AppTextStyles.pharmacyOrderNumber),
          if (payment.detail case final detail?) ...[
            SizedBox(height: 8.h),
            Text(detail, style: AppTextStyles.settingsMutedText),
          ],
        ],
      ),
    );
  }
}
