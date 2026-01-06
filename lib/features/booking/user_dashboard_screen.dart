import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/repositories.dart';
import '../../domain/models.dart';
import '../../core/glass_widgets.dart';
import '../../core/shimmer.dart';
import '../../core/notifications.dart';

// UI PAGE: Displays the user's booking history and current reservations.
class UserDashboardScreen extends ConsumerWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'My Reservations'),
      body: Stack(
        children: [
          // 1. Background
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1544148103-0773bf10d330?ixlib=rb-1.2.1&auto=format&fit=crop&w=1920&q=80',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          // 2. Content
          Padding(
            padding: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top,
            ),
            child: const UserBookingsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/'),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
        tooltip: 'New Booking',
      ),
    );
  }
}

class UserBookingsList extends ConsumerWidget {
  const UserBookingsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // STATE MANAGEMENT: Watch the current user stream to adapt UI (Guest vs Logged In)
    final userAsync = ref.watch(currentAppUserStreamProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Center(
            child: GlassContainer(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Color(0xFFFFD700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Sign In Required",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please sign in to view and manage your reservations.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(userBookingsProvider(user.id)),
          color: const Color(0xFFFFD700),
          child: _BookingsListContent(userId: user.id),
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => const BookingCardSkeleton(),
      ),
      error: (e, st) => Center(
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
                'Unable to load',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingsListContent extends ConsumerWidget {
  final String userId;
  const _BookingsListContent({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // STATE MANAGEMENT: Watch bookings stream specific to this user
    final bookingsAsync = ref.watch(userBookingsProvider(userId));

    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: GlassContainer(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: Color(0xFFFFD700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No Reservations Yet",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Start by exploring our exquisite menu packages and make your first reservation.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.explore),
                    label: const Text("EXPLORE MENU"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return BookingCard(booking: booking, index: index);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      ),
      error: (e, st) => Center(
        child: GlassContainer(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                "Unable to Load Reservations",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(userBookingsProvider(userId)),
                icon: const Icon(Icons.refresh),
                label: const Text("RETRY"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingCard extends ConsumerWidget {
  final Booking booking;
  final int index;

  const BookingCard({super.key, required this.booking, this.index = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpcoming = booking.eventDateTime.isAfter(DateTime.now());
    final isCancelled = booking.status == 'cancelled';
    final isConfirmed = booking.status == 'confirmed';
    final formatCurrency = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
    );

    // Calculate days until event
    final daysUntil = booking.eventDateTime.difference(DateTime.now()).inDays;

    return Semantics(
      label:
          'Booking for ${booking.menuPackageName} on ${DateFormat('MMMM d').format(booking.eventDateTime)}',
      child:
          GlassContainer(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                opacity: isCancelled ? 0.1 : 0.15,
                blur: 15,
                border: Border.all(
                  color: isConfirmed
                      ? Colors.green.withOpacity(0.3)
                      : isCancelled
                      ? Colors.red.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Event Image with CachedNetworkImage
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: booking.packageImageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: booking.packageImageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 80,
                                    height: 80,
                                    color: const Color(0xFF2A2A2A),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFD4AF37),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 80,
                                        height: 80,
                                        color: const Color(0xFF2A2A2A),
                                        child: const Icon(
                                          Icons.restaurant,
                                          color: Colors.white30,
                                        ),
                                      ),
                                )
                              : Container(
                                  width: 80,
                                  height: 80,
                                  color: const Color(0xFF2A2A2A),
                                  child: const Icon(
                                    Icons.restaurant,
                                    color: Colors.white30,
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
                                booking.menuPackageName,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isCancelled
                                      ? Colors.white54
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat(
                                      'EEE, MMM d • h:mm a',
                                    ).format(booking.eventDateTime),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 14,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${booking.numberOfGuests} guests',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    formatCurrency.format(booking.totalPrice),
                                    style: const TextStyle(
                                      color: Color(0xFFD4AF37),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 12),

                    // Footer Actions/Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status Badge with days until
                        Row(
                          children: [
                            _buildStatusBadge(
                              isCancelled,
                              isUpcoming,
                              isConfirmed,
                            ),
                            if (isUpcoming &&
                                !isCancelled &&
                                daysUntil >= 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  daysUntil == 0
                                      ? 'Today!'
                                      : daysUntil == 1
                                      ? 'Tomorrow'
                                      : 'In $daysUntil days',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: daysUntil <= 1
                                        ? const Color(0xFFD4AF37)
                                        : Colors.white60,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Action Buttons
                        Row(
                          children: [
                            if (isUpcoming && !isCancelled) ...[
                              TextButton(
                                onPressed: () =>
                                    _confirmCancel(context, ref, booking.id),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  final package = MenuPackage(
                                    id: booking.menuPackageId,
                                    name: booking.menuPackageName,
                                    description: '',
                                    imageUrl: booking.packageImageUrl,
                                    pricePerGuest: booking.basePricePerGuest,
                                  );
                                  context.push(
                                    '/book/edit',
                                    extra: {
                                      'package': package,
                                      'booking': booking,
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFD4AF37),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                child: const Text(
                                  "Edit",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate(delay: (index * 50).ms)
              .fadeIn(duration: 400.ms)
              .slideY(
                begin: 0.1,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),
    );
  }

  Widget _buildStatusBadge(
    bool isCancelled,
    bool isUpcoming,
    bool isConfirmed,
  ) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    if (isCancelled) {
      bgColor = Colors.red.withOpacity(0.2);
      borderColor = Colors.red.withOpacity(0.5);
      textColor = Colors.redAccent;
      icon = Icons.cancel_outlined;
    } else if (isConfirmed) {
      bgColor = Colors.green.withOpacity(0.2);
      borderColor = Colors.green.withOpacity(0.5);
      textColor = Colors.greenAccent;
      icon = Icons.check_circle_outline;
    } else if (isUpcoming) {
      bgColor = const Color(0xFFD4AF37).withOpacity(0.2);
      borderColor = const Color(0xFFD4AF37).withOpacity(0.5);
      textColor = const Color(0xFFD4AF37);
      icon = Icons.schedule;
    } else {
      bgColor = Colors.grey.withOpacity(0.2);
      borderColor = Colors.grey.withOpacity(0.5);
      textColor = Colors.grey;
      icon = Icons.history;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            booking.status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    String bookingId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF202020),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Cancel Booking?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to cancel this reservation? This action cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Keep Reservation",
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.2),
            ),
            child: const Text(
              "Cancel Booking",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(databaseRepositoryProvider).cancelBooking(bookingId);
        if (context.mounted) {
          LuxeToast.success(context, 'Reservation cancelled successfully');
        }
      } catch (e) {
        if (context.mounted) {
          LuxeToast.error(context, 'Failed to cancel: $e');
        }
      }
    }
  }
}

// STATE MANAGEMENT: Stream provider to fetch bookings for a specific user
final userBookingsProvider = StreamProvider.family<List<Booking>, String>((
  ref,
  userId,
) {
  return ref.watch(databaseRepositoryProvider).getUserBookings(userId);
});
