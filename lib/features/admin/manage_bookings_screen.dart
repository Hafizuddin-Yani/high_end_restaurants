import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:high_end_restaurants/features/admin/widgets/admin_scaffold.dart';
import 'package:high_end_restaurants/data/repositories.dart';
import 'package:high_end_restaurants/domain/models.dart';

class ManageBookingsScreen extends ConsumerWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine title based on screen width (Mobile/Desktop)
    // AdminScaffold handles the main title on Desktop.

    // UI PAGE: Admin view for managing all customer reservations
    return AdminScaffold(
      title: "Reservations",
      child: const AdminBookingsList(),
    );
  }
}

class AdminBookingsList extends ConsumerWidget {
  const AdminBookingsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // STATE MANAGEMENT: Watch stream of all bookings from Firestore
    final bookingsAsync = ref.watch(adminBookingsProvider);

    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return const Center(
            child: Text(
              "No bookings found.",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return AdminBookingTile(booking: booking);
          },
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (e, st) => Center(
        child: Text("Error: $e", style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}

class AdminBookingTile extends ConsumerWidget {
  final Booking booking;
  const AdminBookingTile({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatCurrency = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
    );
    final theme = Theme.of(context);
    final isPending = booking.status == 'pending';
    final isConfirmed = booking.status == 'confirmed';
    final isCancelled =
        booking.status == 'cancelled' || booking.status == 'rejected';

    Color statusColor = Colors.grey;
    if (isPending) statusColor = Colors.orange;
    if (isConfirmed) statusColor = Colors.green;
    if (isCancelled) statusColor = Colors.red;

    // Use a simplified Card style that looks good on Glass/Dark
    return Card(
      color: Colors.white.withOpacity(0.05), // Glassy card
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        title: Text(
          booking.menuPackageName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat.yMMMd().add_jm().format(booking.eventDateTime),
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              "Guests: ${booking.numberOfGuests} • ${formatCurrency.format(booking.totalPrice)}",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Text(
                booking.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (booking.specialRequests != null &&
                    booking.specialRequests!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "REMARKS / CONTACT",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.specialRequests!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isPending || isConfirmed) ...[
                      if (booking.status != 'rejected' &&
                          booking.status != 'cancelled')
                        TextButton(
                          onPressed: () =>
                              _updateStatus(context, ref, 'cancelled'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                          ),
                          child: const Text("Reject/Cancel"),
                        ),
                    ],
                    if (isPending)
                      ElevatedButton(
                        onPressed: () =>
                            _updateStatus(context, ref, 'confirmed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Approve"),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String status,
  ) async {
    // LOGIC: Show confirmation dialog before mutating booking status
    final action = status == 'confirmed' ? 'Approve' : 'Cancel/Reject';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B), // Dark dialog
        title: Text(
          "$action Booking",
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to $action this booking?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: status == 'confirmed'
                  ? Colors.green
                  : Colors.red,
            ),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (status == 'cancelled') {
        await ref.read(databaseRepositoryProvider).cancelBooking(booking.id);
      } else {
        await ref
            .read(databaseRepositoryProvider)
            .updateBookingStatus(booking.id, status);
      }
    }
  }
}

// Keep the provider here or move to a common providers file if reused.
// For now, redefining locally or importing if it was shared.
// Looking at original file, `adminBookingsProvider` was defined at bottom.
// STATE: Provider to stream all bookings for the admin view
final adminBookingsProvider = StreamProvider<List<Booking>>((ref) {
  return ref
      .watch(databaseRepositoryProvider)
      .getAllBookings(); // DATABASE: Get full list
});
