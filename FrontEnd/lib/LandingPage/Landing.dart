import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late AnimationController _statsController;
  late List<Animation<double>> _statAnimations;
  
  @override
  void initState() {
    super.initState();
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _statAnimations = List.generate(
      3,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _statsController,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
    
    _statsController.forward();
  }
  
  @override
  void dispose() {
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {
        'title': 'Plumbing',
        'description': 'Fix leaks, install fixtures, and more.',
        'icon': Icons.plumbing_rounded,
        'color': const Color(0xFF667eea),
        'gradient': const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      },
      {
        'title': 'Electrical',
        'description': 'Wiring, lights, and electrical safety.',
        'icon': Icons.electrical_services_rounded,
        'color': const Color(0xFFf093fb),
        'gradient': const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        ),
      },
      {
        'title': 'Cleaning',
        'description': 'Home, office, and deep cleaning services.',
        'icon': Icons.cleaning_services_rounded,
        'color': const Color(0xFF4facfe),
        'gradient': const LinearGradient(
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        ),
      },
      {
        'title': 'Carpenter',
        'description': 'Professional carpentry and woodwork.',
        'icon': Icons.carpenter_rounded,
        'color': const Color(0xFFfa709a),
        'gradient': const LinearGradient(
          colors: [Color(0xFFfa709a), Color(0xFFfee140)],
        ),
      },
      {
        'title': 'Painting',
        'description': 'Interior and exterior painting services.',
        'icon': Icons.format_paint_rounded,
        'color': const Color(0xFF30cfd0),
        'gradient': const LinearGradient(
          colors: [Color(0xFF30cfd0), Color(0xFF330867)],
        ),
      },
      {
        'title': 'Gardening',
        'description': 'Lawn care and garden maintenance.',
        'icon': Icons.grass_rounded,
        'color': const Color(0xFFa8edea),
        'gradient': const LinearGradient(
          colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
        ),
      },
    ];

    final List<Map<String, dynamic>> stats = [
      {'number': '500+', 'label': 'Service Providers', 'icon': Icons.people_rounded},
      {'number': '1000+', 'label': 'Happy Customers', 'icon': Icons.sentiment_satisfied_alt_rounded},
      {'number': '4.9', 'label': 'Average Rating', 'icon': Icons.star_rounded},
    ];

    return Container(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    stats.length,
                    (index) => Expanded(
                      child: AnimatedBuilder(
                        animation: _statAnimations[index],
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _statAnimations[index].value,
                            child: Opacity(
                              opacity: _statAnimations[index].value,
                              child: _buildStatCard(
                                stats[index]['number']!,
                                stats[index]['label']!,
                                stats[index]['icon']!,
                                index,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // Popular Services Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'SERVICES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Popular Services',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Professional services for every corner of your home',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate().fade().slideY(begin: 0.1),

          const SizedBox(height: 30),

          // Services Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(
                  services[index]['title']!,
                  services[index]['description']!,
                  services[index]['icon']!,
                  services[index]['gradient']!,
                  services[index]['color']!,
                );
              },
            ),
          ),

          const SizedBox(height: 50),

          // Why Choose Us Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why Choose Us?',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFeatureItem(
                  Icons.verified_user_rounded,
                  'Verified Professionals',
                  'All service providers are background checked',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  Icons.price_check_rounded,
                  'Best Prices',
                  'Competitive rates with no hidden charges',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  Icons.support_agent_rounded,
                  '24/7 Support',
                  'Round-the-clock customer assistance',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  Icons.schedule_rounded,
                  'Flexible Scheduling',
                  'Book services at your convenience',
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // Testimonial Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What Our Customers Say',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildTestimonialCard(
                        'Excellent service! The plumber arrived on time and fixed everything perfectly.',
                        'Ramesh Kumar',
                        'Kathmandu',
                      ),
                      _buildTestimonialCard(
                        'Very professional electrician. Highly recommended for electrical work.',
                        'Sita Sharma',
                        'Lalitpur',
                      ),
                      _buildTestimonialCard(
                        'Great cleaning service. My house looks brand new!',
                        'Bikash Thapa',
                        'Bhaktapur',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // Footer
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3748),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'HamroGharSewa',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your trusted home service partner',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFA0AEC0),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIcon(Icons.facebook),
                    const SizedBox(width: 16),
                    _buildSocialIcon(Icons.phone),
                    const SizedBox(width: 16),
                    _buildSocialIcon(Icons.email),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  '© 2026 HamroGharSewa. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon, int index) {
    final List<Color> colors = [
      const Color(0xFF667eea),
      const Color(0xFFf093fb),
      const Color(0xFF4facfe),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: index == 1 ? 8 : 4),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[index].withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors[index], colors[index].withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            number,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors[index],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    String title,
    String description,
    IconData icon,
    Gradient gradient,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialCard(String review, String name, String location) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => const Icon(
                Icons.star_rounded,
                color: Color(0xFFfbbf24),
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              review,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A5568),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
