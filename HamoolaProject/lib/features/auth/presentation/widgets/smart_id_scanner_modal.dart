import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Interactive Smart ID Scanner Modal (`modalIdScanner`).
/// Simulates optical recognition (OCR) of the national ID card with:
/// - Camera viewfinder shell
/// - Corner alignment brackets
/// - Animated laser scan line
/// - Simulated Yemeni smart ID card in viewport
/// - Automatic data extraction and field autofill callback
class SmartIdScannerModal extends StatefulWidget {
  final VoidCallback onScannedDataApplied;

  const SmartIdScannerModal({
    super.key,
    required this.onScannedDataApplied,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onScannedDataApplied,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => SmartIdScannerModal(
        onScannedDataApplied: onScannedDataApplied,
      ),
    );
  }

  @override
  State<SmartIdScannerModal> createState() => _SmartIdScannerModalState();
}

class _SmartIdScannerModalState extends State<SmartIdScannerModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  void _triggerScan() {
    setState(() => _isProcessing = true);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onScannedDataApplied();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF16A34A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تم مسح وقراءة بيانات البطاقة الشخصية بنجاح ✓',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400.0),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24.0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'إغلاق',
                  ),
                  Expanded(
                    child: Text(
                      'مسح بطاقة الهوية الذكي',
                      style: GoogleFonts.cairo(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48.0), // Balance close button
                ],
              ),
            ),

            // Camera Viewfinder Box
            Container(
              height: 250.0,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Grid background
                    Opacity(
                      opacity: 0.15,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/id_front_preview.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Card Focus Frame with Corner Brackets
                    Container(
                      width: 280.0,
                      height: 170.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Stack(
                        children: [
                          // 4 Corner Brackets
                          _buildCornerBracket(top: 0, right: 0, isTop: true, isRight: true),
                          _buildCornerBracket(top: 0, left: 0, isTop: true, isRight: false),
                          _buildCornerBracket(bottom: 0, right: 0, isTop: false, isRight: true),
                          _buildCornerBracket(bottom: 0, left: 0, isTop: false, isRight: false),

                          // Simulated ID Card Mockup inside frame
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44.0,
                                    height: 52.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6.0),
                                      image: const DecorationImage(
                                        image: AssetImage('assets/images/avatar_personal_preview.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(height: 8.0, width: 80.0, color: Colors.white54),
                                        const SizedBox(height: 6.0),
                                        Container(height: 6.0, width: 120.0, color: Colors.white30),
                                        const SizedBox(height: 6.0),
                                        Text(
                                          '11010290469',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFF59E0B),
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Animated Laser Scan Line
                          AnimatedBuilder(
                            animation: _laserAnimation,
                            builder: (context, child) {
                              return Positioned(
                                top: _laserAnimation.value * 160.0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 3.0,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0xFFEF4444),
                                        Color(0xFFF59E0B),
                                        Colors.transparent,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF59E0B).withValues(alpha: 0.8),
                                        blurRadius: 6.0,
                                        spreadRadius: 1.0,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            // Instruction prompt
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'ضع بطاقة الهوية الشخصية داخل الإطار لمسح وقراءة البيانات تلقائياً',
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16.0),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 18.0),
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _triggerScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE67E22),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18.0,
                        height: 18.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.qr_code_scanner_rounded, size: 20.0),
                label: Text(
                  _isProcessing ? 'جاري القراءة والمعالجة...' : 'مسح البطاقة الذكية الآن',
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerBracket({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isRight,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 18.0,
        height: 18.0,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: Color(0xFFF59E0B), width: 3.0)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Color(0xFFF59E0B), width: 3.0)
                : BorderSide.none,
            right: isRight
                ? const BorderSide(color: Color(0xFFF59E0B), width: 3.0)
                : BorderSide.none,
            left: !isRight
                ? const BorderSide(color: Color(0xFFF59E0B), width: 3.0)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
