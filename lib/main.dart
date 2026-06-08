import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════
// DESIGN CONSTANTS
// ═══════════════════════════════════════════════════════

const Color kPrimary = Color(
  0xFF0F1B4E,
); // Exact Navy from transparent BUITEMS logo
const Color kPrimaryDark = Color(0xFF090F2C); // Darker shade for gradients
const Color kPrimaryLight = Color(
  0xFF223682,
); // Lighter shade for selection states
const Color kAccent = Color(
  0xFFCE6A22,
); // Warm Golden Orange from transparent BUITEMS logo
const Color kBackground = Color(0xFFF4F6FA);
const Color kSurface = Color(0xFFFFFFFF);
const Color kLostColor = Color(0xFFE53935);
const Color kFoundColor = Color(0xFF2E7D32);
const Color kClaimedColor = Color(0xFFFF8F00);
const Color kTextDark = Color(0xFF1A1A2E);
const Color kTextMid = Color(0xFF4A4A6A);
const Color kTextGrey = Color(0xFF9E9EB8);
const Color kBorder = Color(0xFFEEEEF5);
const double kRadius = 18.0;
const double kRadiusSm = 12.0;
const double kRadiusFull = 100.0;

List<BoxShadow> get kCardShadow => [
  BoxShadow(
    color: const Color(0xFF1A237E).withOpacity(0.07),
    blurRadius: 20,
    offset: const Offset(0, 6),
  ),
];

List<BoxShadow> get kDeepShadow => [
  BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 30,
    offset: const Offset(0, 10),
  ),
];

// ═══════════════════════════════════════════════════════
// ENTRY POINT
// ═══════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════
// FIREBASE SERVICES (singleton references)
// ═══════════════════════════════════════════════════════
final _auth = FirebaseAuth.instance;
final _db = FirebaseFirestore.instance;

// ── Firebase Storage image upload ──
Future<String?> _uploadToCloudinary(String filePath) async {
  try {
    final file = File(filePath);
    final ext = filePath.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final ref = FirebaseStorage.instance.ref().child('item_images/$fileName');
    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    return null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BUITEMSApp());
}

class BUITEMSApp extends StatelessWidget {
  const BUITEMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme();
    return MaterialApp(
      title: 'BUITEMS Lost & Found',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: kPrimary,
          onPrimary: Colors.white,
          secondary: kAccent,
          onSecondary: kPrimary,
          error: kLostColor,
          onError: Colors.white,
          surface: kSurface,
          onSurface: kTextDark,
        ),
        scaffoldBackgroundColor: kBackground,
        textTheme: textTheme,
        primaryTextTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadius),
            borderSide: const BorderSide(color: kBorder, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadius),
            borderSide: const BorderSide(color: kBorder, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadius),
            borderSide: const BorderSide(color: kPrimary, width: 2),
          ),
          labelStyle: GoogleFonts.poppins(color: kTextGrey, fontSize: 14),
          hintStyle: GoogleFonts.poppins(color: kTextGrey, fontSize: 14),
          prefixIconColor: kPrimaryLight,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════
// BACKGROUND PATTERN PAINTER
// ═══════════════════════════════════════════════════════

