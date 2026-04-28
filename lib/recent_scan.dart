import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'resultpage.dart';
import 'package:dio/dio.dart';

class ScanRecord {
  final String imagePath;
  final String plantName;
  final String? imageUrl;
  final String confidence;
  final String status;
  final DateTime scanTime;

  ScanRecord({
    required this.imagePath,
    required this.plantName,
    required this.confidence,
    this.imageUrl,
    required this.status,
    required this.scanTime,
  });
}

class ScansState extends ChangeNotifier {
  final List<ScanRecord> _scans = [];

  List<ScanRecord> get scans => List.unmodifiable(_scans);

  void add(ScanRecord record) {
    _scans.add(record);
    notifyListeners();
  }

  void remove(int index) {
    _scans.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _scans.clear();
    notifyListeners();
  }

  void setAll(List<ScanRecord> records) {
    _scans
      ..clear()
      ..addAll(records);
    notifyListeners();
  }

  bool get isEmpty => _scans.isEmpty;
}

final scansState = ScansState();

Future<void> saveScans() async {
  final prefs = await SharedPreferences.getInstance();
  final list = scansState.scans
      .map((s) => {
    'imagePath': s.imagePath,
    'imageUrl': s.imageUrl ?? '',
    'plantName': s.plantName,
    'status': s.status,
    'confidence': s.confidence,
    'scanTime': s.scanTime.toIso8601String(),
  })
      .toList();

  await prefs.setString('recentScans', jsonEncode(list));
}

Future<void> loadScans() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('recentScans');
    if (data == null) return;

    final List decoded = jsonDecode(data);

    scansState.setAll(
      decoded
          .map(
            (s) => ScanRecord(
          imagePath: s['imagePath'] ?? '',
          imageUrl: s['imageUrl'],
          plantName: s['plantName'] ?? '',
          status: s['status'] ?? '',
          confidence: (s['confidence'] ?? '0.0').toString(),
          scanTime: DateTime.parse(s['scanTime']),
        ),
      )
          .toList(),
    );
  } catch (_) {
    scansState.clear();
  }
}

class RecentScan extends StatefulWidget {
  const RecentScan({super.key});

  @override
  State<RecentScan> createState() => _RecentScanState();
}

class _RecentScanState extends State<RecentScan> {
  @override
  void initState() {
    super.initState();
    scansState.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _clear() {
    scansState.clear();
    saveScans();
  }

  @override
  Widget build(BuildContext context) {
    final scans = scansState.scans;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            const Text(
              "Recent Scan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: scansState.isEmpty
                  ? const Center(child: Text("No scans yet"))
                  : ListView.builder(
                itemCount: scans.length,
                itemBuilder: (context, index) {
                  final scan = scans[scans.length - 1 - index];

                  return ListTile(
                    leading: scan.imageUrl != null &&
                        scan.imageUrl!.isNotEmpty
                        ? Image.network(scan.imageUrl!)
                        : Image.file(File(scan.imagePath)),

                    title: Text(scan.plantName),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(scan.status),

                        // 🔥 ده التعديل المهم
                        Text(
                          "Accuracy: ${scan.confidence}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    trailing: const Icon(Icons.arrow_forward_ios),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultPage(
                            imagePath: scan.imagePath,
                            plantName: scan.plantName,
                            status: scan.status,
                            confidence: scan.confidence, // 🔥 مهم
                            imageUrl: scan.imageUrl,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> loadScansFromApi(String token) async {
  try {
    final dio = Dio();
    final response = await dio.get(
      'https://plant-pules-api.vercel.app/api/v1/scan/recent',
      options: Options(headers: {'token': token}),
    );

    final List data = response.data['data'] ?? [];

    final apiScans = data.map((s) {
      final images = s['imageUrl'] as List?;
      final imageUrl =
      (images != null && images.isNotEmpty) ? images.first : '';

      final decision = (s['finalDecision'] ?? '').toString().toLowerCase();

      return ScanRecord(
        imagePath: '',
        imageUrl: imageUrl,
        plantName: 'Lettuce',
        status: decision == 'healthy' ? 'Healthy' : 'Diseased',
        confidence: (s['confidence'] ?? '0.0').toString(),
        scanTime: DateTime.parse(s['createdAt']),
      );
    }).toList();

    scansState.setAll(apiScans);
    await saveScans();
  } catch (_) {}
}