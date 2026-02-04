import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:HamroGharSewa/LandingPage/Landing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HeroPage extends StatefulWidget {
  const HeroPage({Key? key}) : super(key: key);

  @override
  State<HeroPage> createState() => _HeroPageState();
}

class _HeroPageState extends State<HeroPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    // Generate particles for background animation
    _generateParticles();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }
  
  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _particles.add(
        Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 4 + 2,
          speed: random.nextDouble() * 0.5 + 0.2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_repair_service, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              'HamroGharSewa',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Animated Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A), // Slate 900
                  Color(0xFF1E293B), // Slate 800
                  Color(0xFF334155), // Slate 700
                ],
              ),
            ),
          ),
          
          // Animated Particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  animationValue: _particleController.value,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // Blob/Glow effects
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withOpacity(0.2), // Indigo 500
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 5.seconds, curve: Curves.easeInOut)
             .blur(begin: const Offset(50, 50), end: const Offset(100, 100)),
          ),

          Positioned(
            bottom: 100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEC4899).withOpacity(0.15), // Pink 500
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 4.seconds, curve: Curves.easeInOut)
             .blur(begin: const Offset(40, 40), end: const Offset(80, 80)),
          ),
          
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Icon with sophisticated animation
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.home_repair_service_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ).animate()
                         .fade(duration: 800.ms)
                         .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
                         .shimmer(delay: 2.seconds, duration: 2.seconds),
                        
                        const SizedBox(height: 40),
                        
                        // Animated Text - Welcome
                        Text(
                          'WELCOME TO',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 4,
                          ),
                        ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
                        
                        const SizedBox(height: 12),
                        
                        // Main Title with Animated Text Kit
                        SizedBox(
                          height: 80,
                          child: DefaultTextStyle(
                            style: GoogleFonts.outfit(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TyperAnimatedText('HamroGharSewa', speed: const Duration(milliseconds: 150)),
                              ],
                              isRepeatingAnimation: false,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Subtitle with Fade and Slide
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Your neighborhood\'s trusted platform for professional home services. Experience convenience like never before.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ).animate().fade(delay: 1500.ms, duration: 800.ms).slideY(begin: 0.1),
                        
                        const SizedBox(height: 50),
                        
                        // CTA Buttons
                        Column(
                          children: [
                            _buildPremiumButton(
                              context: context,
                              text: 'Explore Services',
                              icon: Icons.search_rounded,
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                            ).animate().fade(delay: 2000.ms).slideX(begin: -0.1),
                            
                            const SizedBox(height: 16),
                            
                            _buildPremiumOutlineButton(
                              context: context,
                              text: 'Join as Professional',
                              icon: Icons.work_outline_rounded,
                              onPressed: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                            ).animate().fade(delay: 2200.ms).slideX(begin: 0.1),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Quick Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildQuickStat('500+', 'Experts'),
                            Container(width: 1, height: 30, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
                            _buildQuickStat('10k+', 'Orders'),
                            Container(width: 1, height: 30, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
                            _buildQuickStat('4.9/5', 'Rating'),
                          ],
                        ).animate().fade(delay: 2500.ms).scale(),
                      ],
                    ),
                  ),
                  
                  // Landing Page Content with smooth transition
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    child: const LandingPage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumOutlineButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Particle class for animated background
class Particle {
  double x;
  double y;
  final double size;
  final double speed;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

// Custom painter for particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      // Update particle position
      particle.y = (particle.y + particle.speed * 0.001) % 1.0;
      
      final dx = particle.x * size.width;
      final dy = particle.y * size.height;
      
      // Draw particle with glow effect
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      canvas.drawCircle(Offset(dx, dy), particle.size * 2, glowPaint);
      canvas.drawCircle(Offset(dx, dy), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