class _BgPattern extends StatelessWidget {
  const _BgPattern();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _PatternPainter(), child: const SizedBox.expand());
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.04);
    for (var i = 0; i < size.width; i += 55) {
      for (var j = 0; j < size.height; j += 55) {
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 2.5, p);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════════════════
// BUITEMS LOGO WIDGET
// ═══════════════════════════════════════════════════════

class BUITEMSLogo extends StatelessWidget {
  final double size;
  final bool light;
  const BUITEMSLogo({super.key, this.size = 80, this.light = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: kAccent, width: size * 0.035),
        boxShadow: [
          BoxShadow(
            color: kAccent.withOpacity(0.35),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(size * 0.08),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SPLASH SCREEN
// ═══════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale, _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _slide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final user = _auth.currentUser;
    final destination = user != null ? const MainScreen() : const WelcomeScreen();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => destination,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryDark, kPrimary, Color(0xFF283593)],
          ),
        ),
        child: Stack(
          children: [
            const _BgPattern(),
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: const BUITEMSLogo(size: 130),
                    ),
                    const SizedBox(height: 42),
                    AnimatedBuilder(
                      animation: _slide,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _slide.value),
                        child: child,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Lost & Found',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: kAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(kRadiusFull),
                              border: Border.all(
                                color: kAccent.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              'BUITEMS Campus Portal',
                              style: GoogleFonts.poppins(
                                color: kAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                    SizedBox(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(kRadiusFull),
                        child: const LinearProgressIndicator(
                          backgroundColor: Colors.white12,
                          color: kAccent,
                          minHeight: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Loading...',
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// WELCOME SCREEN
// ═══════════════════════════════════════════════════════

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryDark, kPrimary, Color(0xFF283593)],
          ),
        ),
        child: Stack(
          children: [
            const _BgPattern(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            const BUITEMSLogo(size: 100),
                            const SizedBox(height: 16),
                            Text(
                              'BUITEMS',
                              style: GoogleFonts.poppins(
                                color: kAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lost & Found',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Find what you\'ve lost,\nreturn what you\'ve found',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white60,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Feature pills
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _FeatChip(Icons.search_rounded, 'Find Items'),
                                  _FeatChip(
                                    Icons.add_circle_outline_rounded,
                                    'Post Items',
                                  ),
                                  _FeatChip(
                                    Icons.connect_without_contact_rounded,
                                    'Connect',
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Bottom glass card
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  kRadius * 1.5,
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.18),
                                ),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kAccent,
                                        foregroundColor: kPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            kRadiusFull,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      ),
                                      child: Text(
                                        'Login to Account',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            kRadiusFull,
                                          ),
                                        ),
                                      ),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const SignupScreen(),
                                        ),
                                      ),
                                      child: Text(
                                        'Create New Account',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Divider(color: Colors.white24),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        child: Text(
                                          'Students & Faculty only',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white38,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: Divider(color: Colors.white24),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatChip(this.icon, this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(kRadiusFull),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kAccent, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// LOGIN SCREEN
// ═══════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter email and password', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: kLostColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
      // Create Firestore doc if missing (for old accounts)
      final uid = cred.user!.uid;
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) {
        await _db.collection('users').doc(uid).set({
          'userId': uid,
          'name': cred.user!.displayName ?? email.split('@').first,
          'email': email,
          'phoneNumber': '',
          'department': '',
          'semester': '',
          'role': 'Student',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      String msg = 'Login failed. Please try again.';
      if (e.code == 'user-not-found') msg = 'No account found with this email.';
      if (e.code == 'wrong-password') msg = 'Incorrect password.';
      if (e.code == 'invalid-email') msg = 'Invalid email format.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: kLostColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryDark, kPrimary],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const BUITEMSLogo(size: 90),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Login to BUITEMS Lost & Found',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 36),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(kRadius * 1.5),
                    boxShadow: kDeepShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('Email Address'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'example@buitems.edu.pk',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Label('Password'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: kTextGrey,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              color: kPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kRadiusFull),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: GoogleFonts.poppins(
                                color: kTextGrey,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: GoogleFonts.poppins(
                                    color: kPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SIGNUP SCREEN
// ═══════════════════════════════════════════════════════

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true, _loading = false;
  String _userType = 'Student';
  String _dept = 'Software Engineering';
  String _semester = '1st Semester';

  final _depts = const [
    'Software Engineering',
    'Computer Science',
    'Information Technology',
    'Electrical Engineering',
    'Civil Engineering',
    'Mechanical Engineering',
    'Business Administration',
    'English',
    'Mathematics',
  ];
  final _semesters = const [
    '1st Semester',
    '2nd Semester',
    '3rd Semester',
    '4th Semester',
    '5th Semester',
    '6th Semester',
    '7th Semester',
    '8th Semester',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _signup() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (name.isEmpty || email.isEmpty || phone.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: kLostColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        ),
      );
      return;
    }
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 6 characters', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: kLostColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      await cred.user!.updateDisplayName(name);
      await _db.collection('users').doc(cred.user!.uid).set({
        'userId': cred.user!.uid,
        'name': name,
        'email': email,
        'phoneNumber': phone,
        'department': _dept,
        'semester': _semester,
        'role': _userType,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      String msg = 'Signup failed. Please try again.';
      if (e.code == 'email-already-in-use') msg = 'This email is already registered.';
      if (e.code == 'invalid-email') msg = 'Invalid email format.';
      if (e.code == 'weak-password') msg = 'Password is too weak.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: kLostColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryDark, kPrimary],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const BUITEMSLogo(size: 80),
                const SizedBox(height: 16),
                Text(
                  'Create Account',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Join BUITEMS Lost & Found System',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 44),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(kRadius * 1.5),
                    boxShadow: kDeepShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('I am a'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: kBackground,
                          borderRadius: BorderRadius.circular(kRadius),
                        ),
                        child: Row(
                          children: ['Student', 'Faculty'].map((type) {
                            final sel = _userType == type;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _userType = type),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sel ? kPrimary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                      kRadiusSm,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        type == 'Student'
                                            ? Icons.school_rounded
                                            : Icons.badge_rounded,
                                        color: sel ? Colors.white : kTextGrey,
                                        size: 17,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        type,
                                        style: GoogleFonts.poppins(
                                          color: sel ? Colors.white : kTextGrey,
                                          fontWeight: sel
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Label('Full Name'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameCtrl,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Enter your full name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _Label('Email Address'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'your@buitems.edu.pk',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _Label('Phone Number'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: '03XX-XXXXXXX',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _Label('Department'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _dept,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: kTextDark,
                        ),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.account_balance_outlined),
                        ),
                        borderRadius: BorderRadius.circular(kRadius),
                        items: _depts
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d,
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _dept = v!),
                      ),
                      if (_userType == 'Student') ...[
                        const SizedBox(height: 16),
                        _Label('Semester'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _semester,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: kTextDark,
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.class_outlined),
                          ),
                          borderRadius: BorderRadius.circular(kRadius),
                          items: _semesters
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _semester = v!),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _Label('Password'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Create a strong password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: kTextGrey,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kRadiusFull),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Create Account',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: GoogleFonts.poppins(
                                color: kTextGrey,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: GoogleFonts.poppins(
                                    color: kPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SHARED LABEL WIDGET
// ═══════════════════════════════════════════════════════

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: kTextMid,
    ),
  );
}

// ═══════════════════════════════════════════════════════
// MAIN SCREEN + BOTTOM NAV
// ═══════════════════════════════════════════════════════

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;
  String _browseSubTab = 'Lost';

  void _onTap(int i) {
    setState(() => _idx = i);
  }

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: kSurface,
      builder: (_) => _AddSelector(
        onSelect: (type) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddItemScreen(type: type)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(
        onNavigate: (index, subTab) {
          setState(() {
            _idx = index;
            if (subTab != null) {
              _browseSubTab = subTab;
            }
          });
        },
      ),
      BrowseTab(initialTab: _browseSubTab),
      const SearchScreen(),
      const ProfileTab(),
    ];
    return Scaffold(
      body: IndexedStack(index: _idx, children: tabs),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddModal,
        backgroundColor: kPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusFull),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(current: _idx, onTap: _onTap),
    );
  }
}

class _AddSelector extends StatelessWidget {
  final void Function(String) onSelect;
  const _AddSelector({required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 44),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kBorder,
              borderRadius: BorderRadius.circular(kRadiusFull),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Post an Item',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'What do you want to post?',
            style: GoogleFonts.poppins(color: kTextGrey, fontSize: 13),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _TypeCard(
                  icon: Icons.search_off_rounded,
                  label: 'Lost Item',
                  sub: 'I lost something',
                  color: kLostColor,
                  onTap: () => onSelect('Lost'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _TypeCard(
                  icon: Icons.inventory_2_rounded,
                  label: 'Found Item',
                  sub: 'I found something',
                  color: kFoundColor,
                  onTap: () => onSelect('Found'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback onTap;
  const _TypeCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(kRadius),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: GoogleFonts.poppins(fontSize: 12, color: kTextGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current;
  final void Function(int) onTap;
  const _BottomNav({required this.current, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      elevation: 14,
      color: kSurface,
      surfaceTintColor: kSurface,
      child: SizedBox(
        height: 62,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              idx: 0,
              cur: current,
              onTap: onTap,
            ),
            _NavItem(
              icon: Icons.layers_rounded,
              label: 'Browse',
              idx: 1,
              cur: current,
              onTap: onTap,
            ),
            const SizedBox(width: 40),
            _NavItem(
              icon: Icons.search_rounded,
              label: 'Search',
              idx: 2,
              cur: current,
              onTap: onTap,
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              idx: 3,
              cur: current,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int idx, cur;
  final void Function(int) onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.idx,
    required this.cur,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final sel = idx == cur;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(idx),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? kPrimary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(kRadiusFull),
              ),
              child: Icon(icon, color: sel ? kPrimary : kTextGrey, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? kPrimary : kTextGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ITEM DATA
// ═══════════════════════════════════════════════════════

// kAllItems removed — data now comes from Firestore in real time.
// Kept as empty list for any legacy widget references.
const List<Map<String, String>> kAllItems = [];

// ═══════════════════════════════════════════════════════
// ITEM CARD WIDGET
// ═══════════════════════════════════════════════════════

class ItemCard extends StatelessWidget {
  final Map<String, String> item;
  final VoidCallback onTap;
  const ItemCard({super.key, required this.item, required this.onTap});

  Color get _typeColor => item['type'] == 'Lost' ? kLostColor : kFoundColor;
  IconData get _typeIcon => item['type'] == 'Lost'
      ? Icons.search_off_rounded
      : Icons.inventory_2_rounded;
  Color get _statusColor {
    switch (item['status']) {
      case 'Active':
        return kFoundColor;
      case 'Claimed':
        return kClaimedColor;
      case 'Returned':
        return kPrimaryLight;
      default:
        return kTextGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(kRadius),
          boxShadow: kCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image display if available
            if ((item['imageUrl'] ?? '').isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(kRadius),
                  topRight: Radius.circular(kRadius),
                ),
                child: Image.network(
                  item['imageUrl']!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          height: 160,
                          color: kBorder,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: kBorder,
                    child: const Icon(Icons.broken_image_rounded, color: kTextGrey, size: 40),
                  ),
                ),
              ),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: _typeColor,
                borderRadius: (item['imageUrl'] ?? '').isNotEmpty
                    ? BorderRadius.zero
                    : const BorderRadius.only(
                        topLeft: Radius.circular(kRadius),
                        topRight: Radius.circular(kRadius),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(kRadiusSm),
                    ),
                    child: Icon(_typeIcon, color: _typeColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['title'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: kTextDark,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  kRadiusFull,
                                ),
                                border: Border.all(
                                  color: _statusColor.withOpacity(0.35),
                                ),
                              ),
                              child: Text(
                                item['status'] ?? '',
                                style: GoogleFonts.poppins(
                                  color: _statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 12,
                              color: kTextGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['category'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: kTextGrey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: kTextGrey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item['location'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: kTextGrey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: kTextGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['date'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: kTextGrey,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _typeColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(
                                  kRadiusFull,
                                ),
                              ),
                              child: Text(
                                item['type'] == 'Lost' ? '🔴 Lost' : '🟢 Found',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _typeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HOME TAB
// ═══════════════════════════════════════════════════════

class HomeTab extends StatelessWidget {
  final void Function(int index, String? subTab)? onNavigate;
  const HomeTab({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            floating: false,
            automaticallyImplyLeading: false,
            backgroundColor: kPrimary,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimaryDark, kPrimary, Color(0xFF283593)],
                  ),
                ),
                child: Stack(
                  children: [
                    const _BgPattern(),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const BUITEMSLogo(size: 44),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'BUITEMS',
                                      style: GoogleFonts.poppins(
                                        color: kAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    Text(
                                      'Lost & Found',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Good Day,',
                              style: GoogleFonts.poppins(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${_auth.currentUser?.displayName ?? _auth.currentUser?.email?.split('@').first ?? 'Student'} 👋',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats from Firestore
                  StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('items').snapshots(),
                    builder: (context, snap) {
                      final docs = snap.data?.docs ?? [];
                      final lost = docs.where((d) => (d.data() as Map)['type'] == 'Lost').length.toString();
                      final found = docs.where((d) => (d.data() as Map)['type'] == 'Found').length.toString();
                      final returned = docs.where((d) => (d.data() as Map)['status'] == 'Returned').length.toString();
                      return Row(
                        children: [
                          _StatCard(label: 'Lost', value: lost, icon: Icons.search_off_rounded, color: kLostColor),
                          const SizedBox(width: 12),
                          _StatCard(label: 'Found', value: found, icon: Icons.inventory_2_rounded, color: kFoundColor),
                          const SizedBox(width: 12),
                          _StatCard(label: 'Returned', value: returned, icon: Icons.check_circle_rounded, color: kPrimaryLight),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  // Quick actions
                  _SecHeader(title: 'Quick Actions'),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 108,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _QuickAction(
                    icon: Icons.search_off_rounded,
                    label: 'Lost\nItems',
                    color: kLostColor,
                    onTap: () => onNavigate?.call(1, 'Lost'),
                  ),
                  _QuickAction(
                    icon: Icons.inventory_2_rounded,
                    label: 'Found\nItems',
                    color: kFoundColor,
                    onTap: () => onNavigate?.call(1, 'Found'),
                  ),
                  _QuickAction(
                    icon: Icons.add_circle_rounded,
                    label: 'Post\nLost',
                    color: const Color(0xFFFF6F00),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddItemScreen(type: 'Lost'),
                      ),
                    ),
                  ),
                  _QuickAction(
                    icon: Icons.add_box_rounded,
                    label: 'Post\nFound',
                    color: const Color(0xFF00897B),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddItemScreen(type: 'Found'),
                      ),
                    ),
                  ),
                  _QuickAction(
                    icon: Icons.article_rounded,
                    label: 'My\nPosts',
                    color: kPrimaryLight,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyPostsScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
              child: _SecHeader(
                title: 'Recent Items',
                actionLabel: 'See All',
                onAction: () {},
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _db
                .collection('items')
                .orderBy('createdAt', descending: true)
                .limit(4)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  )),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No items yet. Be the first to post!',
                        style: GoogleFonts.poppins(color: kTextGrey, fontSize: 14),
                      ),
                    ),
                  ),
                );
              }
              final docs = snapshot.data!.docs;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final item = _docToMap(docs[i].id, d);
                    return Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, i == docs.length - 1 ? 100 : 12),
                      child: ItemCard(
                        item: item,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
                        ),
                      ),
                    );
                  },
                  childCount: docs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(kRadius),
          boxShadow: kCardShadow,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kTextDark,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: kTextGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(kRadius),
          boxShadow: kCardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(kRadiusSm),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: kTextDark,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SecHeader({required this.title, this.actionLabel, this.onAction});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: kTextDark,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// BROWSE TAB
// ═══════════════════════════════════════════════════════

class BrowseTab extends StatefulWidget {
  final String initialTab;
  const BrowseTab({super.key, this.initialTab = 'Lost'});
  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _cat = 'All';
  static const _cats = [
    'All',
    'ID Card',
    'Wallet',
    'Keys',
    'Books',
    'Electronics',
    'Bag',
    'Other',
  ];

  Stream<QuerySnapshot> _stream(String type) {
    Query q = _db.collection('items').where('type', isEqualTo: type);
    if (_cat != 'All') q = q.where('category', isEqualTo: _cat);
    return q.snapshots();
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.index = widget.initialTab == 'Lost' ? 0 : 1;
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(BrowseTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      _tabCtrl.animateTo(widget.initialTab == 'Lost' ? 0 : 1);
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Browse Items',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: kAccent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded, size: 16),
                  const SizedBox(width: 6),
                  StreamBuilder<QuerySnapshot>(
                    stream: _stream('Lost'),
                    builder: (_, s) => Text('Lost (${s.data?.docs.length ?? 0})'),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_rounded, size: 16),
                  const SizedBox(width: 6),
                  StreamBuilder<QuerySnapshot>(
                    stream: _stream('Found'),
                    builder: (_, s) => Text('Found (${s.data?.docs.length ?? 0})'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: kSurface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _cats.length,
                itemBuilder: (_, i) {
                  final c = _cats[i];
                  final sel = _cat == c;
                  return GestureDetector(
                    onTap: () => setState(() => _cat = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? kPrimary : kBackground,
                        borderRadius: BorderRadius.circular(kRadiusFull),
                        border: Border.all(
                          color: sel ? kPrimary : kBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        c,
                        style: GoogleFonts.poppins(
                          color: sel ? Colors.white : kTextGrey,
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _FirestoreItemList(stream: _stream('Lost')),
                _FirestoreItemList(stream: _stream('Found')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  final List<Map<String, String>> items;
  const _ItemList({required this.items});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// Firestore-driven list widget
class _FirestoreItemList extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  const _FirestoreItemList({required this.stream});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 64, color: kTextGrey.withOpacity(0.4)),
                const SizedBox(height: 12),
                Text('No items found', style: GoogleFonts.poppins(color: kTextGrey, fontSize: 15, fontWeight: FontWeight.w500)),
                Text('Try a different category', style: GoogleFonts.poppins(color: kTextGrey, fontSize: 13)),
              ],
            ),
          );
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final item = _docToMap(docs[i].id, d);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ItemCard(
                item: item,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Helper: convert Firestore doc to Map<String,String> for existing UI widgets
Map<String, String> _docToMap(String id, Map<String, dynamic> d) {
  final ts = d['createdAt'];
  String dateStr = '';
  if (ts is Timestamp) {
    final dt = ts.toDate();
    dateStr = '${dt.day.toString().padLeft(2,'0')} ${_monthName(dt.month)} ${dt.year}';
  }
  return {
    'itemId': id,
    'title': d['title'] ?? '',
    'category': d['category'] ?? '',
    'location': d['location'] ?? '',
    'status': d['status'] ?? 'Active',
    'type': d['type'] ?? '',
    'contact': d['contactInfo'] ?? '',
    'date': dateStr,
    'by': d['postedByName'] ?? '',
    'description': d['description'] ?? '',
    'imageUrl': d['imageUrl'] ?? '',
    'postedByUid': d['postedBy'] ?? '',
  };
}

String _monthName(int m) => const ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];



// ═══════════════════════════════════════════════════════
// ADD ITEM SCREEN
// ═══════════════════════════════════════════════════════

class AddItemScreen extends StatefulWidget {
  final String type;
  const AddItemScreen({super.key, required this.type});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  String _category = 'ID Card';
  bool _loading = false;
  String? _imagePath;
  static const _cats = [
    'ID Card',
    'Wallet',
    'Keys',
    'Books',
    'Electronics',
    'Calculator',
    'USB Drive',
    'Bag',
    'Stationery',
    'Clothing',
    'Other',
  ];

  Color get _color => widget.type == 'Lost' ? kLostColor : kFoundColor;
  IconData get _icon => widget.type == 'Lost'
      ? Icons.search_off_rounded
      : Icons.inventory_2_rounded;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  void _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: kSurface,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(kRadiusFull),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Photo Select Karo',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Gallery ya Camera se photo lo',
              style: GoogleFonts.poppins(fontSize: 13, color: kTextGrey),
            ),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRadius),
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kRadiusSm),
                ),
                child: const Icon(Icons.photo_library_rounded, color: kPrimary),
              ),
              title: Text(
                'Gallery se chuno',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
              ),
              subtitle: Text(
                'Phone ki gallery khulegi',
                style: GoogleFonts.poppins(fontSize: 12, color: kTextGrey),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: kTextGrey,
              ),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                );
                if (picked != null) setState(() => _imagePath = picked.path);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRadius),
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kFoundColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kRadiusSm),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: kFoundColor),
              ),
              title: Text(
                'Camera se kheencho',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
              ),
              subtitle: Text(
                'Camera khul jaega',
                style: GoogleFonts.poppins(fontSize: 12, color: kTextGrey),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: kTextGrey,
              ),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final picked = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                );
                if (picked != null) setState(() => _imagePath = picked.path);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill title & location!', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: kLostColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      // Upload image to Cloudinary if selected
      String imageUrl = '';
      if (_imagePath != null) {
        final url = await _uploadToCloudinary(_imagePath!);
        imageUrl = url ?? '';
      }

      // Fetch user name from Firestore
      String userName = user.email ?? 'Unknown';
      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (userDoc.exists) userName = userDoc.data()?['name'] ?? userName;

      // Save item to Firestore
      await _db.collection('items').add({
        'title': _titleCtrl.text.trim(),
        'type': widget.type,
        'category': _category,
        'description': _descCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'date': DateTime.now().toIso8601String(),
        'imageUrl': imageUrl,
        'postedBy': user.uid,
        'postedByName': userName,
        'contactInfo': _contactCtrl.text.trim().isEmpty ? (user.email ?? '') : _contactCtrl.text.trim(),
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text('${widget.type} item posted!', style: GoogleFonts.poppins(fontSize: 13)),
          ]),
          backgroundColor: kFoundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: kLostColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: _color,
        title: Text(
          'Post ${widget.type} Item',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_color, _color.withOpacity(0.75)],
                ),
                borderRadius: BorderRadius.circular(kRadius),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(kRadiusSm),
                    ),
                    child: Icon(_icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Post a ${widget.type} Item',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.type == 'Lost'
                              ? 'Help others find your item'
                              : 'Help return it to the owner',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(kRadius),
                boxShadow: kCardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label('Item Title *'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'e.g., Blue Student ID Card',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Label('Category *'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _category,
                    style: GoogleFonts.poppins(fontSize: 14, color: kTextDark),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    borderRadius: BorderRadius.circular(kRadius),
                    items: _cats
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 18),
                  _Label('Description'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 4,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Color, brand, any markings...',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: Icon(
                          Icons.description_rounded,
                          color: kPrimaryLight,
                        ),
                      ),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Label('Location on Campus *'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationCtrl,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'e.g., CS Dept, Library, Lab 3',
                      prefixIcon: Icon(Icons.location_on_rounded),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Label('Contact Number'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contactCtrl,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: '03XX-XXXXXXX',
                      prefixIcon: Icon(Icons.phone_rounded),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Label('Item Photo (Optional)'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      height: _imagePath != null ? 200 : 130,
                      decoration: BoxDecoration(
                        color: _imagePath != null
                            ? Colors.transparent
                            : _color.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(kRadius),
                        border: Border.all(
                          color: _imagePath != null ? _color : kBorder,
                          width: _imagePath != null ? 2 : 1.5,
                        ),
                      ),
                      child: _imagePath != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    kRadius - 2,
                                  ),
                                  child: Image.file(
                                    File(_imagePath!),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _imagePath = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.55),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.55),
                                        borderRadius: BorderRadius.circular(
                                          kRadiusFull,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.edit_rounded,
                                            color: Colors.white,
                                            size: 13,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Change',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: _color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add_a_photo_rounded,
                                    color: _color,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Tap to add photo',
                                  style: GoogleFonts.poppins(
                                    color: kTextMid,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Gallery or Camera',
                                  style: GoogleFonts.poppins(
                                    color: kTextGrey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kRadiusFull),
                        ),
                      ),
                      icon: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white),
                      label: Text(
                        _loading ? 'Posting...' : 'Post ${widget.type} Item',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ITEM DETAIL SCREEN
// ═══════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════
// ITEM DETAIL SCREEN (fully functional)
// ═══════════════════════════════════════════════════════

class ItemDetailScreen extends StatefulWidget {
  final Map<String, String> item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Map<String, String> _item;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _item = Map.from(widget.item);
  }

  Color get _tc => _item['type'] == 'Lost' ? kLostColor : kFoundColor;
  Color get _sc {
    switch (_item['status']) {
      case 'Active':
        return kFoundColor;
      case 'Claimed':
        return kClaimedColor;
      case 'Returned':
        return kPrimaryLight;
      default:
        return kTextGrey;
    }
  }

  bool get _isOwner => _auth.currentUser?.uid != null &&
      (_item['postedByUid'] == _auth.currentUser!.uid ||
          _item['by'] == (_auth.currentUser?.displayName ?? ''));

  // ── Contact: show call / WhatsApp / email options ──
  void _showContactOptions() {
    final contact = _item['contact'] ?? '';
    if (contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No contact info provided', style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: kLostColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
      ));
      return;
    }
    // Determine if it looks like a phone number or email
    final isPhone = RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(contact.trim());
    final isEmail = contact.contains('@');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: kSurface,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(kRadiusFull)),
            ),
            const SizedBox(height: 20),
            Text('Contact Person', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: kTextDark)),
            const SizedBox(height: 4),
            Text(contact, style: GoogleFonts.poppins(fontSize: 13, color: kTextGrey)),
            const SizedBox(height: 20),
            if (isPhone || !isEmail) ...[
              _ContactTile(
                icon: Icons.call_rounded,
                color: kFoundColor,
                title: 'Call',
                subtitle: 'Direct phone call',
                onTap: () async {
                  Navigator.pop(context);
                  final uri = Uri(scheme: 'tel', path: contact.trim());
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
              const SizedBox(height: 8),
              _ContactTile(
                icon: Icons.chat_rounded,
                color: const Color(0xFF25D366),
                title: 'WhatsApp',
                subtitle: 'Chat on WhatsApp',
                onTap: () async {
                  Navigator.pop(context);
                  final num = contact.trim().replaceAll(RegExp(r'[^\d]'), '');
                  final uri = Uri.parse('https://wa.me/$num');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
            if (isEmail) ...[
              const SizedBox(height: 8),
              _ContactTile(
                icon: Icons.email_rounded,
                color: kPrimaryLight,
                title: 'Send Email',
                subtitle: 'Open email app',
                onTap: () async {
                  Navigator.pop(context);
                  final uri = Uri(scheme: 'mailto', path: contact.trim(),
                    queryParameters: {'subject': 'Regarding your ${_item['type']} item: ${_item['title']}'},
                  );
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
            ],
            if (!isEmail && (isPhone || true)) ...[
              const SizedBox(height: 8),
              _ContactTile(
                icon: Icons.email_rounded,
                color: kPrimaryLight,
                title: 'Send Email',
                subtitle: 'If contact is an email',
                onTap: () async {
                  Navigator.pop(context);
                  final uri = Uri(scheme: 'mailto', path: contact.trim(),
                    queryParameters: {'subject': 'Regarding your ${_item['type']} item: ${_item['title']}'},
                  );
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Share ──
  void _shareItem() {
    final text = '🔍 ${_item['type']} Item: ${_item['title']}\n'
        '📍 Location: ${_item['location'] ?? '-'}\n'
        '📂 Category: ${_item['category'] ?? '-'}\n'
        '📅 Date: ${_item['date'] ?? '-'}\n'
        '📞 Contact: ${_item['contact'] ?? '-'}\n\n'
        'BUITEMS Campus Lost & Found App';
    Share.share(text, subject: '${_item['type']} Item: ${_item['title']}');
  }

  // ── Mark as Found / Returned (from item detail) ──
  void _markStatus() async {
    final itemId = _item['itemId'];
    if (itemId == null || itemId.isEmpty) return;
    final newStatus = _item['type'] == 'Lost' ? 'Claimed' : 'Returned';
    setState(() => _updating = true);
    try {
      await _db.collection('items').doc(itemId).update({'status': newStatus});
      setState(() {
        _item = Map.from(_item)..[('status')] = newStatus;
        _updating = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white),
          const SizedBox(width: 8),
          Text('Status updated to $newStatus!', style: GoogleFonts.poppins(fontSize: 13)),
        ]),
        backgroundColor: kFoundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
      ));
    } catch (e) {
      setState(() => _updating = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Update failed: $e', style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: kLostColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
      ));
    }
  }

  // ── Status Change dropdown (owner only) ──
  void _showStatusPicker() {
    const statuses = ['Active', 'Claimed', 'Returned'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: kSurface,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(kRadiusFull)),
            ),
            const SizedBox(height: 20),
            Text('Update Status', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: kTextDark)),
            const SizedBox(height: 16),
            ...statuses.map((s) {
              Color sc;
              IconData ic;
              switch (s) {
                case 'Active': sc = kFoundColor; ic = Icons.radio_button_checked_rounded; break;
                case 'Claimed': sc = kClaimedColor; ic = Icons.handshake_rounded; break;
                default: sc = kPrimaryLight; ic = Icons.check_circle_rounded;
              }
              final isCurrent = _item['status'] == s;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? sc.withOpacity(0.08) : kBackground,
                  borderRadius: BorderRadius.circular(kRadius),
                  border: Border.all(color: isCurrent ? sc : kBorder, width: isCurrent ? 1.5 : 1),
                ),
                child: ListTile(
                  leading: Icon(ic, color: sc),
                  title: Text(s, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: kTextDark)),
                  trailing: isCurrent ? Icon(Icons.check_rounded, color: sc) : null,
                  onTap: () async {
                    Navigator.pop(context);
                    if (isCurrent) return;
                    final itemId = _item['itemId'];
                    if (itemId == null || itemId.isEmpty) return;
                    setState(() => _updating = true);
                    try {
                      await _db.collection('items').doc(itemId).update({'status': s});
                      setState(() {
                        _item = Map.from(_item)..['status'] = s;
                        _updating = false;
                      });
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Row(children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Status updated to $s!', style: GoogleFonts.poppins(fontSize: 13)),
                        ]),
                        backgroundColor: kFoundColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
                      ));
                    } catch (e) {
                      setState(() => _updating = false);
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _auth.currentUser?.uid ?? '';
    final isOwner = _item['postedByUid'] == currentUid;

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: (_item['imageUrl'] ?? '').isNotEmpty ? 280 : 230,
            pinned: true,
            backgroundColor: _tc,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              if (isOwner)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditPostScreen(item: _item)),
                      ).then((updated) {
                        if (updated != null && updated is Map<String, String>) {
                          setState(() => _item = updated);
                        }
                      }),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: (_item['imageUrl'] ?? '').isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _item['imageUrl']!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: _tc),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, _tc.withOpacity(0.7)],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(kRadiusFull),
                            ),
                            child: Text(
                              '${_item['type']} Item',
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_tc, _tc.withOpacity(0.72)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _item['type'] == 'Lost' ? Icons.search_off_rounded : Icons.inventory_2_rounded,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(kRadiusFull),
                      ),
                      child: Text(
                        '${_item['type']} Item',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _item['title'] ?? '',
                          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: kTextDark),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: isOwner ? _showStatusPicker : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _sc.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(kRadiusFull),
                            border: Border.all(color: _sc.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _item['status'] ?? '',
                                style: GoogleFonts.poppins(color: _sc, fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                              if (isOwner) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.expand_more_rounded, color: _sc, size: 14),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Posted by ${_item['by'] ?? 'Unknown'}',
                    style: GoogleFonts.poppins(color: kTextGrey, fontSize: 13),
                  ),
                  if (_item['description'] != null && _item['description']!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(kRadius),
                        boxShadow: kCardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description', style: GoogleFonts.poppins(color: kTextGrey, fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(_item['description']!, style: GoogleFonts.poppins(color: kTextDark, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Container(
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(kRadius),
                      boxShadow: kCardShadow,
                    ),
                    child: Column(
                      children: [
                        _DRow(icon: Icons.category_rounded, ic: kPrimaryLight, label: 'Category', value: _item['category'] ?? '-'),
                        const Divider(height: 1, indent: 60, color: kBorder),
                        _DRow(icon: Icons.location_on_rounded, ic: kLostColor, label: 'Location', value: _item['location'] ?? '-'),
                        const Divider(height: 1, indent: 60, color: kBorder),
                        _DRow(icon: Icons.calendar_today_rounded, ic: kClaimedColor, label: 'Date Reported', value: _item['date'] ?? '-'),
                        const Divider(height: 1, indent: 60, color: kBorder),
                        _DRow(icon: Icons.phone_rounded, ic: kFoundColor, label: 'Contact', value: _item['contact'] ?? '-', isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _shareItem,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kPrimary,
                              side: const BorderSide(color: kPrimary, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusFull)),
                            ),
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: Text('Share', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: kPrimary)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _showContactOptions,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kFoundColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusFull)),
                            ),
                            icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
                            label: Text('Contact Person', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_item['status'] != 'Returned')
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _updating ? null : _markStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusFull)),
                        ),
                        icon: _updating
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                        label: Text(
                          _updating ? 'Updating...' : 'Mark as ${_item['type'] == 'Lost' ? 'Claimed' : 'Returned'}',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                  if (isOwner) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _showStatusPicker,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kAccent,
                          side: const BorderSide(color: kAccent, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusFull)),
                        ),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        label: Text('Change Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: kAccent)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper tile for contact options bottom sheet
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final VoidCallback onTap;
  const _ContactTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
      tileColor: color.withOpacity(0.06),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(kRadiusSm)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: kTextDark)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: kTextGrey)),
      trailing: const Icon(Icons.chevron_right_rounded, color: kTextGrey),
      onTap: onTap,
    );
  }
}

class _DRow extends StatelessWidget {
  final IconData icon;
  final Color ic;
  final String label, value;
  final bool isLast;
  const _DRow({
    required this.icon,
    required this.ic,
    required this.label,
    required this.value,
    this.isLast = false,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ic.withOpacity(0.1),
              borderRadius: BorderRadius.circular(kRadiusSm),
            ),
            child: Icon(icon, color: ic, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: kTextGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: kTextDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// EDIT POST SCREEN
// ═══════════════════════════════════════════════════════

class EditPostScreen extends StatefulWidget {
  final Map<String, String> item;
  const EditPostScreen({super.key, required this.item});
  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _contactCtrl;
  late String _category;
  bool _loading = false;

  static const _cats = [
    'ID Card', 'Wallet', 'Keys', 'Books', 'Electronics',
    'Calculator', 'USB Drive', 'Bag', 'Stationery', 'Clothing', 'Other',
  ];

  Color get _color => widget.item['type'] == 'Lost' ? kLostColor : kFoundColor;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item['title'] ?? '');
    _descCtrl = TextEditingController(text: widget.item['description'] ?? '');
    _locationCtrl = TextEditingController(text: widget.item['location'] ?? '');
    _contactCtrl = TextEditingController(text: widget.item['contact'] ?? '');
    final cat = widget.item['category'] ?? 'Other';
    _category = _cats.contains(cat) ? cat : 'Other';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (_titleCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Title and Location required!', style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: kLostColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
      ));
      return;
    }
    final itemId = widget.item['itemId'];
    if (itemId == null || itemId.isEmpty) return;
    setState(() => _loading = true);
    try {
      await _db.collection('items').doc(itemId).update({
        'title': _titleCtrl.text.trim(),
        'category': _category,
        'description': _descCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'contactInfo': _contactCtrl.text.trim(),
      });
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white),
          const SizedBox(width: 8),
          Text('Post updated!', style: GoogleFonts.poppins(fontSize: 13)),
        ]),
        backgroundColor: kFoundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
      ));
      // Return updated item map to caller
      final updated = Map<String, String>.from(widget.item)
        ..['title'] = _titleCtrl.text.trim()
        ..['category'] = _category
        ..['description'] = _descCtrl.text.trim()
        ..['location'] = _locationCtrl.text.trim()
        ..['contact'] = _contactCtrl.text.trim();
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e', style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: kLostColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: _color,
        title: Text('Edit Post', style: GoogleFonts.poppins(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: Text('Save', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(kRadius), boxShadow: kCardShadow),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('Item Title *'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: const InputDecoration(hintText: 'e.g., Blue Student ID Card', prefixIcon: Icon(Icons.title_rounded)),
              ),
              const SizedBox(height: 18),
              _Label('Category *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                style: GoogleFonts.poppins(fontSize: 14, color: kTextDark),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category_rounded)),
                borderRadius: BorderRadius.circular(kRadius),
                items: _cats.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 18),
              _Label('Description'),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                maxLines: 4,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Color, brand, any markings...',
                  prefixIcon: Padding(padding: const EdgeInsets.only(bottom: 60), child: Icon(Icons.description_rounded, color: kPrimaryLight)),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 18),
              _Label('Location on Campus *'),
              const SizedBox(height: 8),
              TextField(
                controller: _locationCtrl,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: const InputDecoration(hintText: 'e.g., CS Dept, Library, Lab 3', prefixIcon: Icon(Icons.location_on_rounded)),
              ),
              const SizedBox(height: 18),
              _Label('Contact Number'),
              const SizedBox(height: 8),
              TextField(
                controller: _contactCtrl,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: const InputDecoration(hintText: '03XX-XXXXXXX', prefixIcon: Icon(Icons.phone_rounded)),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusFull)),
                  ),
                  icon: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_rounded, color: Colors.white),
                  label: Text(
                    _loading ? 'Saving...' : 'Save Changes',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
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

// ═══════════════════════════════════════════════════════
// SEARCH SCREEN
// ═══════════════════════════════════════════════════════

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _q = '', _filter = 'All';
  static const _filters = ['All', 'Lost', 'Found'];

  // All items are fetched from Firestore; filtering/searching done client-side
  Stream<QuerySnapshot> get _stream => _db.collection('items').snapshots();

  List<Map<String, String>> _applyFilter(List<QueryDocumentSnapshot> docs) {
    return docs
        .where((doc) {
          final d = doc.data() as Map<String, dynamic>;
          final title = (d['title'] ?? '').toString().toLowerCase();
          final cat = (d['category'] ?? '').toString().toLowerCase();
          final loc = (d['location'] ?? '').toString().toLowerCase();
          final type = (d['type'] ?? '').toString();
          final q = _q.toLowerCase();
          final matchQ = _q.isEmpty || title.contains(q) || cat.contains(q) || loc.contains(q);
          final matchF = _filter == 'All' || type == _filter;
          return matchQ && matchF;
        })
        .map((doc) => _docToMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Search', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: TextField(
              autofocus: false,
              controller: _ctrl,
              onChanged: (v) => setState(() => _q = v),
              style: GoogleFonts.poppins(fontSize: 14, color: kTextDark),
              decoration: InputDecoration(
                fillColor: kSurface,
                filled: true,
                hintText: 'Search items by name, location...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: kTextGrey),
                prefixIcon: const Icon(Icons.search_rounded, color: kPrimaryLight),
                suffixIcon: _q.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: kTextGrey),
                        onPressed: () { _ctrl.clear(); setState(() => _q = ''); },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusFull), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusFull), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusFull), borderSide: const BorderSide(color: kAccent, width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final results = snapshot.hasData ? _applyFilter(snapshot.data!.docs) : <Map<String, String>>[];
          return Column(
            children: [
              Container(
                color: kSurface,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    ..._filters.map((f) {
                      final sel = _filter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? kPrimary : kBackground,
                            borderRadius: BorderRadius.circular(kRadiusFull),
                            border: Border.all(color: sel ? kPrimary : kBorder),
                          ),
                          child: Text(f, style: GoogleFonts.poppins(color: sel ? Colors.white : kTextGrey, fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                        ),
                      );
                    }),
                    const Spacer(),
                    Text('${results.length} found', style: GoogleFonts.poppins(color: kTextGrey, fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 64, color: kTextGrey.withOpacity(0.4)),
                                const SizedBox(height: 12),
                                Text('No results found', style: GoogleFonts.poppins(color: kTextGrey, fontSize: 16, fontWeight: FontWeight.w600)),
                                Text(_q.isEmpty ? 'Start typing to search...' : 'Try different keywords', style: GoogleFonts.poppins(color: kTextGrey, fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                            itemCount: results.length,
                            itemBuilder: (context, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ItemCard(
                                item: results[i],
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailScreen(item: results[i]))),
                              ),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════
// MY POSTS SCREEN
// ═══════════════════════════════════════════════════════

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('My Posts')),
      body: uid == null
          ? Center(child: Text('Please log in', style: GoogleFonts.poppins(color: kTextGrey)))
          : StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('items')
                  .where('postedBy', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.post_add_rounded, size: 64, color: kTextGrey.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text('No posts yet', style: GoogleFonts.poppins(color: kTextGrey, fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final item = _docToMap(docs[i].id, d);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: Key(docs[i].id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: kLostColor,
                            borderRadius: BorderRadius.circular(kRadius),
                          ),
                          child: const Icon(Icons.delete_rounded, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
                              title: Text('Delete Post', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                              content: Text('Are you sure you want to delete this post?', style: GoogleFonts.poppins(fontSize: 14)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.poppins())),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Delete', style: GoogleFonts.poppins(color: kLostColor, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ) ?? false;
                        },
                        onDismissed: (_) => _db.collection('items').doc(docs[i].id).delete(),
                        child: Stack(
                          children: [
                            ItemCard(
                              item: item,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Status chip (tappable)
                                  GestureDetector(
                                    onTap: () => _showMyPostStatusPicker(context, docs[i].id, item['status'] ?? 'Active'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statusColor(item['status']).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(kRadiusFull),
                                        border: Border.all(color: _statusColor(item['status']).withOpacity(0.5)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(item['status'] ?? 'Active', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor(item['status']))),
                                          const SizedBox(width: 2),
                                          Icon(Icons.expand_more_rounded, size: 12, color: _statusColor(item['status'])),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Edit button
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => EditPostScreen(item: item)),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: kPrimary.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: kPrimary.withOpacity(0.3)),
                                      ),
                                      child: const Icon(Icons.edit_rounded, size: 14, color: kPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Active': return kFoundColor;
      case 'Claimed': return kClaimedColor;
      case 'Returned': return kPrimaryLight;
      default: return kTextGrey;
    }
  }

  void _showMyPostStatusPicker(BuildContext context, String docId, String current) {
    const statuses = ['Active', 'Claimed', 'Returned'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: kSurface,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(kRadiusFull))),
            const SizedBox(height: 20),
            Text('Update Status', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: kTextDark)),
            const SizedBox(height: 16),
            ...statuses.map((s) {
              Color sc;
              IconData ic;
              switch (s) {
                case 'Active': sc = kFoundColor; ic = Icons.radio_button_checked_rounded; break;
                case 'Claimed': sc = kClaimedColor; ic = Icons.handshake_rounded; break;
                default: sc = kPrimaryLight; ic = Icons.check_circle_rounded;
              }
              final isCurrent = current == s;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? sc.withOpacity(0.08) : kBackground,
                  borderRadius: BorderRadius.circular(kRadius),
                  border: Border.all(color: isCurrent ? sc : kBorder, width: isCurrent ? 1.5 : 1),
                ),
                child: ListTile(
                  leading: Icon(ic, color: sc),
                  title: Text(s, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: kTextDark)),
                  trailing: isCurrent ? Icon(Icons.check_rounded, color: sc) : null,
                  onTap: () async {
                    Navigator.pop(context);
                    if (isCurrent) return;
                    await _db.collection('items').doc(docId).update({'status': s});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Status updated to $s', style: GoogleFonts.poppins(fontSize: 13)),
                        backgroundColor: kFoundColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
                      ));
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// PROFILE TAB
// ═══════════════════════════════════════════════════════

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  void _showEditProfile(BuildContext context, String uid, String name, String dept, String semester, String phone) {
    final nameCtrl = TextEditingController(text: name);
    final phoneCtrl = TextEditingController(text: phone);
    String selDept = dept.isEmpty ? 'CS' : dept;
    String selSem = semester.isEmpty ? '1st Semester' : semester;
    const depts = ['CS', 'SE', 'EE', 'CE', 'ME', 'BBA', 'Other'];
    const sems = ['1st Semester', '2nd Semester', '3rd Semester', '4th Semester', '5th Semester', '6th Semester', '7th Semester', '8th Semester'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: kSurface,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 40),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(kRadiusFull)))),
                const SizedBox(height: 20),
                Center(child: Text('Edit Profile', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: kTextDark))),
                const SizedBox(height: 20),
                Text('Full Name', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: kTextGrey)),
                const SizedBox(height: 6),
                TextField(controller: nameCtrl, style: GoogleFonts.poppins(fontSize: 14), decoration: const InputDecoration(prefixIcon: Icon(Icons.person_rounded), hintText: 'Your full name')),
                const SizedBox(height: 14),
                Text('Phone Number', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: kTextGrey)),
                const SizedBox(height: 6),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, style: GoogleFonts.poppins(fontSize: 14), decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_rounded), hintText: '03XX-XXXXXXX')),
                const SizedBox(height: 14),
                Text('Department', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: kTextGrey)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selDept,
                  style: GoogleFonts.poppins(fontSize: 14, color: kTextDark),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.school_rounded)),
                  borderRadius: BorderRadius.circular(kRadius),
                  items: depts.map((d) => DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                  onChanged: (v) => setSt(() => selDept = v!),
                ),
                const SizedBox(height: 14),
                Text('Semester', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: kTextGrey)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selSem,
                  style: GoogleFonts.poppins(fontSize: 14, color: kTextDark),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.class_rounded)),
                  borderRadius: BorderRadius.circular(kRadius),
                  items: sems.map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                  onChanged: (v) => setSt(() => selSem = v!),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusFull))),
                    onPressed: () async {
                      await _db.collection('users').doc(uid).update({
                        'name': nameCtrl.text.trim(),
                        'phoneNumber': phoneCtrl.text.trim(),
                        'department': selDept,
                        'semester': selSem,
                      });
                      await _auth.currentUser?.updateDisplayName(nameCtrl.text.trim());
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Profile updated!', style: GoogleFonts.poppins(fontSize: 13)),
                          backgroundColor: kFoundColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
                        ));
                      }
                    },
                    child: Text('Save Changes', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid ?? '';
    return StreamBuilder<DocumentSnapshot>(
      stream: _db.collection('users').doc(uid).snapshots(),
      builder: (context, userSnap) {
        final u = userSnap.data?.data() as Map<String, dynamic>? ?? {};
        final name = u['name'] ?? 'Student';
        final email = u['email'] ?? (_auth.currentUser?.email ?? '');
        final dept = u['department'] ?? '';
        final semester = u['semester'] ?? '';
        final phone = u['phoneNumber'] ?? '';
        final role = u['role'] ?? 'Student';

        return StreamBuilder<QuerySnapshot>(
          stream: _db.collection('items').where('postedBy', isEqualTo: uid).snapshots(),
          builder: (context, itemsSnap) {
            final allPosts = itemsSnap.data?.docs ?? [];
            final totalPosts = allPosts.length.toString();
            final returned = allPosts.where((d) => (d.data() as Map)['status'] == 'Returned').length.toString();
            final active = allPosts.where((d) => (d.data() as Map)['status'] == 'Active').length.toString();

            return Scaffold(
              backgroundColor: kBackground,
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: kPrimary,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [kPrimaryDark, kPrimary, Color(0xFF283593)],
                          ),
                        ),
                        child: Stack(
                          children: [
                            const _BgPattern(),
                            SafeArea(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),
                                  Stack(
                                    children: [
                                      Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: kAccent.withOpacity(0.2),
                                          border: Border.all(color: kAccent, width: 2.5),
                                        ),
                                        child: const Icon(Icons.person_rounded, size: 52, color: kAccent),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () => _showEditProfile(context, uid, name, dept, semester, phone),
                                          child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: kAccent,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: kPrimary, width: 2),
                                          ),
                                          child: const Icon(Icons.edit_rounded, color: kPrimary, size: 14),
                                        ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                                  Text(
                                    dept.isNotEmpty && semester.isNotEmpty ? '$dept • $semester' : email,
                                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: kAccent.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(kRadiusFull),
                                      border: Border.all(color: kAccent.withOpacity(0.4)),
                                    ),
                                    child: Text('🎓 $role', style: GoogleFonts.poppins(color: kAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _PStat(totalPosts, 'Posts'),
                              const SizedBox(width: 12),
                              _PStat(returned, 'Returned'),
                              const SizedBox(width: 12),
                              _PStat(active, 'Active'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _PSection('Personal Information', [
                            _PTile(icon: Icons.email_rounded, ic: kPrimaryLight, label: 'Email', value: email),
                            _PTile(icon: Icons.school_rounded, ic: kFoundColor, label: 'Department', value: dept.isEmpty ? 'Not set' : dept),
                            _PTile(icon: Icons.class_rounded, ic: kClaimedColor, label: 'Semester', value: semester.isEmpty ? 'Not set' : semester),
                            _PTile(icon: Icons.phone_rounded, ic: const Color(0xFF00897B), label: 'Phone', value: phone.isEmpty ? 'Not set' : phone, isLast: true),
                          ]),
                          const SizedBox(height: 16),
                          _PSection('Settings', [
                            _STile(
                              icon: Icons.article_rounded,
                              label: 'My Posts',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPostsScreen())),
                            ),
                            _STile(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
                            _STile(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}),
                            _STile(icon: Icons.info_outline_rounded, label: 'About App', onTap: () {}, isLast: true),
                          ]),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: () => _logout(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kLostColor.withOpacity(0.08),
                                foregroundColor: kLostColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(kRadiusFull),
                                  side: BorderSide(color: kLostColor.withOpacity(0.3)),
                                ),
                              ),
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: Text('Logout', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: kLostColor)),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PStat extends StatelessWidget {
  final String v, l;
  const _PStat(this.v, this.l);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(kRadius),
          boxShadow: kCardShadow,
        ),
        child: Column(
          children: [
            Text(
              v,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kPrimary,
              ),
            ),
            Text(l, style: GoogleFonts.poppins(fontSize: 12, color: kTextGrey)),
          ],
        ),
      ),
    );
  }
}

class _PSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _PSection(this.title, this.children);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kTextMid,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(kRadius),
            boxShadow: kCardShadow,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _PTile extends StatelessWidget {
  final IconData icon;
  final Color ic;
  final String label, value;
  final bool isLast;
  const _PTile({
    required this.icon,
    required this.ic,
    required this.label,
    required this.value,
    this.isLast = false,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ic.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kRadiusSm),
                ),
                child: Icon(icon, color: ic, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: kTextGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        color: kTextDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 74, endIndent: 20, color: kBorder),
      ],
    );
  }
}

class _STile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;
  const _STile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(kRadiusSm),
            ),
            child: Icon(icon, color: kPrimaryLight, size: 20),
          ),
          title: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kTextDark,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: kTextGrey,
            size: 20,
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 74, endIndent: 20, color: kBorder),
      ],
    );
  }
}
