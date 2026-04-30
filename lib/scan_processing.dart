import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'green_button.dart';
import 'recent_scan.dart';
import 'resultpage.dart';
import 'user_state.dart';

class ScanProcessing extends StatefulWidget {
  final String imagePath;

  const ScanProcessing({super.key, required this.imagePath});

  @override
  State<ScanProcessing> createState() => _ScanProcessingState();
}

class _ScanProcessingState extends State<ScanProcessing>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  bool _scanComplete = false;
  late AnimationController _lineController;
  Timer? _progressTimer;

  bool _resultSaved = false;
  String? _savedStatus;

  String? _apiStatus;
  String? _apiConfidence;
  bool _apiDone = false;
  String? _apiError;

  static const _scanUrl =
      'https://plant-pules-api.vercel.app/api/v1/scan/predict';

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _callScanApi();
  }

  void _startAnimation() {
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;

      setState(() {
        _progress += 0.014;

        if (_progress >= 1.0) {
          _progress = 1.0;
          _lineController.stop();
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

        // 🔥 أهم تعديل هنا
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
    _lineController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            const Text(
              'Plant AI Scanner',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            if (!_scanComplete)
              const CircularProgressIndicator()
            else
              _buildSuccessSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessSection() {
    if (_apiError != null) {
      return Column(
        children: [
          Text(_apiError!),
          GreenButton(
            text: 'Try Again',
            onPress: () => Navigator.pop(context),
          ),
        ],
      );
    }

    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 40),

        const SizedBox(height: 10),

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

            // 🔥 هنا أهم إصلاح (مفيش "---" تاني)
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
    );
  }
}
