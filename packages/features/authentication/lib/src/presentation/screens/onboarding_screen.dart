import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/usecases/set_onboarding_seen.dart';
import '../routing/auth_routes.dart';

final class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}

/// First-run intro slides (storefront only).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({this.setOnboardingSeen, this.slides, super.key});

  final SetOnboardingSeen? setOnboardingSeen;
  final List<OnboardingSlide>? slides;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  var _index = 0;

  List<OnboardingSlide> get _slides {
    if (widget.slides != null) {
      return widget.slides!;
    }
    final name = getIt.isRegistered<TenantConfig>()
        ? getIt<TenantConfig>().displayName
        : 'our store';
    return [
      OnboardingSlide(
        title: 'Welcome to $name',
        body: 'Discover curated products tailored for you.',
        icon: Icons.storefront_outlined,
      ),
      const OnboardingSlide(
        title: 'Shop with confidence',
        body: 'Secure checkout, tracked delivery, and easy returns.',
        icon: Icons.verified_user_outlined,
      ),
      const OnboardingSlide(
        title: 'Ready when you are',
        body: 'Sign in to sync your cart, wishlist, and orders.',
        icon: Icons.shopping_bag_outlined,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_slides.isEmpty && mounted) {
        _complete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final useCase = widget.setOnboardingSeen ?? getIt<SetOnboardingSeen>();
    await useCase(const SetOnboardingSeenParams(seen: true));
    if (!mounted) {
      return;
    }
    context.go(AuthRoutes.loginPath);
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides;
    final isLast = _index >= slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: AppTextLinkButton(label: 'Skip', onPressed: _complete),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          slide.icon,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (i) {
                  final selected = i == _index;
                  return Container(
                    width: selected ? 18 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: isLast ? 'Get started' : 'Next',
                isFullWidth: true,
                onPressed: () {
                  if (isLast) {
                    _complete();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
