import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart'; // UI: Animation package
import 'package:cached_network_image/cached_network_image.dart'; // UI & CACHING: Image caching package
import '../../data/repositories.dart';
import '../../domain/models.dart';
import 'package:intl/intl.dart';
import '../../core/glass_widgets.dart';
import '../../core/shimmer.dart';
import '../../core/responsive.dart';
import '../../core/notifications.dart';
import '../shared/main_wrapper.dart';

class GuestHomeScreen extends ConsumerStatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  ConsumerState<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends ConsumerState<GuestHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';

  @override
  void dispose() {
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _searchController.clear();
    setState(() => _query = '');
    _searchFocus.unfocus();
    ref.read(searchVisibilityProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    // STATE MANAGEMENT: Watch the packages stream using Riverpod
    final packagesAsyncValue = ref.watch(providerOfPackages);
    // STATE MANAGEMENT: Watch search visibility from the shared provider
    final showSearchBar = ref.watch(searchVisibilityProvider);

    // Auto-focus when search opens
    if (showSearchBar && !_searchFocus.hasFocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && showSearchBar) _searchFocus.requestFocus();
      });
    }

    return Scaffold(
      extendBodyBehindAppBar:
          true, // UI: Allows content to flow behind transparent app bar
      // Fixed Glass AppBar (Custom Widget)
      appBar: GlassAppBar(title: 'Luxe Dining'),
      body: Stack(
        children: [
          // 1. Fixed Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1920&q=80',
              fit: BoxFit.cover,
            ),
          ),
          // 2. Dark Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // 3. Main Content Structure
          Column(
            children: [
              // Spacer for AppBar
              SizedBox(
                height:
                    kToolbarHeight + MediaQuery.of(context).padding.top + 10,
              ),

              // Expanded Area for Content
              Expanded(child: _buildPackagesList(packagesAsyncValue)),
            ],
          ),

          // 4. Premium Search Overlay
          if (showSearchBar) _buildSearchOverlay(packagesAsyncValue),
        ],
      ),
    );
  }

  // UI: Builds the premium search overlay
  Widget _buildSearchOverlay(AsyncValue<List<MenuPackage>> packagesAsyncValue) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _closeSearch,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: Colors.black.withOpacity(0.7),
            child: SafeArea(
              child: Column(
                children: [
                  // Premium Search Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Discover',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFD4AF37),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _closeSearch,
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            )
                            // UI ANIMATION: 3rd party package 'flutter_animate' for fade and slide effects
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: -0.1),
                        const SizedBox(height: 16),
                        // Premium Search Field
                        Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(
                                    0xFFD4AF37,
                                  ).withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFD4AF37,
                                    ).withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocus,
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search experiences, cuisines...',
                                  hintStyle: GoogleFonts.lato(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 16,
                                  ),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 12,
                                    ),
                                    child: Icon(
                                      Icons.search_rounded,
                                      color: Color(0xFFD4AF37),
                                      size: 24,
                                    ),
                                  ),
                                  suffixIcon: _query.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _query = '');
                                          },
                                          icon: const Icon(
                                            Icons.clear_rounded,
                                            color: Colors.white54,
                                            size: 20,
                                          ),
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                ),
                                onChanged: (val) =>
                                    setState(() => _query = val),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 300.ms)
                            .scaleXY(begin: 0.95),
                      ],
                    ),
                  ),

                  // Search Results
                  Expanded(
                    child: GestureDetector(
                      onTap: () {}, // Prevent tap from closing overlay
                      child: _buildSearchResults(packagesAsyncValue),
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

  Widget _buildSearchResults(AsyncValue<List<MenuPackage>> packagesAsyncValue) {
    return packagesAsyncValue.when(
      data: (packages) {
        if (_query.isEmpty) {
          // Show suggestions when no query
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Popular Searches',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      [
                        'Seafood',
                        'Wagyu',
                        'Vegetarian',
                        'Fine Dining',
                        'Halal',
                      ].asMap().entries.map((entry) {
                        return GestureDetector(
                              onTap: () {
                                _searchController.text = entry.value;
                                setState(() => _query = entry.value);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.trending_up,
                                      size: 16,
                                      color: Color(0xFFD4AF37),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      entry.value,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .animate(delay: (250 + entry.key * 50).ms)
                            .fadeIn()
                            .slideX(begin: 0.1);
                      }).toList(),
                ),
              ],
            ),
          );
        }

        // SEARCH LOGIC: Filter results based on the query string
        final results = packages.where((p) {
          final queryLower = _query.toLowerCase();
          // CORE FUNCTION: Basic search/filter function
          return p.name.toLowerCase().contains(queryLower) ||
              p.description.toLowerCase().contains(queryLower);
        }).toList();

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'No results for "$_query"',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ).animate().fadeIn(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final package = results[index];
            return _buildSearchResultItem(package, index);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      ),
      error: (_, __) => const Center(
        child: Text(
          'Error loading results',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildSearchResultItem(MenuPackage package, int index) {
    final formatCurrency = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
    );

    return GestureDetector(
      onTap: () {
        _closeSearch();
        context.push('/package-details', extra: package);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            // UI: Image Display with Caching
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: package.imageUrl.isNotEmpty
                  // CACHING: 3rd party package 'cached_network_image' handles loading, caching, and error placeholders
                  ? CachedNetworkImage(
                      imageUrl: package.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: const Color(0xFF2A2A2A),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white24,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency.format(package.pricePerGuest),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white24,
            ),
          ],
        ),
      ),
    ).animate(delay: (100 + index * 50).ms).fadeIn().slideX(begin: 0.05);
  }

  Widget _buildPackagesList(AsyncValue<List<MenuPackage>> packagesAsyncValue) {
    return packagesAsyncValue.when(
      data: (packages) {
        if (packages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No experiences available',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn();
        }

        // Responsive: Use grid on desktop, list on mobile
        final isDesktop = Responsive.isDesktop(context);
        final crossAxisCount = Responsive.gridColumns(context);

        if (isDesktop) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.maxContentWidth(context),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.72,
                ),
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  final package = packages[index];
                  return PackageCard(package: package, index: index);
                },
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final package = packages[index];
            return PackageCard(package: package, index: index);
          },
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        itemCount: 3,
        itemBuilder: (context, index) => const PackageCardSkeleton(),
      ),
      error: (err, stack) => Center(
        child: GlassContainer(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load experiences',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(providerOfPackages),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(),
    );
  }
}

