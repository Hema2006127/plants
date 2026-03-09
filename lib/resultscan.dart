import 'dart:io';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final String imagePath;
  final String plantName;
  final String status;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.plantName,
    required this.status,
  });

  bool get isHealthy => status == 'Healthy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF1F1F1F)),
                    ),
                    const Expanded(
                      child: Text(
                        'Result Page',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),

              // 2. Plant Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: File(imagePath).existsSync()
                      ? Image.file(File(imagePath), width: double.infinity, height: 184, fit: BoxFit.cover)
                      : Container(
                    width: double.infinity,
                    height: 184,
                    color: const Color(0xFFD9D9D9),
                    child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. Plant Name + Status Badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(plantName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1F1F1F),
                        )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHealthy ? const Color(0xFFEBF5E9) : const Color(0xFFFFEAEA),
                        borderRadius: BorderRadius.circular(56),
                        border: Border.all(
                          color: isHealthy ? const Color(0xFFA4D19B) : const Color(0xFFEB9F9F),
                          width: 0.4,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isHealthy ? Icons.check_circle_outline : Icons.error_outline,
                            size: 13,
                            color: isHealthy ? const Color(0xFF399B25) : const Color(0xFFE53935),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isHealthy ? 'Healthy Condition' : 'Issue Detected',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              color: isHealthy ? const Color(0xFF399B25) : const Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 4. Message Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isHealthy ? const Color(0xFFEBF5E9) : const Color(0xFFFFEAEA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isHealthy ? const Color(0xFFA4D19B) : const Color(0xFFEB9F9F),
                      width: 0.4,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isHealthy ? Icons.check_circle_outline : Icons.error_outline,
                            color: isHealthy ? const Color(0xFF399B25) : const Color(0xFFE53935),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isHealthy ? 'Your plant is healthy and thriving!' : 'Detected Disease',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                        ],
                      ),
                      if (!isHealthy) ...[
                        const SizedBox(height: 4),
                        const Padding(
                          padding: EdgeInsets.only(left: 28),
                          child: Text('Nutrient Deficiency',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Poppins',
                                color: Color(0xFFE53935),
                              )),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 5. Accuracy + Severity/Leaf
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 65,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF5E9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFA4D19B), width: 0.4),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Color(0xFF399B25), size: 24),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Accuracy',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Color(0xFF1F1F1F))),
                                Text('94%',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Poppins', color: Color(0xFF399B25))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 65,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFCC80), width: 0.4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFE65100), size: 24),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(isHealthy ? 'Leaf Condition' : 'Severity',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Color(0xFF1F1F1F))),
                                Text(isHealthy ? 'Excellent' : 'Medium',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Poppins', color: Color(0xFFE65100))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 6. Plant Status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFACACAC), width: 0.4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Plant Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0xFF1F1F1F),
                          )),
                      const SizedBox(height: 10),
                      Text(
                        isHealthy
                            ? 'Your lettuce is growing well and shows no signs of disease or stress.'
                            : 'This plant is unhealthy due to poor water quality and nutrient imbalance. The leaves are yellow and wilted, and the roots are weak. Immediate care is needed to improve plant health.',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1F1F1F),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 7. Care Tips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA4D19B), width: 0.4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Color(0xFF399B25), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isHealthy ? 'Care Tips for Ongoing Health' : 'Recommended Treatment Steps',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...(isHealthy
                          ? ['Use clean, fresh water', 'Maintain proper temperature', 'Provide balanced lighting', 'Ensure good air circulation']
                          : ['Change the water immediately', 'Adjust nutrient solution', 'Avoid excessive light', 'Remove affected leaves'])
                          .map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Color(0xFF1F1F1F), fontSize: 10)),
                            Expanded(
                              child: Text(tip,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF1F1F1F),
                                  )),
                            ),
                          ],
                        ),
                      )).toList(), // تم إضافة toList لضمان عمل الكود
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20), // مسافة بسيطة في الأسفل
            ],
          ),
        ),
      ),
    );
  }
}
