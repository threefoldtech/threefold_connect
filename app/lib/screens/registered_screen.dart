import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/widgets/chat_widget.dart';
import 'package:threebotlogin/widgets/home_card.dart';
import 'package:threebotlogin/widgets/home_logo.dart';

class RegisteredScreen extends StatefulWidget {
  static final RegisteredScreen _singleton = RegisteredScreen._internal();

  factory RegisteredScreen() {
    return _singleton;
  }

  RegisteredScreen._internal();

  @override
  State<RegisteredScreen> createState() => _RegisteredScreenState();
}

class _RegisteredScreenState extends State<RegisteredScreen> {
  static const List<Map<String, dynamic>> _quickAccessCards = [
    {'name': 'Wallet', 'icon': Icons.account_balance_wallet, 'page': 2},
    {'name': 'Farming', 'icon': Icons.storage, 'page': 3},
    {'name': 'Market', 'icon': Icons.show_chart_sharp, 'page': 6},
    {'name': 'Dao', 'icon': Icons.how_to_vote_outlined, 'page': 4},
    {'name': 'Sign', 'icon': Icons.draw_sharp, 'page': 9},
    {'name': 'News', 'icon': Icons.article, 'page': 1},
    {'name': 'Identity', 'icon': Icons.person, 'page': 5},
    {'name': 'Settings', 'icon': Icons.settings, 'page': 7},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colorScheme.surfaceContainerHighest,
        statusBarIconBrightness: colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerHighest,
        body: Column(
        children: [
          _buildHeroSection(colorScheme, screenHeight),
          Expanded(
            child: Container(
              color: colorScheme.surfaceContainerHighest,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildDescription(colorScheme),
                      const SizedBox(height: 24),
                      _buildSectionHeader(colorScheme),
                      _buildCardGrid(),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: CrispChatbot(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildHeroSection(ColorScheme colorScheme, double screenHeight) {
    return Container(
      height: screenHeight * 0.20,
      width: double.infinity,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/map.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              colorScheme.surfaceContainerHighest.withOpacity(0.4),
              colorScheme.surfaceContainerHighest,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Hero(
            tag: 'logo',
            child: HomeLogoWidget(animate: false),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(ColorScheme colorScheme) {
    return Text(
      'Your portal to ThreeFold: access your wallets, your digital identity, your farms, and ThreeFold updates with ease.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
    );
  }

  Widget _buildSectionHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        'Quick Access',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildCardGrid() {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 8,
      runSpacing: 8,
      children: _quickAccessCards.map((card) {
        return HomeCardWidget(
          name: card['name'] as String,
          icon: card['icon'] as IconData,
          pageNumber: card['page'] as int,
        );
      }).toList(),
    );
  }
}