// STATE MANAGEMENT: Provider to fetch packages from repository
// Returns a Stream which updates UI automatically when database changes
final providerOfPackages = StreamProvider<List<MenuPackage>>((ref) {
  return ref.watch(databaseRepositoryProvider).getPackages();
});

class PackageCard extends ConsumerStatefulWidget {
  final MenuPackage package;
  final int index;

  const PackageCard({super.key, required this.package, this.index = 0});

  @override
  ConsumerState<PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends ConsumerState<PackageCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
    );

    return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: () =>
                context.push('/package-details', extra: widget.package),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
              child: GlassContainer(
                margin: const EdgeInsets.only(bottom: 24),
                opacity: _isHovered ? 0.2 : 0.15,
                blur: 15,
                color: Colors.white,
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFFD4AF37).withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  width: _isHovered ? 1.5 : 1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image area with Hero animation
                    Hero(
                      tag: 'package_image_${widget.package.id}',
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: widget.package.imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: widget.package.imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: 200,
                                      color: const Color(0xFF2A2A2A),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFFD4AF37),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          height: 200,
                                          color: const Color(0xFF2A2A2A),
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white30,
                                            size: 48,
                                          ),
                                        ),
                                  )
                                : Container(
                                    height: 200,
                                    color: const Color(0xFF2A2A2A),
                                    child: const Icon(
                                      Icons.restaurant,
                                      size: 50,
                                      color: Colors.white54,
                                    ),
                                  ),
                          ),
                          // Gradient overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.6),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Availability badge
                          if (widget.package.isAvailable)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Available',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Content area
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.package.name,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatCurrency.format(
                                      widget.package.pricePerGuest,
                                    ),
                                    style: GoogleFonts.lato(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFD4AF37),
                                    ),
                                  ),
                                  Text(
                                    'per guest',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.package.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Dietary tags
                          if (widget.package.dietaryInfo.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.package.dietaryInfo.take(3).map((
                                tag,
                              ) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFD4AF37,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFD4AF37,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      color: Color(0xFFD4AF37),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 16),
                          // Book button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Check if user is logged in
                                final authState = ref.read(authStateProvider);
                                final user = authState.value;
                                if (user == null) {
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
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'BOOK NOW',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
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
        )
        .animate(delay: (50 * widget.index).ms)
        .fadeIn(duration: 400.ms)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
