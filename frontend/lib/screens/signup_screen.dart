import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_motion_detection_app/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/res_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  /// Xử lý sự kiện đăng ký
  void _handleSignup() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final resService = ResService();
    final response = await resService.registerUser(
      fullName: fullNameController.text.trim(),
      username: usernameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (response.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${response["error"]}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Registration successful! Please login.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    "Sign up",
                    style: GoogleFonts.acme(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: const Color.fromARGB(255, 64, 6, 156),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Create an account, It's free",
                    style: GoogleFonts.acme(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  inputFile(label: "Fullname", controller: fullNameController),
                  inputFile(label: "Username", controller: usernameController),
                  inputFile(label: "Email", controller: emailController),
                  inputFile(label: "Password", controller: passwordController, obscureText: true),
                  inputFile(label: "Confirm Password", controller: confirmPasswordController, obscureText: true),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 3, left: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: const Border(
                    bottom: BorderSide(color: Colors.blue),
                    top: BorderSide(color: Colors.blue),
                    left: BorderSide(color: Colors.blue),
                    right: BorderSide(color: Colors.blue),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: const Color(0xff0095FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Sign up",
                          style: GoogleFonts.acme(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Already have an account?",
                    style: GoogleFonts.acme(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: const Color.fromARGB(255, 18, 18, 19),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      "Login",
                      style: GoogleFonts.acme(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: const Color(0xff0095FF),
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget cho text field
Widget inputFile({
  required String label,
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
          color: const Color.fromARGB(255, 18, 18, 19),
        ),
      ),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Enter your $label",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          prefixIcon: Icon(
            label == "Email" ? Icons.email : label.contains("Password") ? Icons.lock : Icons.person,
            color: Colors.grey,
          ),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}
