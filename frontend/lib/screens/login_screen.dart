import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/forgot_password_screen.dart';
import '../screens/signup_screen.dart';
import '../models/mock_data.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void _handleLogin() async {
    setState(() {
      isLoading = true; // Bắt đầu tải
    });

    await Future.delayed(const Duration(seconds: 2)); // Giả lập thời gian xử lý
    
    if (!mounted) return;
    // Tìm user trong mock data
    final user = mockUsers.firstWhere(
      (user) =>
          user['email'] == emailController.text.trim() &&
          user['password'] == passwordController.text.trim(),
      orElse: () => {},
    );

    setState(() {
      isLoading = false; // Kết thúc tải
    });

    if (user.isNotEmpty) {
      // Đăng nhập thành công
      Navigator.pushNamed(
        context,
        '/main', // Chuyển đến màn hình Dashboard
        arguments: {
          "userId": user['id'],
          "email": user['email'],
        },
      );
    } else {
      // Thông báo lỗi nếu đăng nhập thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email or password."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    "Login",
                    style: GoogleFonts.acme(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: const Color.fromARGB(255, 64, 6, 156),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Login to your account",
                    style: GoogleFonts.acme(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Column(
                children: <Widget>[
                  inputFile(
                    label: "Email",
                    icon: Icons.email,
                    controller: emailController,
                  ),
                  const SizedBox(height: 20),
                  inputFile(
                    label: "Password",
                    icon: Icons.lock,
                    controller: passwordController,
                    obscureText: true,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: const Color(0xff0095FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 5,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Login",
                        style: GoogleFonts.acme(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  "Forgot Password?",
                  style: GoogleFonts.acme(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: const Color(0xff0095FF),
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: GoogleFonts.acme(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign up",
                      style: GoogleFonts.acme(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: const Color(0xff0095FF),
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/back_ground.png"),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget cho input text với icon và controller
Widget inputFile({
  required String label,
  required IconData icon,
  required TextEditingController controller,
  bool obscureText = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: GoogleFonts.acme(
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: Colors.grey[800],
        ),
      ),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.grey,
          ),
          hintText: "Enter your $label",
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff0095FF)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ],
  );
}
