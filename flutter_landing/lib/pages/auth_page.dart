import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: 2, vsync: this);
  bool _loading = false;

  // Login
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  bool _loginPassVisible = false;

  // Register
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  bool _regPassVisible = false;

  @override
  void dispose() {
    _tab.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _loginEmailCtrl.text.trim();
    final pass = _loginPassCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().login(email, pass, ApiService.instance);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _showError('Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    final name = _regNameCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final pass = _regPassCtrl.text;
    final phone = _regPhoneCtrl.text.trim();
    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      _showError('Please fill in all required fields.');
      return;
    }
    setState(() => _loading = true);
    try {
      await context
          .read<AuthProvider>()
          .register(name, email, pass, phone, ApiService.instance);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _showError('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _demoLogin() async {
    setState(() => _loading = true);
    try {
      await context
          .read<AuthProvider>()
          .login('alice@example.com', 'password123', ApiService.instance);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) _showError('Demo login failed.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Logo area
                  GestureDetector(
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/', (r) => false),
                    child: Text(
                      'ShopSphere',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: AppTheme.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Luxury. Curated. UAE.',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppTheme.muted),
                  ),
                  const SizedBox(height: 32),
                  // Tab bar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.border.withValues(alpha: 0.8),
                          width: 1),
                    ),
                    child: TabBar(
                      controller: _tab,
                      indicator: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                      unselectedLabelStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.muted,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Sign In'),
                        Tab(text: 'Register'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tab views
                  SizedBox(
                    height: 380,
                    child: TabBarView(
                      controller: _tab,
                      children: [
                        _LoginForm(
                          emailCtrl: _loginEmailCtrl,
                          passCtrl: _loginPassCtrl,
                          passVisible: _loginPassVisible,
                          loading: _loading,
                          onTogglePass: () => setState(
                              () => _loginPassVisible = !_loginPassVisible),
                          onLogin: _login,
                        ),
                        _RegisterForm(
                          nameCtrl: _regNameCtrl,
                          emailCtrl: _regEmailCtrl,
                          passCtrl: _regPassCtrl,
                          phoneCtrl: _regPhoneCtrl,
                          passVisible: _regPassVisible,
                          loading: _loading,
                          onTogglePass: () => setState(
                              () => _regPassVisible = !_regPassVisible),
                          onRegister: _register,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Demo login
                  GestureDetector(
                    onTap: _loading ? null : _demoLogin,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.border.withValues(alpha: 0.7),
                            width: 1),
                      ),
                      child: Center(
                        child: Text(
                          'Demo Login (alice@example.com)',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.emailCtrl,
    required this.passCtrl,
    required this.passVisible,
    required this.loading,
    required this.onTogglePass,
    required this.onLogin,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool passVisible;
  final bool loading;
  final VoidCallback onTogglePass;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FormField(
          controller: emailCtrl,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _FormField(
          controller: passCtrl,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: !passVisible,
          suffix: IconButton(
            icon: Icon(
              passVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: AppTheme.muted,
            ),
            onPressed: onTogglePass,
          ),
        ),
        const SizedBox(height: 20),
        _SubmitButton(
          label: 'Sign In',
          loading: loading,
          onTap: onLogin,
        ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.phoneCtrl,
    required this.passVisible,
    required this.loading,
    required this.onTogglePass,
    required this.onRegister,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController phoneCtrl;
  final bool passVisible;
  final bool loading;
  final VoidCallback onTogglePass;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FormField(
          controller: nameCtrl,
          hint: 'Full name',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 10),
        _FormField(
          controller: emailCtrl,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        _FormField(
          controller: passCtrl,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: !passVisible,
          suffix: IconButton(
            icon: Icon(
              passVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: AppTheme.muted,
            ),
            onPressed: onTogglePass,
          ),
        ),
        const SizedBox(height: 10),
        _FormField(
          controller: phoneCtrl,
          hint: 'Phone (optional)',
          icon: Icons.phone_outlined,
          keyboard: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _SubmitButton(
          label: 'Create Account',
          loading: loading,
          onTap: onRegister,
        ),
      ],
    );
  }
}

class _FormField extends StatefulWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboard = TextInputType.text,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboard;
  final Widget? suffix;

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focused
              ? AppTheme.accentBlue.withValues(alpha: 0.6)
              : AppTheme.border.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscure,
          keyboardType: widget.keyboard,
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.text),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle:
                GoogleFonts.inter(fontSize: 14, color: AppTheme.muted),
            prefixIcon:
                Icon(widget.icon, size: 18, color: AppTheme.muted),
            suffixIcon: widget.suffix,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  const _SubmitButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });
  final String label;
  final bool loading;
  final VoidCallback onTap;

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.loading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _hover
                ? AppTheme.accentBlue
                : AppTheme.accentBlue.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: widget.loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : Text(
                    widget.label,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
