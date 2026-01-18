import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/screens/wizard/web_view.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class Page5 extends StatefulWidget {
  const Page5({super.key});

  @override
  State<Page5> createState() => _Page5State();
}

class _Page5State extends State<Page5> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<Animation<double>> _itemAnimations;
  bool agreed = false;
  bool attemptToContinue = false;
  final termsAndConditionsUrl = Globals().termsAndConditionsUrl;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    // Stagger animations for feature items
    _itemAnimations = List.generate(4, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.3 + (index * 0.12),
          0.75 + (index * 0.06),
          curve: Curves.easeOut,
        ),
      ));
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Title
              Text(
                'Explore More',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium!.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Discover the full power of ThreeFold',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 24),

              // Feature grid
              _buildFeatureItem(
                context,
                'Farming',
                'Manage your farms and nodes',
                Icons.storage_rounded,
                0,
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                'DAO Voting',
                'Participate in governance',
                Icons.how_to_vote_rounded,
                1,
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                'Identity',
                'Verify your identity',
                Icons.person_rounded,
                2,
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                'News',
                'Stay updated with latest',
                Icons.article_rounded,
                3,
              ),

              const SizedBox(height: 32),

              // Terms and Conditions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: agreed,
                    onChanged: (bool? value) {
                      agreed = value ?? false;
                      setState(() {});
                    },
                  ),
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "I agree to ThreeFold's ",
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: !agreed && attemptToContinue
                                  ? colorScheme.error
                                  : colorScheme.onSurface,
                            ),
                          ),
                          TextSpan(
                            text: 'Terms & Conditions.',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: !agreed && attemptToContinue
                                  ? colorScheme.error
                                  : Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationColor: !agreed && attemptToContinue
                                  ? colorScheme.error
                                  : Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WebView(
                                      title: 'Terms and Conditions',
                                      url: termsAndConditionsUrl,
                                    ),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    if (agreed) {
                      saveInitDone();
                      Navigator.pop(context, true);
                    }
                    attemptToContinue = true;
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: colorScheme.primary,
                    elevation: 0,
                  ),
                  child: Text(
                    "Let's Go",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _itemAnimations[index],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.3 + (index * 0.12),
            0.75 + (index * 0.06),
            curve: Curves.easeOut,
          ),
        )),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
