import 'dart:async';
import 'dart:io';
import 'dart:math' show pi;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../widgets/green_button.dart';
import 'recent_scan.dart';
import 'resultpage.dart';
import '../state/user_state.dart';

class ScanProcessing extends StatefulWidget {
  final String imagePath;

  const ScanProcessing({super.key, required this.imagePath});

  @override
  State<ScanProcessing> createState() => _ScanProcessingState();
}

class _ScanProcessingState extends State<ScanProcessing>
    with TickerProviderStateMixin {
  double _progress = 0.0;
  bool _scanComplete = false;
  Timer? _progressTimer;

  bool _resultSaved = false;
  String? _savedStatus;

  String? _apiStatus;
  String? _apiConfidence;
  bool _apiDone = false;
  String? _apiError;

  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnim;

  static const _scanUrl =
      'https://plant-pules-api.vercel.app/api/v1/scan/predict';
  static const _green = Color(0xFF399B25);

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scanLineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    _startProgress();
    _callScanApi();
  }

  void _startProgress() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 0.014;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          _checkComplete();
        }
      });
    });
  }

  void _checkComplete() {
    if (_progress >= 1.0 && _apiDone) {
      if (mounted) setState(() => _scanComplete = true);
    }
  }

  Future<void> _callScanApi() async {
    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(widget.imagePath),
      });
      final response = await dio.post(
        _scanUrl,
        data: formData,
        options: Options(headers: {'token': userState.token}),
      );
      final data = response.data['data'];
      final decision =
          (data?['finalDecision'] as String? ?? '').toLowerCase();
      final confidenceNum = (data?['averageConfidence'] as num? ?? 0);
      setState(() {
        _apiStatus = decision == 'healthy' ? 'Healthy' : 'Diseased';
        _apiConfidence = confidenceNum.toStringAsFixed(0);
        _apiDone = true;
      });
    } catch (e) {
      setState(() {
        _apiError = 'Scan failed. Please try again.';
        _apiDone = true;
      });
    }
    _checkComplete();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final progressPercent = (_progress * 100).toInt();
    final imgSize = size.width * 0.55;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.06),

            // ── Title ────────────────────────────────────────────
            const Text(
              'Plant AI Scanner',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Analyzing plant health and species',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),

            const Spacer(),

            // ── Image with scanner frame ──────────────────────────
            SizedBox(
              width: imgSize + 32,
              height: imgSize + 32,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(widget.imagePath),
                      width: imgSize,
                      height: imgSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Scan line
                  if (!_scanComplete)
                    AnimatedBuilder(
                      animation: _scanLineAnim,
                      builder: (_, __) {
                        final top = _scanLineAnim.value * (imgSize - 4);
                        return Positioned(
                          top: (imgSize + 32 - imgSize) / 2 + top,
                          left: (imgSize + 32 - imgSize) / 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: imgSize,
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _green.withValues(alpha: 0.0),
                                    _green.withValues(alpha: 0.9),
                                    _green.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  // Corner frame
                  SizedBox(
                    width: imgSize + 20,
                    height: imgSize + 20,
                    child: CustomPaint(
                      painter: _ScannerFramePainter(
                        color: _green,
                        strokeWidth: 3.5,
                        cornerLength: 28,
                        radius: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Tip text ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
              child: const Text(
                'Make sure the plant is clearly visible in the photo for best results.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                  height: 1.5,
                ),
              ),
            ),

            const Spacer(flex: 2),

            // ── Progress or result ────────────────────────────────
            if (!_scanComplete) ...[
              // Pill button
              Container(
                margin: EdgeInsets.symmetric(horizontal: size.width * 0.064),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _green, width: 2.5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Scanning in progress... $progressPercent%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Progress bar
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: size.width * 0.064),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_green),
                  ),
                ),
              ),
            ] else
              _buildResultSection(size),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(Size size) {
    if (_apiError != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.064),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 40),
            const SizedBox(height: 8),
            Text(
              _apiError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
            const SizedBox(height: 16),
            GreenButton(
              text: 'Try Again',
              onPress: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.064),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle, color: _green, size: 22),
              SizedBox(width: 8),
              Text(
                'Scan complete!',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: _green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GreenButton(
            text: 'See Result',
            onPress: () async {
              if (_resultSaved) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultPage(
                      imagePath: widget.imagePath,
                      plantName: 'Lettuce',
                      status: _savedStatus!,
                      confidence: _apiConfidence ?? '0',
                    ),
                  ),
                );
                return;
              }

              _resultSaved = true;
              final status = _apiStatus ?? 'Healthy';
              _savedStatus = status;

              scansState.add(
                ScanRecord(
                  imagePath: widget.imagePath,
                  plantName: 'Lettuce',
                  status: status,
                  confidence: _apiConfidence ?? '0',
                  scanTime: DateTime.now(),
                ),
              );
              await saveScans();

              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultPage(
                    imagePath: widget.imagePath,
                    plantName: 'Lettuce',
                    status: status,
                    confidence: _apiConfidence ?? '0',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Scanner corner frame painter ──────────────────────────────────────────────
class _ScannerFramePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double radius;

  const _ScannerFramePainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final r = radius;
    final c = cornerLength;

    // Top-left
    canvas.drawLine(Offset(r, 0), Offset(r + c, 0), paint);
    canvas.drawArc(
        Rect.fromLTWH(0, 0, r * 2, r * 2), -pi / 2 * 2, pi / 2, false, paint);
    canvas.drawLine(Offset(0, r), Offset(0, r + c), paint);

    // Top-right
    canvas.drawLine(Offset(w - r - c, 0), Offset(w - r, 0), paint);
    canvas.drawArc(
        Rect.fromLTWH(w - r * 2, 0, r * 2, r * 2), -pi / 2, pi / 2, false, paint);
    canvas.drawLine(Offset(w, r), Offset(w, r + c), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, h - r - c), Offset(0, h - r), paint);
    canvas.drawArc(
        Rect.fromLTWH(0, h - r * 2, r * 2, r * 2), pi / 2 * 2, pi / 2, false, paint);
    canvas.drawLine(Offset(r, h), Offset(r + c, h), paint);

    // Bottom-right
    canvas.drawLine(Offset(w, h - r - c), Offset(w, h - r), paint);
    canvas.drawArc(
        Rect.fromLTWH(w - r * 2, h - r * 2, r * 2, r * 2), 0, pi / 2, false, paint);
    canvas.drawLine(Offset(w - r - c, h), Offset(w - r, h), paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerFramePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
