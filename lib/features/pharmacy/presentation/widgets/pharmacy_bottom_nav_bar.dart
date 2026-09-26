import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import 'pharmacy_dashboard_tab_scope.dart';

/// The 5-item bottom navigation bar of [PharmacyDashboardShellScreen]: an icon
/// and a label per tab, and a bar above the selected one. Built as a plain
/// widget (like the patient's) rather than [BottomNavigationBar] since its
/// icons keep their own sizes and the selected home icon keeps its own two
/// colours.
///
/// [PharmacyDashboardTab.inventory] and [PharmacyDashboardTab.products] have
/// no item of their own, so while one is showing, the item it belongs to is the
/// one marked: المنتجات for the inventory (reached from the side menu), and
/// الرئيسية for the products page (opened from its card).
class PharmacyBottomNavBar extends StatelessWidget {
  final PharmacyDashboardTab selectedTab;
  final ValueChanged<PharmacyDashboardTab> onTabSelected;

  const PharmacyBottomNavBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  static const _items = [
    _NavEntry(PharmacyDashboardTab.home, 'الرئيسية', 'assets/icons/home_fill_icon.svg', 24,
        keepsColorsWhenSelected: true),
    _NavEntry(PharmacyDashboardTab.medicines, 'المنتجات', 'assets/icons/Search_icon.svg', 24),
    _NavEntry(PharmacyDashboardTab.orders, 'الطلبات', 'assets/icons/Search_icon.svg', 24),
    _NavEntry(PharmacyDashboardTab.inquiries, 'المراسلات', 'assets/icons/massage_icon.svg', 24),
    _NavEntry(PharmacyDashboardTab.profile, 'الملف الشخصي', 'assets/icons/user_icon.svg', 20),
  ];

  /// The item marked while [selectedTab] shows.
  PharmacyDashboardTab get _markedTab => switch (selectedTab) {
        PharmacyDashboardTab.inventory => PharmacyDashboardTab.medicines,
        PharmacyDashboardTab.products => PharmacyDashboardTab.home,
        _ => selectedTab,
      };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 12.h),
          child: Row(
            children: [
              for (final item in _items)
                Expanded(
                  child: _NavItem(
                    entry: item,
                    selected: item.tab == _markedTab,
                    onTap: () => onTabSelected(item.tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavEntry {
  final PharmacyDashboardTab tab;
  final String label;
  final String iconAsset;
  final double iconSize;

  /// The home icon is a filled house with a light bar in it: tinting it a
  /// single colour would lose the bar, so while selected it is drawn as is.
  final bool keepsColorsWhenSelected;

  const _NavEntry(
    this.tab,
    this.label,
    this.iconAsset,
    this.iconSize, {
    this.keepsColorsWhenSelected = false,
  });
}

class _NavItem extends StatelessWidget {
  final _NavEntry entry;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.entry, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? AppColors.mainTeal : AppColors.authInputBorder;
    final tint = selected && entry.keepsColorsWhenSelected
        ? null
        : ColorFilter.mode(iconColor, BlendMode.srcIn);

    // One node per item — a button that says whether it is the selected one —
    // as the Material bar this replaced gave; the pieces drawn below (the bar,
    // the icon, the text) carry no meaning of their own.
    return Semantics(
      button: true,
      selected: selected,
      label: entry.label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed-width bar, not stretched to the item's flexible width.
            Container(
              width: 40.w,
              height: 2,
              decoration: BoxDecoration(
                color: selected ? AppColors.mainTeal : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            // Every icon sits centered in the same 24px slot, each at its own
            // size (the profile icon is 20).
            SizedBox(
              height: 24.h,
              child: Center(
                child: SvgPicture.asset(
                  entry.iconAsset,
                  width: entry.iconSize.w,
                  height: entry.iconSize.w,
                  colorFilter: tint,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              entry.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.pharmacyNavLabel.copyWith(
                color: selected ? AppColors.onboardingText : AppColors.authInputBorder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
