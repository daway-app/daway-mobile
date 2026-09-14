import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import 'patient_dashboard_tab_scope.dart';

/// Custom 5-item bottom navigation bar for [PatientDashboardShellScreen] —
/// four labeled icon tabs plus a distinct, unlabeled "scan" action in the
/// middle, per the design. Built as a plain widget (rather than
/// [BottomNavigationBar]) since that center item's raised, unlabeled square
/// doesn't fit the standard item shape.
class PatientBottomNavBar extends StatelessWidget {
  final PatientDashboardTab selectedTab;
  final ValueChanged<PatientDashboardTab> onTabSelected;

  const PatientBottomNavBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

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
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _NavItem(
                  iconAsset: 'assets/icons/home_fill_icon.svg',
                  label: 'الرئيسية',
                  selected: selectedTab == PatientDashboardTab.home,
                  onTap: () => onTabSelected(PatientDashboardTab.home),
                ),
              ),
              Expanded(
                child: _NavItem(
                  iconAsset: 'assets/icons/Search_icon.svg',
                  label: 'البحث',
                  selected: selectedTab == PatientDashboardTab.search,
                  onTap: () => onTabSelected(PatientDashboardTab.search),
                ),
              ),
              _ScanNavItem(onTap: () => onTabSelected(PatientDashboardTab.scan)),
              Expanded(
                child: _NavItem(
                  iconAsset: 'assets/icons/massage_icon.svg',
                  label: 'المراسلات',
                  selected: selectedTab == PatientDashboardTab.messages,
                  onTap: () => onTabSelected(PatientDashboardTab.messages),
                ),
              ),
              Expanded(
                child: _NavItem(
                  iconAsset: 'assets/icons/user_icon.svg',
                  label: 'الملف الشخصي',
                  selected: selectedTab == PatientDashboardTab.profile,
                  onTap: () => onTabSelected(PatientDashboardTab.profile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String iconAsset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconAsset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.mainTeal : AppColors.grey;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed-width active-tab indicator, not stretched to the item's
          // full (flexible) column width.
          Container(
            width: 40.w,
            height: 2,
            color: selected ? AppColors.mainTeal : Colors.transparent,
          ),
          SizedBox(height: 6.h),
          SvgPicture.asset(
            iconAsset,
            width: 22.w,
            height: 22.w,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ScanNavItem extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanNavItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 56.w,
        height: 56.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C72A6), Color(0xFF104665)],
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: SvgPicture.asset(
          'assets/icons/scan_icon.svg',
          width: 24.w,
          height: 24.w,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}
