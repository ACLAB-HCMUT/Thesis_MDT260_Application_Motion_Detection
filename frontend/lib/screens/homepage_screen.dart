import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0095FF), // Màu xanh dương
                Colors.white, // Màu trắng
                Color.fromARGB(255, 27, 167, 58), // Màu xanh nhạt
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Image.asset(
                    "assets/images/logo_BK.png", // Đường dẫn tới logo của bạn
                    height: 80, // Chiều cao logo
                    width: 80, // Chiều rộng logo
                  ),
                  const SizedBox(
                      height: 20), // Khoảng cách giữa logo và chữ "Welcome"
                  Text(
                    "Welcome Back!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.acme(
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      color: const Color.fromARGB(255, 20, 163, 44),
                    ),
                  ),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage("assets/images/BG_1.jpg"),
                    fit: BoxFit
                        .cover, // Đảm bảo hình ảnh bao phủ toàn bộ container
                  ),
                  borderRadius: BorderRadius.circular(15), // Bo góc hình ảnh
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Màu bóng
                      blurRadius: 15, // Độ mờ của bóng
                      offset: const Offset(0, 15), // Độ lệch của bóng
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  // Login Button with Shadow
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // Màu bóng
                          blurRadius: 20, // Độ mờ bóng
                          offset: const Offset(0, 10), // Độ lệch bóng
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      color: const Color.fromARGB(255, 141, 165, 182),
                      shape: RoundedRectangleBorder(
                        // side: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        "Login",
                        style: GoogleFonts.acme(
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Signup Button with Shadow
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(0.4), // Màu bóng đậm hơn
                          blurRadius: 50, // Độ mờ bóng lớn hơn
                          offset: const Offset(0, 20), // Độ lệch bóng
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      color: const Color(0xff0095FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        "Sign up",
                        style: GoogleFonts.acme(
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
