
import 'package:flutter/material.dart';

const _purple = Color(0xFF9B83D9);
const _pink = Color(0xFFE99AB7);
const _background = Color(0xFFFFF8FB);
const _text = Color(0xFF393047);
const _muted = Color(0xFF898197);

class AuthScreen extends StatefulWidget {
  final Future<bool> Function(String email, String password) onLogin;
  final Future<bool> Function(
    String name,
    String email,
    String password,
  ) onRegister;

  const AuthScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _registering = false;
  bool _hidePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      bool success;

      if (_registering) {
        success = await widget.onRegister(
          _name.text.trim(),
          _email.text.trim().toLowerCase(),
          _password.text,
        );

        if (!mounted) return;

        if (success) {
          // Chuyển về màn hình đăng nhập sau khi đăng ký thành công.
          final registeredEmail = _email.text.trim().toLowerCase();

          setState(() {
            _registering = false;
            _email.text = registeredEmail;
            _password.clear();
            _confirm.clear();
            _name.clear();
            _hidePassword = true;
          });

          _formKey.currentState?.reset();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Đăng ký thành công! Vui lòng đăng nhập.',
              ),
              backgroundColor: _purple,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email đã tồn tại hoặc đăng ký thất bại.',
              ),
            ),
          );
        }

        return;
      } else {
        success = await widget.onLogin(
          _email.text.trim().toLowerCase(),
          _password.text,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Đăng nhập thành công!'
                : 'Email hoặc mật khẩu không đúng.',
          ),
          backgroundColor: success ? _purple : Colors.redAccent,
        ),
      );

      // Khi đăng nhập thành công, AuthGate trong main.dart
      // sẽ chuyển sang màn hình chính.
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFDCE9),
                            Color(0xFFE8DFFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: _purple,
                        size: 43,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Expense Tracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _text,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _registering
                        ? 'Tạo tài khoản để bắt đầu quản lý chi tiêu'
                        : 'Chào mừng bạn quay trở lại ♡',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _muted),
                  ),
                  const SizedBox(height: 30),

                  if (_registering) ...[
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập họ tên';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                  ],

                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(email)) {
                        return 'Vui lòng nhập email hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _password,
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Mật khẩu cần ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),

                  if (_registering) ...[
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Xác nhận mật khẩu',
                        prefixIcon: Icon(Icons.lock_reset_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != _password.text) {
                          return 'Mật khẩu xác nhận không khớp';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              _registering ? 'Đăng ký' : 'Đăng nhập',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() {
                              _registering = !_registering;
                            });
                            _formKey.currentState?.reset();
                          },
                    child: Text(
                      _registering
                          ? 'Đã có tài khoản? Đăng nhập'
                          : 'Chưa có tài khoản? Đăng ký',
                      style: const TextStyle(
                        color: _purple,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thông tin tài khoản được xử lý bởi ứng dụng.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
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
}
