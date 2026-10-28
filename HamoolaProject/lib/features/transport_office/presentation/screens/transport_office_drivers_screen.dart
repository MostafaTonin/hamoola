import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../merchant/domain/models/transport_order_draft.dart';
import '../../../merchant/presentation/screens/driver_profile_screen.dart';
import '../../domain/models/transport_office_drivers_store.dart';
import 'transport_office_endorse_search_screen.dart';

/// Screen 1: «السائقون»
/// Displays only drivers who currently have an active endorsement from the current office.
/// Exact visual fidelity matching the reference mockup (Image 1, Image 5, Image 6, Image 7).
class TransportOfficeDriversScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onAddEndorsement;

  const TransportOfficeDriversScreen({
    super.key,
    this.onBack,
    this.onAddEndorsement,
  });

  @override
  State<TransportOfficeDriversScreen> createState() => _TransportOfficeDriversScreenState();
}

class _TransportOfficeDriversScreenState extends State<TransportOfficeDriversScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final TransportOfficeDriversStore _store = TransportOfficeDriversStore.instance;

  bool _isFabSheetOpen = false;
  late final AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreUpdated);
    _searchController.addListener(_onSearchChanged);

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreUpdated);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  List<EndorsedDriver> get _displayedDrivers {
    return _store.searchEndorsedDrivers(_searchController.text);
  }

  void _openAddEndorsementScreen() {
    if (widget.onAddEndorsement != null) {
      widget.onAddEndorsement!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TransportOfficeEndorseSearchScreen(),
      ),
    );
  }

  void _openDriverProfile(EndorsedDriver driver) {
    // Map EndorsedDriver to DriverProfile
    final profile = DriverProfile(
      id: driver.id,
      name: driver.name,
      city: driver.city,
      phone: driver.phone,
      avatarAsset: driver.avatarAsset,
      profession: 'سائق نقل بري معتمد',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverProfileScreen(
          driver: profile,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  // ===========================================================================
  // Cancel Endorsement Dialog Flow
  // ===========================================================================
  Future<void> _showCancelEndorsementDialog(EndorsedDriver driver) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isProcessing = false;

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 26.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trash Icon in soft red circle
                      Container(
                        width: 64.0,
                        height: 64.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFECACA),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFDC2626),
                            size: 32.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),

                      // Dialog Title
                      Text(
                        'إلغاء تزكية السائق',
                        style: GoogleFonts.cairo(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12.0),

                      // Main Prompt with driver name
                      Text(
                        'هل أنت متأكد من رغبتك في إلغاء تزكية السائق ${driver.name}؟',
                        style: GoogleFonts.cairo(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),

                      // Explanatory note
                      Text(
                        'ستُزال تزكية مكتبك من الملف، وسيصله إشعار بذلك. لن يؤثر هذا الإجراء على تقييماته أو تزكيات المكاتب الأخرى.',
                        style: GoogleFonts.cairo(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24.0),

                      // Action Button 1: تأكيد الإلغاء (Red)
                      SizedBox(
                        width: double.infinity,
                        height: 48.0,
                        child: ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  setDialogState(() => isProcessing = true);
                                  final success = await _store.cancelEndorsement(driver.id);
                                  if (ctx.mounted) {
                                    Navigator.of(ctx).pop(success);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: isProcessing
                              ? const SizedBox(
                                  width: 20.0,
                                  height: 20.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'تأكيد الإلغاء',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // Action Button 2: تراجع (Soft gray)
                      SizedBox(
                        width: double.infinity,
                        height: 48.0,
                        child: TextButton(
                          onPressed: isProcessing ? null : () => Navigator.of(ctx).pop(false),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: const Color(0xFF334155),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            'تراجع',
                            style: GoogleFonts.cairo(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إلغاء تزكية السائق بنجاح',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFF334155),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (confirmed == false) {
      // User cancelled, do nothing
    } else if (confirmed == null) {
      // Null return implies error or dismiss
    }
  }

  // ===========================================================================
  // Build Methods
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.compactMax,
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      // 1. Independent Sub-screen Header (No main home elements)
                      _buildScreenHeader(),

                      // 2. Main Content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 110.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 14.0),

                              // Primary Action Button: "+ تزكية سائق"
                              _buildAddEndorsementButton(),

                              const SizedBox(height: 12.0),

                              // Real-time Search Field
                              _buildSearchField(),

                              const SizedBox(height: 14.0),

                              // Drivers Cards List or Empty States
                              _buildDriversList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Quick Actions Backdrop when (+) is open
                  if (_isFabSheetOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => _closeQuickActions(),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ),

                  // Floating 2x2 Quick Actions Card
                  if (_isFabSheetOpen)
                    Positioned(
                      left: 16.0,
                      right: 16.0,
                      bottom: 84.0,
                      child: _buildFloatingQuickActionsCard(),
                    ),

                  // Unified 5-Item Bottom Navigation Bar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildUnifiedBottomNavBar(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Screen Header (Dedicated, No home greetings)
  // ===========================================================================
  Widget _buildScreenHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          InkWell(
            onTap: widget.onBack ?? () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.transportOfficeHome);
              }
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18.0,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),

          // Title & Subtitle centered with Group Icon Badge
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'السائقون',
                          style: GoogleFonts.cairo(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.group_rounded,
                            size: 16.0,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'السائقون الذين يزكّيهم مكتبك حاليًا',
                      style: GoogleFonts.cairo(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Balance spacer for symmetrical centering
          const SizedBox(width: 40.0),
        ],
      ),
    );
  }

  // ===========================================================================
  // Add Endorsement Button
  // ===========================================================================
  Widget _buildAddEndorsementButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 48.0,
        child: ElevatedButton(
          onPressed: _openAddEndorsementScreen,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, size: 20.0, color: Colors.white),
              const SizedBox(width: 6.0),
              Text(
                'تزكية سائق',
                style: GoogleFonts.cairo(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Search Field
  // ===========================================================================
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 46.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: 'ابحث بالاسم أو رقم الحساب',
            hintStyle: GoogleFonts.cairo(
              fontSize: 13.0,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF64748B),
              size: 20.0,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18.0,
                      color: Color(0xFF64748B),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11.0),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Drivers List & Cards
  // ===========================================================================
  Widget _buildDriversList() {
    final list = _displayedDrivers;

    // 1. Empty overall state (office has no endorsed drivers)
    if (_store.endorsedDrivers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Column(
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 40.0,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'لا يوجد سائقون مزكّون حالياً من مكتبك',
              style: GoogleFonts.cairo(
                fontSize: 16.0,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6.0),
            Text(
              'يمكنك البحث عن سائقين مسجلين في حمولة وتزكيتهم لتعزيز الموثوقية وتسهيل إسناد الرحلات.',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: _openAddEndorsementScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18.0),
              label: Text(
                'تزكية سائق الآن',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    // 2. Empty search state (no search results match query)
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48.0,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12.0),
            Text(
              'لم يتم العثور على سائق مطابق',
              style: GoogleFonts.cairo(
                fontSize: 15.0,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'تأكد من كتابة الاسم أو رقم الحساب بشكل صحيح.',
              style: GoogleFonts.cairo(
                fontSize: 12.0,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14.0),
            TextButton(
              onPressed: () => _searchController.clear(),
              child: Text(
                'مسح نص البحث',
                style: GoogleFonts.cairo(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Render Driver Cards
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10.0),
        itemBuilder: (context, index) {
          final driver = list[index];
          return _buildDriverCard(driver);
        },
      ),
    );
  }

  Widget _buildDriverCard(EndorsedDriver driver) {
    return InkWell(
      onTap: () => _openDriverProfile(driver),
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 3-dots popup menu on the start side (in RTL)
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF64748B),
                size: 22.0,
              ),
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
              onSelected: (value) {
                if (value == 'profile') {
                  _openDriverProfile(driver);
                } else if (value == 'cancel') {
                  _showCancelEndorsementDialog(driver);
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF334155),
                        size: 20.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'عرض ملف السائق',
                        style: GoogleFonts.cairo(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1.0),
                PopupMenuItem<String>(
                  value: 'cancel',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFDC2626),
                        size: 20.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'إلغاء التزكية',
                        style: GoogleFonts.cairo(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(width: 4.0),

            // Driver details (Middle)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Driver Name
                  Text(
                    driver.name,
                    style: GoogleFonts.cairo(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2.0),

                  // Account Number
                  Text(
                    'رقم الحساب: ${driver.accountNumber}',
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 3.0),

                  // City with green/slate location pin
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14.0,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 3.0),
                      Flexible(
                        child: Text(
                          driver.city,
                          style: GoogleFonts.cairo(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),

                  // Endorsement Status Badge: "مزكّى" with green checkmark only
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 15.0,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'مزكّى',
                        style: GoogleFonts.cairo(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10.0),

            // Driver Avatar (Left side)
            _buildDriverAvatar(driver),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverAvatar(EndorsedDriver driver) {
    return Container(
      width: 54.0,
      height: 54.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          driver.avatarAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFEFF6FF),
            child: Center(
              child: Text(
                driver.name.isNotEmpty ? driver.name.substring(0, 1) : 'س',
                style: GoogleFonts.cairo(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Unified Bottom Navigation Bar
  // ===========================================================================
  Widget _buildUnifiedBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. الرئيسية
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'الرئيسية',
                isActive: false,
                onTap: () => context.go(AppRoutes.transportOfficeHome),
              ),

              // 2. الخريطة
              _buildNavItem(
                icon: Icons.map_outlined,
                label: 'الخريطة',
                isActive: false,
                onTap: () => context.push(AppRoutes.driverCargoMap),
              ),

              // 3. Central (+) FAB
              _buildCenterFab(),

              // 4. طلباتي
              _buildNavItem(
                icon: Icons.assignment_outlined,
                label: 'طلباتي',
                isActive: false,
                onTap: () => context.push(AppRoutes.transportOfficeOrders),
              ),

              // 5. حسابي
              _buildNavItem(
                icon: Icons.person_outline_rounded,
                label: 'حسابي',
                isActive: false,
                onTap: () => context.push(AppRoutes.transportOfficeAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? const Color(0xFFDC2626) : const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24.0),
              const SizedBox(height: 2.0),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11.0,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterFab() {
    return GestureDetector(
      onTap: _toggleQuickActionsSheet,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: const Offset(0, -6.0),
        child: Container(
          width: 54.0,
          height: 54.0,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: _isFabSheetOpen ? 0.55 : 0.4),
                blurRadius: _isFabSheetOpen ? 14.0 : 10.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 0.125).animate(
                CurvedAnimation(
                  parent: _fabAnimController,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Quick Actions Sheet & Grid (2x2)
  // ===========================================================================
  void _toggleQuickActionsSheet() {
    if (_isFabSheetOpen) {
      _closeQuickActions();
    } else {
      _openQuickActions();
    }
  }

  void _openQuickActions() {
    setState(() => _isFabSheetOpen = true);
    _fabAnimController.forward(from: 0.0);
  }

  void _closeQuickActions({bool immediate = false}) {
    if (!_isFabSheetOpen) return;
    if (immediate) {
      _fabAnimController.reset();
      setState(() => _isFabSheetOpen = false);
    } else {
      _fabAnimController.reverse().then((_) {
        if (mounted) {
          setState(() => _isFabSheetOpen = false);
        }
      });
    }
  }

  Widget _buildFloatingQuickActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24.0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12.0, bottom: 4.0),
              width: 38.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionGridTile(
                          icon: Icons.sync_alt_rounded,
                          label: 'تحديث الحالة',
                          onTap: () {
                            _closeQuickActions(immediate: true);
                            _showStatusNotification();
                          },
                        ),
                      ),
                      Container(
                        height: 80.0,
                        width: 1.0,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      Expanded(
                        child: _buildQuickActionGridTile(
                          icon: Icons.local_shipping_rounded,
                          label: 'رحلاتي الجارية',
                          onTap: () {
                            _closeQuickActions(immediate: true);
                            context.push(AppRoutes.transportOfficeTrips);
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 1.0,
                    width: double.infinity,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionGridTile(
                          icon: Icons.support_agent_rounded,
                          label: 'طلب مساعدة',
                          onTap: () {
                            _closeQuickActions(immediate: true);
                            _showSupportDialog();
                          },
                        ),
                      ),
                      Container(
                        height: 80.0,
                        width: 1.0,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      Expanded(
                        child: _buildQuickActionGridTile(
                          icon: Icons.report_problem_rounded,
                          label: 'الإبلاغ عن مشكلة',
                          onTap: () {
                            _closeQuickActions(immediate: true);
                            _showReportIssueDialog();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionGridTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28.0),
            const SizedBox(height: 10.0),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حالة المكتب: متاح لاستقبال الطلبات ✓', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _showSupportDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('الدعم الفني متاح على مدار الساعة عبر 800-HAMULA', style: GoogleFonts.cairo()),
      ),
    );
  }

  void _showReportIssueDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم فتح نافذة الإبلاغ عن مشكلة لوجستية', style: GoogleFonts.cairo()),
      ),
    );
  }
}
