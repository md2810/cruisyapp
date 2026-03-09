import 'package:flutter/material.dart';
import 'package:cruisyapp/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);

      if (authService == null) {
        setState(() {
          _errorMessage = 'Authentication services are not available. Please try again later.';
        });
        return;
      }

      if (_isSignUp) {
        await authService.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _nameController.text,
        );
      } else {
        await authService.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _errorMessage = l10n.unexpectedError;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);

      if (authService == null) {
        setState(() {
          _errorMessage = 'Google Sign-In is not available. Please try again later.';
        });
        return;
      }

      await authService.signInWithGoogle();
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _errorMessage = l10n.googleSignInFailed;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sailing_rounded,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.appTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp ? l10n.createYourAccount : l10n.welcomeBack,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_isSignUp) ...[
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: l10n.name,
                            hintText: l10n.yourName,
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                          ),
                          validator: (value) {
                            if (_isSignUp && (value == null || value.isEmpty)) {
                              return l10n.pleaseEnterName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: l10n.email,
                          hintText: l10n.emailHint,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterEmail;
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return l10n.pleaseEnterValidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          hintText: l10n.yourPassword,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterPassword;
                          }
                          if (_isSignUp && value.length < 6) {
                            return l10n.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isLoading || _isGoogleLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            _isSignUp ? l10n.createAccount : l10n.login,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // OR Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: colorScheme.outlineVariant),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.or,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: colorScheme.outlineVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading || _isGoogleLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      side: BorderSide(color: colorScheme.outline),
                    ),
                    icon: _isGoogleLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          )
                        : Image.network(
                            'https://www.google.com/favicon.ico',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.g_mobiledata_rounded,
                              size: 24,
                              color: colorScheme.onSurface,
                            ),
                          ),
                    label: Text(
                      l10n.continueWithGoogle,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp ? l10n.alreadyHaveAccount : l10n.dontHaveAccount,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        _isSignUp ? l10n.login : l10n.signUp,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}
