import '../domain/models.dart';

/// Restaurant capacity configuration and slot availability management
class BookingCapacity {
  BookingCapacity._();

  /// Maximum guests per time slot
  static const int maxGuestsPerSlot = 100;

  /// Show "Last X spots!" warning when remaining capacity is at or below this
  static const int warningThreshold = 20;

  /// Minimum guests per booking
  static const int minGuestsPerBooking = 1;

  /// Maximum guests per single booking
  static const int maxGuestsPerBooking = 50;

  /// Calculate remaining capacity for a specific time slot
  static int getRemainingCapacity(
    List<Booking> bookings,
    DateTime slotDateTime,
  ) {
    // Filter bookings that match the same hour and minute
    final slotBookings = bookings.where((b) {
      return b.eventDateTime.hour == slotDateTime.hour &&
          b.eventDateTime.minute == slotDateTime.minute &&
          b.status != 'cancelled';
    });

    // Sum up all booked guests for this slot
    final bookedGuests = slotBookings.fold<int>(
      0,
      (sum, booking) => sum + booking.numberOfGuests,
    );

    return maxGuestsPerSlot - bookedGuests;
  }

  /// Get the availability status for a time slot
  static SlotAvailability getAvailability(
    int remainingCapacity,
    int requestedGuests,
  ) {
    if (remainingCapacity <= 0) {
      return SlotAvailability.fullyBooked;
    } else if (remainingCapacity < requestedGuests) {
      return SlotAvailability.insufficientCapacity;
    } else if (remainingCapacity <= warningThreshold) {
      return SlotAvailability.limitedAvailability;
    }
    return SlotAvailability.available;
  }

  /// Get display text for remaining capacity
  static String getCapacityText(int remaining) {
    if (remaining <= 0) {
      return 'Full';
    } else if (remaining <= warningThreshold) {
      return 'Last $remaining spots!';
    }
    return '$remaining spots';
  }

  /// Check if a booking can be made for the given slot and guest count
  static bool canBook(int remainingCapacity, int guestCount) {
    return remainingCapacity >= guestCount && guestCount > 0;
  }
}

/// Availability status for a time slot
enum SlotAvailability {
  /// Slot is available with plenty of room
  available,

  /// Slot is available but running low (≤20 spots)
  limitedAvailability,

  /// Slot doesn't have enough capacity for the requested party size
  insufficientCapacity,

  /// Slot is completely booked
  fullyBooked,
}
