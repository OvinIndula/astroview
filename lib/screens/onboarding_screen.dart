import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
        },
        children: [
          _buildPage(
            title: 'Discover Daily Astronomy',
            description:
                'Explore a new NASA image every day with detailed explanations',
            icon: Icons.image,
            color: Colors.blue,
          ),
          _buildPage(
            title: 'Save Your Favorites',
            description:
                'Tap the ❤️ icon to save images to your personal collection',
            icon: Icons.favorite,
            color: Colors.red,
          ),
          _buildPage(
            title: 'Customize Your Experience',
            description:
                'Dark mode and adjustable text size for your comfort and accessibility',
            icon: Icons.brightness_4,
            color: Colors.purple,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _completeOnboarding,
              child: Text('SKIP'),
            ),
            Row(
              children: List.generate(
                3,
                (index) => Container(
                  height: 8,
                  width: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
            _currentPage == 2
                ? ElevatedButton(
                    onPressed: _completeOnboarding,
                    child: Text('GET STARTED'),
                  )
                : ElevatedButton(
                    onPressed: () => _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    child: Text('NEXT'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 100,
                color: color,
              ),
              SizedBox(height: 32),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}