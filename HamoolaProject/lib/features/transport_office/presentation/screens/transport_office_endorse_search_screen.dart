import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/models/transport_office_drivers_store.dart';

/// Screen 2: «تزكية سائق»
/// Search and endorse registered drivers in Hamoola directly from search results.
/// Exact visual fidelity matching the reference mockup (Image 2, Image 3, Image 4, Image 8).
class TransportOfficeEndorseSearchScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const TransportOfficeEndorseSearchScreen({
    super.key,
    this.onBack,
  });

  @override
  State<TransportOfficeEndorseSearchScreen> createState() =>
      _TransportOfficeEndorseSearchScreenState();
}

class _TransportOfficeEndorseSearchScreenState
    extends State<TransportOfficeEndorseSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final TransportOfficeDriversStore _store = TransportOfficeDriversStore.instance;

  String? _successBannerDriverName;
  bool _isSearching = false;

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
    if (mounted) {
      setState(() {
        _isSearching = true;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      });
    }
  }

  List<EndorsedDriver> get _matchingDrivers {
    return _store.searchDrivers(_searchController.text);
  }

  // ===========================================================================
  // Endorsement Flow with Confirmation Dialog & Error Handling
  // ===========================================================================
  Future<void> _handleEndorseAction(EndorsedDriver driver, {bool isReEndorse = false}) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
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
                      // Blue Person Add Icon in soft circle
                      Container(
                        width: 64.0,
                        height: 64.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFDBEAFE),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            isReEndorse ? Icons.replay_rounded : Icons.person_add_rounded,
                            color: const Color(0xFF2563EB),
                            size: 32.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),

                      // Dialog Title
                      Text(
                        isReEndorse ? 'إعادة تزكية السائق' : 'تزكية السائق',
                        style: GoogleFonts.cairo(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12.0),

                      // Confirmation Prompt
                      Text(
                        isReEndorse
                            ? 'هل أنت متأكد من رغبتك في إعادة تزكية السائق ${driver.name}؟'
                            : 'هل أنت متأكد من رغبتك في تزكية السائق ${driver.name}؟',
                        style: GoogleFonts.cairo(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24.0),

                      // Action Button 1: تأكيد التزكية (Blue)
                      SizedBox(
                        width: double.infinity,
                        height: 48.0,
                        child: ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  setDialogState(() => isProcessing = true);
                                  final success = isReEndorse
                                      ? await _store.reEndorseDriver(driver.id)
                                      : await _store.endorseDriver(driver.id);
                                  if (ctx.mounted) {
                                    Navigator.of(ctx).pop(success);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.6),
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
                                  isReEndorse ? 'تأكيد إعادة التزكية' : 'تأكيد التزكية',
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
      setState(() {
        _successBannerDriverName = driver.name;
      });
    } else if (confirmed == false) {
      // User cancelled
    }
  }

  // ===========================================================================
  // Build Method
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
                      // 1. Independent Screen Header
                      _buildScreenHeader(),

                      // 2. Scrollable Body
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 110.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 14.0),

                              // Real-time Search Box
                              _buildSearchField(),

                              const SizedBox(height: 12.0),

                              // Green Success Banner (Image 4)
                              if (_successBannerDriverName != null) ...[
                                _buildSuccessBanner(),
                                const SizedBox(height: 12.0),
                              ],

                              // Search Results List
                              _buildSearchResultsList(),
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
  // Screen Header
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

          // Title & Subtitle with Person Add Badge
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
                          'تزكية سائق',
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
                            Icons.person_add_rounded,
                            size: 16.0,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'ابحث عن سائق مسجّل في حمولة',
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

          // Balance spacer
          const SizedBox(width: 40.0),
        ],
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
            hintText: 'ابحث بالاسم أو رقم الحساب...',
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
  // Success Banner (Image 4)
  // ===========================================================================
  Widget _buildSuccessBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: const Color(0xFF86EFAC)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16A34A).withValues(alpha: 0.08),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Close button (X) on start
            InkWell(
              onTap: () => setState(() => _successBannerDriverName = null),
              borderRadius: BorderRadius.circular(8.0),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.close_rounded,
                  size: 18.0,
                  color: Color(0xFF15803D),
                ),
              ),
            ),
            const SizedBox(width: 8.0),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تمت التزكية بنجاح',
                    style: GoogleFonts.cairo(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                  Text(
                    'تمت إضافة $_successBannerDriverName إلى قائمة السائقين لديك.',
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8.0),

            // Checkmark Icon on end
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF16A34A),
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Search Results List
  // ===========================================================================
  Widget _buildSearchResultsList() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 36.0),
        child: Center(
          child: SizedBox(
            width: 28.0,
            height: 28.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      );
    }

    final results = _matchingDrivers;

    if (results.isEmpty) {
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
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: results.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10.0),
        itemBuilder: (context, index) {
          final driver = results[index];
          return _buildSearchResultCard(driver);
        },
      ),
    );
  }

  Widget _buildSearchResultCard(EndorsedDriver driver) {
    return Container(
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
          // Action button / status badge on start side
          _buildActionOrStatusBadge(driver),

          const SizedBox(width: 8.0),

          // Driver details in middle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                Text(
                  driver.name,
                  style: GoogleFonts.cairo(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3.0),

                // City with location pin
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
              ],
            ),
          ),

          const SizedBox(width: 10.0),

          // Driver Avatar (Left side)
          _buildDriverAvatar(driver),
        ],
      ),
    );
  }

  Widget _buildActionOrStatusBadge(EndorsedDriver driver) {
    Widget content;
    switch (driver.status) {
      case DriverEndorsementStatus.none:
        // Case 1: Driver not endorsed -> "+ تزكية" button
        content = SizedBox(
          height: 36.0,
          child: ElevatedButton(
            onPressed: () => _handleEndorseAction(driver, isReEndorse: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add_rounded, size: 16.0),
                  const SizedBox(width: 4.0),
                  Text(
                    'تزكية',
                    style: GoogleFonts.cairo(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        break;

      case DriverEndorsementStatus.endorsed:
        // Case 2: Driver currently endorsed -> "مزكّى" with green checkmark ONLY
        content = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16.0,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 4.0),
                Text(
                  'مزكّى',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
        );
        break;

      case DriverEndorsementStatus.cancelled:
        // Case 3: Office cancelled endorsement previously -> "إعادة التزكية" button
        content = SizedBox(
          height: 36.0,
          child: ElevatedButton(
            onPressed: () => _handleEndorseAction(driver, isReEndorse: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.replay_rounded, size: 15.0),
                  const SizedBox(width: 4.0),
                  Text(
                    'إعادة التزكية',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        break;
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: content,
    );
  }

  Widget _buildDriverAvatar(EndorsedDriver driver) {
    return Container(
      width: 52.0,
      height: 52.0,
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
