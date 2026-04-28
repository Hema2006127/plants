import 'dart:io';
import 'package:flutter/material.dart';
import 'user_state.dart';

class ResultPage extends StatefulWidget {
  final String imagePath;
  final String plantName;
  final String status;
  final String confidence;
  final String? imageUrl;
  final bool fromRecentScan;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.plantName,
    this.imageUrl,
    required this.status,
    required this.confidence,
    this.fromRecentScan = false,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final Future<bool> _imageExistsFuture =
  File(widget.imagePath).exists();

  bool get isHealthy => widget.status == 'Healthy';

  String get safeConfidence {
    if (widget.confidence.isEmpty ||
        widget.confidence == '—' ||
        widget.confidence == 'null') {
      return '0';
    }
    return widget.confidence;
  }

  void _handleBack() {
    if (widget.fromRecentScan) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        'HomePage',
            (route) => false,
        arguments: {
          'firstName': userState.fullName.isNotEmpty
              ? userState.fullName.split(' ')[0]
              : '',
          'fullName': userState.fullName,
          'email': userState.email,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                _buildImage(size),
                const SizedBox(height: 16),
                _buildNameAndBadge(),
                const SizedBox(height: 24),
                _buildMessageCard(),
                const SizedBox(height: 12),
                _buildAccuracyRow(),
                const SizedBox(height: 24),
                _buildCareTips(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccuracyRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA4D19B), width: 0.4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: Color(0xFF399B25), size: 24),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Accuracy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        '${safeConfidence}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF399B25),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCA9C), width: 0.4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFFF8C27), size: 24),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Image Quality',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isHealthy ? 'Good' : 'Low',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF8C27),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
