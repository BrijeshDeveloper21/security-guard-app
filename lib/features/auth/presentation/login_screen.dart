import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security_app/core/providers/app_providers.dart';
import 'package:security_app/features/settings/presentation/app_settings_screen.dart';

import 'join_society_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _ink = Color(0xFF14233F);
  static const _blue = Color(0xFF2859C5);
  static const _featureImages = [
    'assets/images/smart_gate.png',
    'assets/images/instant_approvals.png',
    'assets/images/qr_passes.png',
    'assets/images/emergency_sos.png',
  ];
  static const _featureCaptionKeys = [
    'login_caption_gate',
    'login_caption_approval',
    'login_caption_pass',
    'login_caption_emergency',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showLoginBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: const LoginBottomSheet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return _buildDesktopLayout();
            }
            return _buildMobileLayout(constraints.maxWidth);
          },
        ),
      ),
    );
  }

  Widget _buildHeaderControls() {
    final lang = ref.watch(languageProvider);
    final accessibility = ref.watch(accessibilityProvider);
    final translator = ref.watch(languageProvider.notifier);
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: translator.translate('language_picker'),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: lang,
                hint: Text(translator.translate('language_label')),
                borderRadius: BorderRadius.circular(12),
                dropdownColor: theme.colorScheme.surface,
                icon: const Icon(
                  Icons.language_rounded,
                  color: _blue,
                  size: 18,
                ),
                isDense: true,
                items: const [
                  DropdownMenuItem(value: 'EN', child: Text('EN')),
                  DropdownMenuItem(value: 'HI', child: Text('हिन्दी')),
                  DropdownMenuItem(value: 'MR', child: Text('मराठी')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(languageProvider.notifier)
                        .setLang(value)
                        .catchError((Object error) {
                          if (mounted) {
                            debugPrint(
                              'Failed to save language preference: $error',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  translator.translate('settings_save_error'),
                                ),
                              ),
                            );
                          }
                        });
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          label: translator.translate('high_contrast'),
          button: true,
          child: IconButton(
            tooltip: translator.translate('high_contrast'),
            onPressed: () {
              ref
                  .read(accessibilityProvider.notifier)
                  .setHighContrast(!accessibility.highContrast)
                  .catchError((Object error) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Could not save the contrast preference: $error',
                          ),
                        ),
                      );
                    }
                  });
            },
            icon: Icon(
              accessibility.highContrast
                  ? Icons.contrast_rounded
                  : Icons.contrast_outlined,
              color: _blue,
            ),
          ),
        ),
        Semantics(
          label: translator.translate('accessibility_settings'),
          button: true,
          child: IconButton(
            tooltip: translator.translate('accessibility_settings'),
            onPressed: () => AppSettingsScreen.open(context),
            icon: const Icon(Icons.tune_rounded, color: _blue),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _buildIntroduction(isDesktop: true)),
              const SizedBox(width: 64),
              Expanded(
                child: _buildFeatureGallery(
                  height: (MediaQuery.sizeOf(context).height - 110).clamp(
                    420.0,
                    650.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(double width) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _buildBrand()),
                  _buildHeaderControls(),
                ],
              ),
              const SizedBox(height: 32),
              _buildHeadline(isDesktop: false),
              const SizedBox(height: 12),
              Text(
                ref
                    .watch(languageProvider.notifier)
                    .translate('login_mobile_description'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 24),
              _buildFeatureGallery(height: width < 420 ? 300 : 350),
              const SizedBox(height: 24),
              _buildContinueButton(),
              const SizedBox(height: 14),
              _buildLegalNote(textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroduction({required bool isDesktop}) {
    final translator = ref.watch(languageProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: _buildBrand()),
            _buildHeaderControls(),
          ],
        ),
        const SizedBox(height: 58),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_rounded, size: 16, color: _blue),
              const SizedBox(width: 8),
              Text(
                translator.translate('login_badge'),
                style: const TextStyle(
                  color: _blue,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _buildHeadline(isDesktop: isDesktop),
        const SizedBox(height: 18),
        Text(
          translator.translate('login_intro'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 16,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 28),
        _BenefitRow(
          icon: Icons.flash_on_rounded,
          label: ref
              .watch(languageProvider.notifier)
              .translate('login_benefit_checkin'),
        ),
        const SizedBox(height: 14),
        _BenefitRow(
          icon: Icons.check_circle_outline_rounded,
          label: ref
              .watch(languageProvider.notifier)
              .translate('login_benefit_approvals'),
        ),
        const SizedBox(height: 14),
        _BenefitRow(
          icon: Icons.qr_code_2_rounded,
          label: ref
              .watch(languageProvider.notifier)
              .translate('login_benefit_passes'),
        ),
        const SizedBox(height: 36),
        SizedBox(width: 310, child: _buildContinueButton()),
        const SizedBox(height: 18),
        _buildLegalNote(textAlign: TextAlign.left),
      ],
    );
  }

  Widget _buildBrand() {
    final highContrast = ref.watch(accessibilityProvider).highContrast;
    final ink = highContrast ? Colors.black : _ink;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _blue,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: _blue.withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.shield_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 11),
        Text(
          'dwarivo',
          style: TextStyle(
            color: ink,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline({required bool isDesktop}) {
    final translator = ref.watch(languageProvider.notifier);
    final highContrast = ref.watch(accessibilityProvider).highContrast;
    final ink = highContrast ? Colors.black : _ink;
    final blue = highContrast ? const Color(0xFF0037B3) : _blue;

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: ink,
          fontSize: isDesktop ? 50 : 36,
          height: 1.08,
          fontWeight: FontWeight.w800,
          letterSpacing: isDesktop ? -2 : -1.2,
        ),
        children: [
          TextSpan(text: '${translator.translate('login_headline_first')}\n'),
          TextSpan(
            text: translator.translate('login_headline_second'),
            style: TextStyle(color: ink),
          ),
          TextSpan(
            text: translator.translate('login_headline_secure'),
            style: TextStyle(color: blue),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGallery({required double height}) {
    final translator = ref.watch(languageProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: translator.translate(_featureCaptionKeys[_currentPage]),
          liveRegion: true,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFE8EDF5)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x121B2F54),
                  blurRadius: 34,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _featureImages.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(12),
                  child: Semantics(
                    image: true,
                    label: ref
                        .watch(languageProvider.notifier)
                        .translate(_featureCaptionKeys[index]),
                    child: Image.asset(
                      _featureImages[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.security_rounded,
                              size: 72,
                              color: _blue,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 19),
        Text(
          ref
              .watch(languageProvider.notifier)
              .translate(_featureCaptionKeys[_currentPage]),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _featureImages.length,
            (index) => Semantics(
              label:
                  '${ref.watch(languageProvider.notifier).translate(_featureCaptionKeys[index])}, ${index + 1} of ${_featureImages.length}',
              button: true,
              selected: _currentPage == index,
              child: InkWell(
                onTap: () => _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                ),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _blue
                            : const Color(0xFFD5DCE8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    final label = ref
        .watch(languageProvider.notifier)
        .translate('login_continue');

    return Semantics(
      label: label,
      button: true,
      excludeSemantics: true,
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _showLoginBottomSheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded, size: 19),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalNote({required TextAlign textAlign}) {
    return Text(
      ref.watch(languageProvider.notifier).translate('login_legal'),
      textAlign: textAlign,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 12,
        height: 1.5,
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: const Color(0xFF2859C5)),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF34445F),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class LoginBottomSheet extends ConsumerStatefulWidget {
  const LoginBottomSheet({super.key});

  @override
  ConsumerState<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends ConsumerState<LoginBottomSheet> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _showOtpField = false;
  bool _isInfoError = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      setState(() {
        _isInfoError = false;
        _error = ref
            .read(languageProvider.notifier)
            .translate('auth_phone_invalid');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _isInfoError = false;
    });

    try {
      final authService = ref.read(authServiceProvider.notifier);
      final user = await authService.lookupUserByPhone(phone);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _showOtpField = true;
        if (user == null) {
          _isInfoError = true;
          _error = ref
              .read(languageProvider.notifier)
              .translate('auth_number_not_found');
        }
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('Failed to send verification code: $error');
      setState(() {
        _isLoading = false;
        _error = ref
            .read(languageProvider.notifier)
            .translate('auth_send_failed');
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length < 4) {
      setState(() {
        _isInfoError = false;
        _error = ref
            .read(languageProvider.notifier)
            .translate('auth_code_required');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _isInfoError = false;
    });

    try {
      final authService = ref.read(authServiceProvider.notifier);
      final success = await authService.verifyOtpAndLogin(phone, otp);
      if (!mounted) return;

      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      } else if (otp != '1234') {
        setState(() {
          _error = ref
              .read(languageProvider.notifier)
              .translate('auth_code_invalid');
        });
      } else {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JoinSocietyScreen()),
        );
      }
    } catch (error) {
      if (!mounted) return;
      debugPrint('Failed to verify sign-in code: $error');
      setState(() {
        _isLoading = false;
        _error = ref
            .read(languageProvider.notifier)
            .translate('auth_verify_failed');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final translator = ref.watch(languageProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E0EC),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _showOtpField
                  ? translator.translate('auth_enter_code')
                  : translator.translate('auth_welcome'),
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: Color(0xFF14233F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _showOtpField
                  ? '${translator.translate('auth_code_sent')}${_phoneController.text}'
                  : translator.translate('auth_enter_phone'),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF687891),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            if (_error != null) ...[
              Semantics(
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isInfoError
                        ? const Color(0xFFEAF3FF)
                        : const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isInfoError
                          ? const Color(0xFFC7DEFF)
                          : const Color(0xFFFFD1D1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isInfoError
                            ? Icons.info_outline_rounded
                            : Icons.error_outline_rounded,
                        color: _isInfoError
                            ? const Color(0xFF2859C5)
                            : const Color(0xFFC23C3C),
                        size: 20,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (!_showOtpField) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                autofillHints: const [AutofillHints.telephoneNumber],
                textInputAction: TextInputAction.done,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  labelText: translator.translate('auth_phone_label'),
                  prefixText: '+91  ',
                  prefixStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF14233F),
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFD),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(
                      color: Color(0xFF2859C5),
                      width: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _buildActionButton(
                label: translator.translate('auth_send_code'),
                onPressed: _isLoading ? null : _handleSendOtp,
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                autofillHints: const [AutofillHints.oneTimeCode],
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  labelText: translator.translate('auth_code_label'),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFD),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(
                      color: Color(0xFF2859C5),
                      width: 1.6,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showOtpField = false;
                      _otpController.clear();
                      _error = null;
                    });
                  },
                  child: Text(translator.translate('auth_change_number')),
                ),
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                label: translator.translate('auth_verify'),
                onPressed: _isLoading ? null : _handleVerifyOtp,
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FB),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFEBEFF5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translator.translate('auth_demo_title'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF34445F),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${translator.translate('auth_demo_resident')}  8355880200    ${translator.translate('auth_demo_guard')}  8355880201',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF687891),
                      height: 1.6,
                    ),
                  ),
                  Text(
                    '${translator.translate('auth_demo_admin')}  8355880202    ${translator.translate('auth_demo_super_admin')}  8355880203',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF687891),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2859C5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(label),
      ),
    );
  }
}
