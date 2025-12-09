import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Welcome to RecyConnect',
      'text': 'Your partner in sustainable recycling. Connect with buyers and sellers effortlessly.',
      'image': 'assets/images/onboarding_1.png', // Placeholder or use Icons
      'icon': 'recycle'
    },
    {
      'title': 'Sell Your Recyclables',
      'text': 'List your plastic, paper, metal, and e-waste. Get the best value for your waste.',
      'image': 'assets/images/onboarding_2.png',
      'icon': 'sell'
    },
    {
      'title': 'Track Your Impact',
      'text': 'Monitor your earnings and environmental contribution in real-time.',
      'image': 'assets/images/onboarding_3.png',
      'icon': 'chart'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => OnboardingContent(
                  title: _onboardingData[index]['title']!,
                  text: _onboardingData[index]['text']!,
                  iconStr: _onboardingData[index]['icon']!,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => buildDot(index: index),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          _currentPage == _onboardingData.length - 1 ? "Get Started" : "Continue",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildDot({required int index}) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primaryGreen : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
}

class OnboardingContent extends StatelessWidget {
  final String title, text, iconStr;

  const OnboardingContent({
    Key? key,
    required this.title,
    required this.text,
    required this.iconStr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (iconStr) {
      case 'sell':
        iconData = Icons.monetization_on_outlined;
        break;
      case 'chart':
        iconData = Icons.bar_chart;
        break;
      default:
        iconData = Icons.recycling;
    }

    return Column(
      children: [
        const Spacer(),
        Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconData,
            size: 150,
            color: AppColors.primaryGreen,
          ),
        ),
        const Spacer(),
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
