import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../providers/auth_provider.dart';

enum _AuthMode { login, register }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  _AuthMode _mode = _AuthMode.login;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() => setState(() {
        _mode = _mode == _AuthMode.login ? _AuthMode.register : _AuthMode.login;
        _formKey.currentState?.reset();
      });

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (_mode == _AuthMode.login) {
      await ref.read(authNotifierProvider.notifier).signInWithEmail(
            email: email, password: password);
    } else {
      await ref.read(authNotifierProvider.notifier).signUpWithEmail(
            email: email, password: password);
    }
    if (!mounted) return;
    setState(() => _loading = false);
    _handleResult();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    _handleResult();
  }

  Future<void> _continueAnonymously() async {
    setState(() => _loading = true);
    await ref.read(authNotifierProvider.notifier).signInAnonymously();
    if (!mounted) return;
    setState(() => _loading = false);
    _handleResult();
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError('Saisissez votre email d\'abord.');
      return;
    }
    final error =
        await ref.read(authNotifierProvider.notifier).sendPasswordReset(email);
    if (!mounted) return;
    if (error != null) {
      _showError(error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de reinitialisation envoye !')),
      );
    }
  }

  void _handleResult() {
    final auth = ref.read(authNotifierProvider);
    if (auth.valueOrNull != null) {
      context.goNamed(RouteNames.splash);
    } else if (auth.hasError) {
      _showError(auth.error.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const SizedBox(height: 24),
              Image.asset(
                'assets/images/logo.jpg',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 4),
              Text(
                _mode == _AuthMode.login ? 'Connexion' : 'Creer un compte',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.lightPurple
                          : AppColors.mediumPurple,
                    ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                          context, 'Email', Icons.email_outlined),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email requis';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration(
                        context,
                        'Mot de passe',
                        Icons.lock_outlined,
                        suffix: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Mot de passe requis';
                        if (v.length < 6) return '6 caracteres minimum';
                        return null;
                      },
                    ),
                    if (_mode == _AuthMode.login) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Mot de passe oublie ?',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.lightPurple
                                  : AppColors.mediumPurple,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _submitEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: Text(
                                _mode == _AuthMode.login
                                    ? 'Se connecter'
                                    : 'Creer le compte',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: Divider(color: cs.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child:
                      Text('ou', style: TextStyle(color: cs.onSurfaceVariant)),
                ),
                Expanded(child: Divider(color: cs.outlineVariant)),
              ]),
              const SizedBox(height: 16),
              if (!_loading)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cs.outline),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 26),
                    label: const Text('Continuer avec Google'),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _mode == _AuthMode.login
                        ? 'Pas encore de compte ? '
                        : 'Deja un compte ? ',
                    style:
                        TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: _toggleMode,
                    child: Text(
                      _mode == _AuthMode.login ? 'S inscrire' : 'Se connecter',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.goldLight
                            : AppColors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loading ? null : _continueAnonymously,
                child: const Text(
                  'Continuer sans compte',
                  style: TextStyle(color: AppColors.textLight, fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : AppColors.cardBackground,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.deepPurple, width: 1.5),
      ),
    );
  }
}
