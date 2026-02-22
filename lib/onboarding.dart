import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OnBoardingScreen extends StatefulWidget {
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();
  int currentPage = 0;
  final pages = [
    Page_view_model().PageView(
      "Welcome to PlantPulse!",
      "Discover, track, and care for your plants easily. Your personal plant companion for a greener life.",
      1,
    ),
    Page_view_model().PageView(
      "Get Expert Tips",
      "Receive daily advice and tips to make your plants thrive",
      2,
    ),
    Page_view_model().PageView(
      "Care for Your Plants",
      "Learn how to water, fertilize, and help your plants grow healthy and strong",
      3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
              top: MyApp.height * 0.084,
              right: MyApp.width * 0.064,
              left: MyApp.width * 0.064,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (currentPage != 0)
                  Positioned(
                    top: MyApp.height * 0.086,
                    left: MyApp.width * 0.064,
                    right: MyApp.width * 0.064,
                    child: GestureDetector(
                      onTap: () {
                        introKey.currentState?.previous();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF4A4A4A),
                        size: 24,
                      ),
                    ),
                  ),
                Spacer(),
                Positioned(
                  top: MyApp.height * 0.086,
                  left: MyApp.width * 0.064,
                  right: MyApp.width * 0.064,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Color(0xFFEDEDED),
                      ),
                      minimumSize: MaterialStateProperty.all(
                        Size(MyApp.width * 0.064, MyApp.height * 0.0345),
                      ),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(
                          vertical: MyApp.height * 0.0123,
                          horizontal: MyApp.width * 0.0567,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('seen', true);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    },
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: Color(0xFF4A4A4A),
                        fontFamily: 'Poppins',
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
            bottom: MyApp.height * 0.197,
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
                          : Color(0xFFC7C7C7),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MyApp.height * 0.111,
            left: MyApp.width * 0.072,
            right: MyApp.width * 0.056,
            child: SizedBox(
              width: double.infinity,
              height: MyApp.height * 0.0591,
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
                      MaterialPageRoute(builder: (_) => HomeScreen()),
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
  PageViewModel PageView(String title, String body, int page_number) {
    return PageViewModel(
      title: title,
      body: body,
      image: Image.asset(
        "assets/onboarding$page_number.png",
        height: MyApp.height * 0.3239,
      ),
      decoration: PageDecoration(
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF399B25),
        ),
        bodyTextStyle: const TextStyle(
          fontSize: 16,
          color: Color(0xFF6E6E6E),
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
        ),
        imagePadding: EdgeInsets.only(
          top: MyApp.height * 0.138,
          bottom: MyApp.height * 0.0394,
          left: MyApp.width * 0.149,
          right: MyApp.width * 0.149,
        ),
        titlePadding: EdgeInsets.only(
          right: MyApp.width * 0.064,
          left: MyApp.width * 0.064,
          bottom: MyApp.height * 0.0123,
          top: MyApp.height * 0.0394,
        ),
        bodyPadding: EdgeInsets.only(
          right: MyApp.width * 0.064,
          left: MyApp.width * 0.064,
          bottom: MyApp.height * 0.1564,
          top: MyApp.height * 0.0123,
        ),
      ),
    );
  }
}
