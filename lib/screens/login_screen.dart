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
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    validator: (val) => val!.isEmpty ? 'E-posta adresini girin' : null,
                    onChanged: (val) => setState(() => email = val),
                    decoration: const InputDecoration(labelText: 'E-posta'),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    obscureText: true,
                    validator: (val) => val!.length < 6 ? 'Şifre 6+ karakter olmalı' : null,
                    onChanged: (val) => setState(() => password = val),
                    decoration: const InputDecoration(labelText: 'Şifre'),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Giriş'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => loading = true);
                        dynamic result = await _auth.signIn(email, password);
                        if (result == null) {
                          setState(() {
                            error = 'E-posta veya şifre hatalı';
                            loading = false;
                          });
                        } else {
                           if(mounted) {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DashboardV2()));
                           }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    textAlign: TextAlign.center,
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