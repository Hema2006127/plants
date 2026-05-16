import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../state/user_state.dart';
import 'recent_scan.dart';
import 'resultpage.dart';

class HomePageContent extends StatefulWidget {
  final String firstName;
  final String gender;
  final VoidCallback? onProfileTap;

  const HomePageContent({
    super.key,
    required this.firstName,
    required this.gender,
    this.onProfileTap,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  static const _green = Color(0xFF4CAF50);
  static const _lightGreen = Color(0xFFEEF7EE);
  static const _lightOrange = Color(0xFFFFF3E6);
  static const _orange = Color(0xFFFF9800);

  static const List<String> _tips = [
    "Overwatering causes yellow leaves. Water only when the top 2 inches of soil feel dry!",
    "Most plants need at least 6 hours of indirect sunlight per day to thrive.",
    "Misting leaves helps plants absorb moisture in dry environments.",
    "Repot your plant every 1–2 years to give roots more room to grow.",
  ];

  @override
  void initState() {
    super.initState();
    userState.addListener(_onStateChanged);
    scansState.addListener(_onStateChanged);
    _syncScansWithApi();
  }

  Future<void> _syncScansWithApi() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://plant-pules-api.vercel.app/api/v1/scan',
        options: Options(headers: {'token': userState.token}),
      );
      final List data = response.data['data'] ?? [];
      final records = data
          .map((item) => ScanRecord.fromJson(item as Map<String, dynamic>))
          .toList();
      scansState.setAll(records);
      await saveScans();
    } catch (_) {}
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _goToRecentScan() async {
    await Navigator.of(context).pushNamed('RecentScan');
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    userState.removeListener(_onStateChanged);
    scansState.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scans = scansState.scans;
    final latestTwo = scans.reversed.take(2).toList();

    final totalStr = '${scans.length}';
    final healthyStr = '${scans.where((s) => s.status == 'Healthy').length}';
    final diseasedStr = '${scans.where((s) => s.status == 'Diseased').length}';

    final tipIndex = (scans.length) % _tips.length;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: size.height * 0.06,
        left: size.width * 0.064,
        right: size.width * 0.064,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi ${widget.firstName}!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Check Your Plants' Health Summary",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onProfileTap,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: _lightGreen,
                  backgroundImage: userState.profileImagePath != null
                      ? FileImage(File(userState.profileImagePath!))
                            as ImageProvider
                      : AssetImage(
                          userState.gender.toLowerCase() == 'female'
                              ? 'assets/bigProfilePic.png'
                              : 'assets/male.png',
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Statistics title ─────────────────────────────────
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),

          const SizedBox(height: 12),

          // ── Total Scans (full width) ─────────────────────────
          _buildStatCard(
            title: 'Total Scans',
            value: totalStr,
            icon: Icons.qr_code_scanner_rounded,
            iconColor: _green,
            bgColor: _lightGreen,
            fullWidth: true,
          ),

          const SizedBox(height: 10),

          // ── Healthy + Diseased (side by side) ────────────────
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Healthy',
                  value: healthyStr,
                  icon: Icons.monitor_heart_outlined,
                  iconColor: _green,
                  bgColor: _lightGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: 'Diseased',
                  value: diseasedStr,
                  icon: Icons.warning_amber_rounded,
                  iconColor: _orange,
                  bgColor: _lightOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Recent Scans header ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Scans',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              GestureDetector(
                onTap: _goToRecentScan,
                child: Row(
                  children: const [
                    Text(
                      'See More',
                      style: TextStyle(
                        fontSize: 13,
                        color: _green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 18, color: _green),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Scan list or empty state ─────────────────────────
          if (scans.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "No scans yet",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            )
          else
            ...latestTwo.map((scan) => _buildScanTile(scan)),

          const SizedBox(height: 16),

          // ── Did you know? ────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: _green, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Did you know?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tips[tipIndex],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF444444),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Card ──────────────────────────────────────────────────────────────
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Scan Tile ──────────────────────────────────────────────────────────────
  Widget _buildScanTile(ScanRecord scan) {
    final isHealthy = scan.status.toLowerCase() == 'healthy';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultPage(
              imagePath: scan.imagePath,
              plantName: scan.plantName,
              status: scan.status,
              confidence: scan.confidence,
              imageUrl: scan.imageUrl,
              fromRecentScan: true,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _scanImage(scan),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.plantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isHealthy ? _lightGreen : _lightOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      scan.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isHealthy ? _green : _orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _scanImage(ScanRecord scan) {
    if (scan.imageUrl != null && scan.imageUrl!.isNotEmpty) {
      return Image.network(
        scan.imageUrl!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    if (scan.imagePath.isNotEmpty) {
      return Image.file(
        File(scan.imagePath),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: _lightGreen,
      child: const Icon(Icons.eco_outlined, color: _green, size: 26),
    );
  }
}
