import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models.dart';
import '../../data/repositories.dart';
import '../../core/glass_widgets.dart';
import '../../core/notifications.dart';
import '../../core/responsive.dart';

// UI PAGE: detailed view of a menu package for guests.
// FEATURES: Hero Animation, Collapsing Header, Responsive Layout
class PackageDetailScreen extends ConsumerStatefulWidget {
  final MenuPackage package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  ConsumerState<PackageDetailScreen> createState() =>
      _PackageDetailScreenState();
}

class _PackageDetailScreenState extends ConsumerState<PackageDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
    );
    // STATE MANAGEMENT: Access authentication state to condense booking flow
    final authState = ref.watch(authStateProvider);
    final isDesktop = Responsive.isDesktop(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero Image Header
              SliverAppBar(
                expandedHeight: isDesktop ? screenHeight * 0.5 : 350,
                pinned: true,
                backgroundColor: const Color(0xFF0A0A0A),
                leading: _buildBackButton(),
                actions: [_buildShareButton(), const SizedBox(width: 8)],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image with Hero animation
                      Hero(
                        tag: 'package_image_${widget.package.id}',
                        child: widget.package.imageUrl.isNotEmpty
                            // UI: Network Image with local caching
                            ? CachedNetworkImage(
                                imageUrl: widget.package.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFF1A1A1A),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFD4AF37),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: const Color(0xFF1A1A1A),
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                    color: Colors.white24,
                                  ),
                                ),
                              )
                            : Container(color: const Color(0xFF1A1A1A)),
                      ),
                      // Gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 200,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                                Colors.black,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Availability badge
                      if (widget.package.isAvailable)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 60,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Available Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2),
                        ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: isDesktop
                    ? _buildDesktopContent(formatCurrency)
                    : _buildMobileContent(formatCurrency),
              ),
            ],
          ),

          // Floating Book Button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: _buildBookButton(authState, formatCurrency),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () {
        LuxeToast.info(context, 'Share feature coming soon!');
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Icon(Icons.share, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildMobileContent(NumberFormat formatCurrency) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(formatCurrency),
          const SizedBox(height: 24),
          _buildDescription(),
          const SizedBox(height: 24),
          if (widget.package.dietaryInfo.isNotEmpty) ...[
            _buildDietarySection(),
            const SizedBox(height: 24),
          ],
          _buildHighlights(),
          const SizedBox(height: 24),
          _buildIncludesSection(),
        ],
      ),
    );
  }

  Widget _buildDesktopContent(NumberFormat formatCurrency) {
    return ContentConstraint(
      maxWidth: 1200,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(formatCurrency),
                  const SizedBox(height: 32),
                  _buildDescription(),
                  const SizedBox(height: 32),
                  _buildHighlights(),
                  const SizedBox(height: 32),
                  _buildIncludesSection(),
                ],
              ),
            ),
            const SizedBox(width: 40),
            // Sidebar
            SizedBox(
              width: 350,
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Summary',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSummaryItem(
                      Icons.restaurant_menu,
                      'Experience',
                      widget.package.name,
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryItem(
                      Icons.attach_money,
                      'Price',
                      '${formatCurrency.format(widget.package.pricePerGuest)} per guest',
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryItem(
                      Icons.access_time,
                      'Duration',
                      '2-3 hours',
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryItem(
                      Icons.people,
                      'Group Size',
                      '2-50 guests',
                    ),
                    if (widget.package.dietaryInfo.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildDietarySection(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(NumberFormat formatCurrency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.package.name,
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              formatCurrency.format(widget.package.pricePerGuest),
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'per guest',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 16),
        // Rating placeholder
        Row(
          children: [
            ...List.generate(
              5,
              (index) => Icon(
                index < 4 ? Icons.star : Icons.star_half,
                color: const Color(0xFFD4AF37),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '4.8',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' (120 reviews)',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ).animate(delay: 150.ms).fadeIn(),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About This Experience',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.package.description,
          style: TextStyle(
            fontSize: 16,
            height: 1.7,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.05);
  }

  Widget _buildDietarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary Options',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.package.dietaryInfo.map((info) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getDietaryIcon(info),
                    size: 16,
                    color: const Color(0xFFD4AF37),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    info,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ).animate(delay: 250.ms).fadeIn();
  }

  IconData _getDietaryIcon(String info) {
    switch (info.toLowerCase()) {
      case 'vegetarian':
        return Icons.eco;
      case 'vegan':
        return Icons.grass;
      case 'gluten-free':
        return Icons.no_food;
      case 'halal':
        return Icons.verified;
      case 'kosher':
        return Icons.star_border;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildHighlights() {
    final highlights = [
      {
        'icon': Icons.restaurant,
        'title': 'Michelin-Quality',
        'desc': 'Crafted by award-winning chefs',
      },
      {
        'icon': Icons.local_florist,
        'title': 'Fresh Ingredients',
        'desc': 'Locally sourced, seasonal produce',
      },
      {
        'icon': Icons.wine_bar,
        'title': 'Wine Pairing',
        'desc': 'Curated selection available',
      },
      {
        'icon': Icons.access_time,
        'title': 'Flexible Timing',
        'desc': 'Lunch & dinner available',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience Highlights',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...highlights.asMap().entries.map((entry) {
          final highlight = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child:
                Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            highlight['icon'] as IconData,
                            color: const Color(0xFFD4AF37),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                highlight['title'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                highlight['desc'] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                    .animate(delay: (300 + entry.key * 50).ms)
                    .fadeIn()
                    .slideX(begin: 0.05),
          );
        }),
      ],
    );
  }

  Widget _buildIncludesSection() {
    final includes = [
      'Welcome drink upon arrival',
      'Multi-course tasting menu',
      'Premium table setting',
      'Dedicated service staff',
      'Complimentary parking',
    ];

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFFD4AF37),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'What\'s Included',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...includes.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:
                  Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD4AF37),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            entry.value,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                      .animate(delay: (400 + entry.key * 50).ms)
                      .fadeIn()
                      .slideX(begin: 0.05),
            );
          }),
        ],
      ),
    ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.05);
  }

  Widget _buildBookButton(AsyncValue authState, NumberFormat formatCurrency) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      opacity: 0.3,
      blur: 25,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Starting from',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                Text(
                  formatCurrency.format(widget.package.pricePerGuest),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Semantics(
            label: 'Book this experience now',
            button: true,
            child: ElevatedButton(
              onPressed: () {
                final user = authState.value;
                if (user == null) {
                  // LOGIC: Redirect to login if user tries to book without auth
                  LuxeToast.info(
                    context,
                    'Please sign in to make a reservation',
                  );
                  context.push('/login');
                } else {
                  context.push('/book', extra: widget.package);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: const Color(0xFFD4AF37).withOpacity(0.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'BOOK NOW',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  }
}
