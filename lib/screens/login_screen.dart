import 'package:crm/screens/dashboard_v2.dart';
import 'package:crm/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bgTop = const Color(0xFF0D47A1); // Lacivert
    final Color bgBottom = const Color(0xFF1565C0); // Mavi
    final Color cardColor = theme.colorScheme.surface;
    final Color onCard = theme.colorScheme.onSurface;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgBottom],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo / Başlık
                  Text(
                    'Nobel Vize CRM',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hesabınızla giriş yapın',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: cardColor.withOpacity(0.98),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Giriş Yap',
                              textAlign: TextAlign.left,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onCard,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              validator: (val) => val == null || val.isEmpty ? 'E-posta adresini girin' : null,
                              onChanged: (val) => setState(() => email = val),
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'E-posta',
                                hintText: 'ornek@mail.com',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              obscureText: true,
                              validator: (val) => val != null && val.length < 6 ? 'Şifre 6+ karakter olmalı' : null,
                              onChanged: (val) => setState(() => password = val),
                              decoration: const InputDecoration(
                                labelText: 'Şifre',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _showPasswordResetDialog(context),
                                child: const Text('Şifremi unuttum'),
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                icon: loading
                                    ? const SizedBox(
                                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.login),
                                label: Text(loading ? 'Giriş yapılıyor...' : 'Giriş'),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => loading = true);
                                    final result = await _auth.signIn(email.trim(), password);
                                    if (result == null) {
                                      setState(() {
                                        error = 'E-posta veya şifre hatalı';
                                        loading = false;
                                      });
                                    } else {
                                      if (mounted) {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (context) => const DashboardV2()),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ),
                            if (error.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                error,
                                style: const TextStyle(color: Colors.red, fontSize: 14.0),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Alt Bilgi
                  Text(
                    'Nobel Vize CRM',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPasswordResetDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final AuthService authService = AuthService();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Şifre Sıfırlama'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Kayıtlı E-posta Adresiniz',
              hintText: 'ornek@mail.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  try {
                    await authService.sifreSifirla(emailController.text.trim());
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Şifre sıfırlama e-postası gönderildi.'), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                     if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bir hata oluştu: ${e.toString()}'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: const Text('Gönder'),
            ),
          ],
        );
      },
    );
  }
}
