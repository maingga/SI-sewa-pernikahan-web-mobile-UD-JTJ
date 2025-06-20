import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:ud_joko_tarub_jingga/welcome.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: OnboardingScreen(),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Selamat Datang!",
          body: "Daftar dengan mengklik 'Sign Up' dan isi formulir. Untuk masuk, gunakan email dan password di halaman Login.",
          image: Image.asset(
            "assets/icons/login.png",
            height: 300,
          ),
          decoration: PageDecoration(
            imageAlignment: Alignment.center, // Atur posisi gambar di tengah
            contentMargin: EdgeInsets.all(16),
            imagePadding: EdgeInsets.only(top: 100), // Jarak bawah gambar
            titlePadding: EdgeInsets.only(top: 50), // Jarak bawah teks judul
            bodyPadding: EdgeInsets.only(top: 20), // Jarak bawah teks body
            titleTextStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ),
        PageViewModel(
          title: "Wedding Package",
          body: "Pilih paket pernikahan terbaikmu dengan dekorasi indah dan layanan eksklusif. Temukan momen istimewa dalam pernikahanmu.",
          image: Image.asset(
            "assets/icons/wedding.png",
            height: 300,
          ),
          decoration: PageDecoration(
            imageAlignment: Alignment.center,
            contentMargin: EdgeInsets.all(16),
            imagePadding: EdgeInsets.only(top: 100), // Jarak bawah gambar
            titlePadding: EdgeInsets.only(top: 50), // Jarak bawah teks judul
            bodyPadding: EdgeInsets.only(top: 20), // Jarak bawah teks body
            titleTextStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ),
        PageViewModel(
          title: "Payment Gateway",
          body: "Pilih Payment Gateway untuk transaksi yang nyaman. Temukan opsi pembayaran yang cocok untuk pengalaman sewa pernikahanmu.",
          image: Image.asset(
            "assets/icons/gateway.png",
            height: 300,
          ),
          decoration: PageDecoration(
            imageAlignment: Alignment.center,
            contentMargin: EdgeInsets.all(16),
            imagePadding: EdgeInsets.only(top: 100), // Jarak bawah gambar
            titlePadding: EdgeInsets.only(top: 50), // Jarak bawah teks judul
            bodyPadding: EdgeInsets.only(top: 20), // Jarak bawah teks body
            titleTextStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ),
        // Tambahkan halaman sesuai kebutuhan Anda
      ],
      onDone: () {
        // Callback ketika pengguna selesai melihat onboarding
        // Navigasi ke halaman selanjutnya, misalnya 'WelcomePage'
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomeScreen(),
          ),
        );
      },
      showSkipButton: true,
      skip: const Text("Lewati"),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Selesai"),
    );
  }
}
