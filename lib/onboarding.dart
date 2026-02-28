import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      Page_view_model().PageView(
        context,
        "Welcome to PlantPulse!",
        "Discover, track, and care for your plants easily. Your personal plant companion for a greener life.",
        1,
      ),
      Page_view_model().PageView(
        context,
        "Get Expert Tips",
        "Receive daily advice and tips to make your plants thrive",
        2,
      ),
      Page_view_model().PageView(
        context,
        "Care for Your Plants",
        "Learn how to water, fertilize, and help your plants grow healthy and strong",
        3,
      ),
    ];
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          IntroductionScreen(
            key: introKey,
            globalBackgroundColor: const Color(0xFFFFFFFF),
            pages: pages,
            showSkipButton: false,
            showNextButton: false,
            showDoneButton: false,
            dotsDecorator: const DotsDecorator(
              size: Size(0, 0),
              activeSize: Size(0, 0),
            ),
            onChange: (index) {
              setState(() {
                currentPage = index;
              });
            },
          ),
          Container(
            padding: EdgeInsets.only(
              top: size.height * 0.084,
              right: size.width * 0.064,
              left: size.width * 0.064,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (currentPage != 0)
                  Positioned(
                    top: size.height * 0.086,
                    left: size.width * 0.064,
                    right: size.width * 0.064,
                    child: GestureDetector(
                      onTap: () {
                        introKey.currentState?.previous();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: const Color(0xFF4A4A4A),
                        size: 24,
                      ),
                    ),
                  ),
                Spacer(),
                Positioned(
                  top: size.height * 0.086,
                  left: size.width * 0.064,
                  right: size.width * 0.064,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor: MaterialStateProperty.all(
                        const Color(0xFFEDEDED),
                      ),
                      minimumSize: MaterialStateProperty.all(
                        Size(size.width * 0.064, size.height * 0.0345),
                      ),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(
                          vertical: size.height * 0.0023,
                          horizontal: size.width * 0.0567,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('seen', true);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => Login()),
                      );
                    },
                    child: const Text(
                      "Skip",
                      style: const TextStyle(
                        color: const Color(0xFF4A4A4A),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: size.height * 0.197,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: currentPage == index ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? const Color(0xFF399B25)
                          : const Color(0xFFC7C7C7),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.111,
            left: size.width * 0.064,
            right: size.width * 0.064,
            child: SizedBox(
              width: double.infinity,
              height: size.height * 0.0591,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF399B25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (currentPage == pages.length - 1) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool('seen', true);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => Login()),
                    );
                  } else {
                    introKey.currentState?.next();
                  }
                },
                child: Text(
                  currentPage == pages.length - 1 ? "Get Started" : "Next",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Page_view_model {
  PageViewModel PageView(
    BuildContext context,
    String title,
    String body,
    int page_number,
  ) {
    final size = MediaQuery.of(context).size;
    return PageViewModel(
      title: title,
      body: body,
      image: Image.asset(
        "assets/onboarding$page_number.png",
        height: size.height * 0.3239,
      ),
      decoration: PageDecoration(
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF399B25),
        ),
        bodyTextStyle: const TextStyle(
          fontSize: 16,
          color: const Color(0xFF6E6E6E),
          fontWeight: FontWeight.w400,
        ),
        imagePadding: EdgeInsets.only(
          top: size.height * 0.138,
          bottom: size.height * 0.0394,
          left: size.width * 0.149,
          right: size.width * 0.149,
        ),
        titlePadding: EdgeInsets.only(
          right: size.width * 0.064,
          left: size.width * 0.064,
          bottom: size.height * 0.0099,
        ),
        bodyPadding: EdgeInsets.only(
          right: size.width * 0.064,
          left: size.width * 0.064,
        ),
      ),
    );
  }
}
