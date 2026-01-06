import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/glass_widgets.dart';
import '../../core/animations.dart';
import '../../core/responsive.dart';
import '../../core/notifications.dart';
import '../../core/validators.dart';
import '../../core/logger.dart';
import '../../core/booking_capacity.dart';
import '../../data/repositories.dart';
import '../../domain/models.dart';

// UI PAGE: Complex multi-step wizard for creating/editing bookings.
// FEATURES: Animations, Real-time Validation, Capacity Checking
class MultiStepBookingScreen extends ConsumerStatefulWidget {
  final MenuPackage package;
  final Booking? existingBooking;

  const MultiStepBookingScreen({
    super.key,
    required this.package,
    this.existingBooking,
  });

  @override
  ConsumerState<MultiStepBookingScreen> createState() =>
      _MultiStepBookingScreenState();
}

class _MultiStepBookingScreenState extends ConsumerState<MultiStepBookingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;

  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form data
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  int _guestCount = 2;
  static const int kMaxGuests = BookingCapacity.maxGuestsPerBooking;

  // LOGIC: Real-time capacity data from Firestore
  List<Booking> _dateBookings = [];
  bool _isLoadingSlots = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  final Set<String> _selectedDietary = {'None'};

  bool _isLoading = false;
  // STATE: Keys for validating individual steps
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  final List<String> _dietaryOptions = [
    'None',
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Halal',
    'Kosher',
    'Dairy-Free',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _loadInitialData();
    _loadBookingsForDate(_selectedDate);
  }

  Future<void> _loadInitialData() async {
    if (widget.existingBooking != null) {
      _initializeFromBooking(widget.existingBooking!);
    } else {
      final user = await ref.read(authRepositoryProvider).getCurrentUserData();
      if (user != null && mounted) {
        setState(() {
          _nameController.text = user.name ?? '';
          _phoneController.text = user.phoneNumber ?? '';
          _emailController.text = user.email;
        });
      }
    }
  }

  /// Load bookings for the selected date to calculate availability
  // DATABASE LOGIC: Fetch existing bookings to prevent overbooking
  Future<void> _loadBookingsForDate(DateTime date) async {
    if (!mounted) return;
    setState(() => _isLoadingSlots = true);

    try {
      final bookings = await ref
          .read(databaseRepositoryProvider)
          .getBookingsForDate(date);
      if (mounted) {
        setState(() {
          _dateBookings = bookings;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to load availability', error: e);
      if (mounted) {
        setState(() => _isLoadingSlots = false);
      }
    }
  }

  /// Get remaining capacity for a specific time slot
  int _getRemainingCapacity(TimeOfDay time) {
    final slotDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      time.hour,
      time.minute,
    );
    return BookingCapacity.getRemainingCapacity(_dateBookings, slotDateTime);
  }

  void _initializeFromBooking(Booking booking) {
    _selectedDate = booking.eventDateTime;
    _selectedTime = TimeOfDay.fromDateTime(booking.eventDateTime);
    _guestCount = booking.numberOfGuests;
    // Parse contact from special requests if needed
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  double get _progress => (_currentStep + 1) / _totalSteps;

  void _nextStep() {
    // Validate current step
    if (_currentStep < 3 && !_validateStep(_currentStep)) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeOutCubic);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: 400.ms,
        curve: Curves.easeOutCubic,
      );
    }
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0: // Date & Time
        if (_selectedTime == null) {
          LuxeToast.warning(context, 'Please select a dining time');
          return false;
        }
        return true;
      case 1: // Guests
        if (_guestCount < 1 || _guestCount > 50) {
          LuxeToast.warning(context, 'Guest count must be between 1 and 50');
          return false;
        }
        return true;
      case 2: // Contact
        return _formKeys[2].currentState?.validate() ?? false;
      default:
        return true;
    }
  }

  double get _subtotal => widget.package.pricePerGuest * _guestCount;
  double get _serviceCharge => _subtotal * 0.10;
  double get _total => _subtotal + _serviceCharge;

  Future<void> _submitBooking() async {
    setState(() => _isLoading = true);

    // ANALYTICS/LOGGING: Track booking attempts

    AppLogger.booking(
      'Submitting booking',
      packageName: widget.package.name,
      guestCount: _guestCount,
    );

    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUserData();
      if (user == null) {
        AppLogger.warning('Booking attempt without authentication');
        LuxeToast.error(context, 'Please sign in to complete your booking');
        context.push('/login');
        return;
      }

      // LOGIC: Double-check capacity before submitting (prevent race conditions)
      final freshBookings = await ref
          .read(databaseRepositoryProvider)
          .getBookingsForDate(_selectedDate);
      final slotDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final remaining = BookingCapacity.getRemainingCapacity(
        freshBookings,
        slotDateTime,
      );

      if (remaining < _guestCount) {
        if (mounted) {
          if (remaining <= 0) {
            LuxeToast.error(
              context,
              'This time slot is now fully booked. Please select another time.',
            );
          } else {
            LuxeToast.error(
              context,
              'Only $remaining spots left for this time. Please reduce your party size or select another time.',
            );
          }
          // Go back to date/time step
          setState(() => _currentStep = 0);
          _pageController.animateToPage(
            0,
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          );
          _loadBookingsForDate(_selectedDate); // Refresh availability
        }
        return;
      }

      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // SECURITY: Sanitize user inputs to prevent injection/XSS (Good Practice)
      final sanitizedName = InputSanitizers.sanitizeName(_nameController.text);
      final sanitizedPhone = InputSanitizers.sanitizePhone(
        _phoneController.text,
      );
      final sanitizedEmail = InputSanitizers.sanitizeEmail(
        _emailController.text,
      );
      final sanitizedRequests = InputSanitizers.sanitizeSpecialRequests(
        _specialRequestsController.text,
      );

      String finalRequests = sanitizedRequests;
      if (_selectedDietary.isNotEmpty && !_selectedDietary.contains('None')) {
        final dietaryString = "Dietary: ${_selectedDietary.join(', ')}";
        finalRequests = finalRequests.isEmpty
            ? dietaryString
            : "$finalRequests\n$dietaryString";
      }
      final contactInfo =
          "Contact: $sanitizedName ($sanitizedPhone) - $sanitizedEmail";
      finalRequests = "$contactInfo\n$finalRequests";

      final bookingId = widget.existingBooking?.id ?? const Uuid().v4();
      final booking = Booking(
        id: bookingId,
        userId: user.id,
        menuPackageId: widget.package.id,
        menuPackageName: widget.package.name,
        packageImageUrl: widget.package.imageUrl,
        eventDateTime: eventDateTime,
        numberOfGuests: _guestCount,
        basePricePerGuest: widget.package.pricePerGuest,
        serviceCharge: _serviceCharge,
        totalPrice: _total,
        specialRequests: finalRequests,
        createdAt: widget.existingBooking?.createdAt ?? DateTime.now(),
        status: widget.existingBooking?.status ?? 'pending',
      );

      if (widget.existingBooking != null) {
        await ref.read(databaseRepositoryProvider).updateBooking(booking);
        AppLogger.booking('Booking updated', bookingId: bookingId);
      } else {
        await ref.read(databaseRepositoryProvider).createBooking(booking);
        AppLogger.booking(
          'Booking created',
          bookingId: bookingId,
          eventDate: eventDateTime,
        );
      }

      // UI: Success Feedback
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Booking submission failed',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        // Show user-friendly error message
        final message = e.toString().contains('permission')
            ? 'Unable to save booking. Please try again.'
            : 'Something went wrong. Please try again.';
        LuxeToast.error(context, message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          Dialog(
            backgroundColor: Colors.transparent,
            child: GlassContainer(
              padding: const EdgeInsets.all(32),
              borderRadius: BorderRadius.circular(24),
              blur: 20,
              opacity: 0.2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Color(0xFF4CAF50),
                    ),
                  ).animate().scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.existingBooking != null
                        ? 'Booking Updated!'
                        : 'Reservation Confirmed!',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your table has been reserved. We\'ll send you a confirmation shortly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.go('/bookings');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'VIEW MY RESERVATIONS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn().scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
            duration: 300.ms,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: widget.existingBooking != null
            ? 'Edit Reservation'
            : 'Book Experience',
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.package.imageUrl),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Progress indicator
        _buildProgressHeader(),
        // Page content
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildDateTimeStep(),
              _buildGuestsStep(),
              _buildContactStep(),
              _buildReviewStep(),
            ],
          ),
        ),
        // Navigation buttons
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildProgressHeader(),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildDateTimeStep(),
                        _buildGuestsStep(),
                        _buildContactStep(),
                        _buildReviewStep(),
                      ],
                    ),
                  ),
                  _buildNavigationButtons(),
                ],
              ),
            ),
            // Summary sidebar
            SizedBox(width: 350, child: _buildSummarySidebar()),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final steps = ['Date & Time', 'Guests', 'Details', 'Review'];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: 300.ms,
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? const Color(0xFFD4AF37)
                                  : isCurrent
                                  ? const Color(0xFFD4AF37).withOpacity(0.3)
                                  : Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCurrent || isCompleted
                                    ? const Color(0xFFD4AF37)
                                    : Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Colors.black,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: isCurrent
                                            ? const Color(0xFFD4AF37)
                                            : Colors.white54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            steps[index],
                            style: TextStyle(
                              fontSize: 12,
                              color: isCurrent ? Colors.white : Colors.white54,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFFD4AF37)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          AnimatedProgress(
            progress: _progress,
            height: 3,
            foregroundColor: const Color(0xFFD4AF37),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeStep() {
    final formatCurrency = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package info
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.package.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.package.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatCurrency.format(widget.package.pricePerGuest)} per guest',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).fadeInUp(),
          const SizedBox(height: 24),

          // Date selection
          Text(
            'Select Date',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).fadeInUp(delay: 100.ms),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 30,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index + 1));
                final isSelected = DateUtils.isSameDay(date, _selectedDate);
                final isWeekend = date.weekday == 6 || date.weekday == 7;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = date);
                    _selectedTime = null; // Reset time when date changes
                    _loadBookingsForDate(date);
                  },
                  child: AnimatedContainer(
                    duration: 200.ms,
                    width: 70,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD4AF37)
                            : Colors.white.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date).toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.black
                                : isWeekend
                                ? const Color(0xFFD4AF37)
                                : Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(date),
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.black54 : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).staggeredItem(index);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Time selection
          Text(
            'Select Time',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).fadeInUp(delay: 200.ms),
          const SizedBox(height: 12),
          _buildTimeSlots(),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    final slots = [
      const TimeOfDay(hour: 12, minute: 0),
      const TimeOfDay(hour: 12, minute: 30),
      const TimeOfDay(hour: 13, minute: 0),
      const TimeOfDay(hour: 18, minute: 0),
      const TimeOfDay(hour: 18, minute: 30),
      const TimeOfDay(hour: 19, minute: 0),
      const TimeOfDay(hour: 19, minute: 30),
      const TimeOfDay(hour: 20, minute: 0),
      const TimeOfDay(hour: 20, minute: 30),
      const TimeOfDay(hour: 21, minute: 0),
    ];

    // Show loading shimmer while fetching availability
    if (_isLoadingSlots) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: slots.map((slot) => _buildSlotShimmer()).toList(),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: slots.asMap().entries.map((entry) {
        final time = entry.value;
        final isSelected = _selectedTime == time;
        final remaining = _getRemainingCapacity(time);
        final availability = BookingCapacity.getAvailability(
          remaining,
          _guestCount,
        );
        final isLunch = time.hour < 15;

        // Determine colors and states based on availability
        Color bgColor;
        Color borderColor;
        Color textColor;
        Color subTextColor;
        bool isDisabled = false;
        String statusText;

        switch (availability) {
          case SlotAvailability.fullyBooked:
            bgColor = Colors.red.withOpacity(0.1);
            borderColor = Colors.red.withOpacity(0.3);
            textColor = Colors.red.withOpacity(0.5);
            subTextColor = Colors.red.withOpacity(0.4);
            statusText = 'Full';
            isDisabled = true;
            break;
          case SlotAvailability.insufficientCapacity:
            bgColor = Colors.amber.withOpacity(0.1);
            borderColor = Colors.amber.withOpacity(0.3);
            textColor = Colors.amber;
            subTextColor = Colors.amber.withOpacity(0.7);
            statusText = 'Only $remaining left';
            isDisabled = true;
            break;
          case SlotAvailability.limitedAvailability:
            bgColor = isSelected
                ? const Color(0xFFD4AF37)
                : const Color(0xFFD4AF37).withOpacity(0.1);
            borderColor = const Color(0xFFD4AF37).withOpacity(0.5);
            textColor = isSelected ? Colors.black : const Color(0xFFD4AF37);
            subTextColor = isSelected
                ? Colors.black54
                : const Color(0xFFD4AF37).withOpacity(0.7);
            statusText = 'Last $remaining!';
            break;
          case SlotAvailability.available:
            bgColor = isSelected
                ? const Color(0xFFD4AF37)
                : Colors.white.withOpacity(0.05);
            borderColor = isSelected
                ? const Color(0xFFD4AF37)
                : Colors.white.withOpacity(0.1);
            textColor = isSelected ? Colors.black : Colors.white;
            subTextColor = isSelected ? Colors.black54 : Colors.white54;
            statusText = isLunch ? 'Lunch' : 'Dinner';
            break;
        }

        return GestureDetector(
          onTap: isDisabled
              ? () {
                  if (availability == SlotAvailability.fullyBooked) {
                    LuxeToast.warning(
                      context,
                      'This time slot is fully booked',
                    );
                  } else {
                    LuxeToast.warning(
                      context,
                      'Only $remaining spots left. Reduce party size to ${remaining} or less.',
                    );
                  }
                }
              : () => setState(() => _selectedTime = time),
          child: AnimatedContainer(
            duration: 200.ms,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  time.format(context),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: availability == SlotAvailability.fullyBooked
                        ? TextDecoration.lineThrough
                        : null,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        availability == SlotAvailability.limitedAvailability
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
        ).staggeredItem(entry.key);
      }).toList(),
    );
  }

  Widget _buildSlotShimmer() {
    return Container(
      width: 90,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How many guests?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).fadeInUp(),
          const SizedBox(height: 8),
          Text(
            'Select the number of people dining',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ).fadeInUp(delay: 50.ms),
          const SizedBox(height: 32),

          // Large guest counter
          GlassContainer(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCounterButton(
                      icon: Icons.remove,
                      onTap: _guestCount > 1
                          ? () => setState(() => _guestCount--)
                          : null,
                    ),
                    const SizedBox(width: 32),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: _guestCount, end: _guestCount),
                      duration: 200.ms,
                      builder: (context, value, child) {
                        return Text(
                          '$_guestCount',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 32),
                    _buildCounterButton(
                      icon: Icons.add,
                      // Interactive validation: Allow click to show error message
                      onTap: () {
                        if (_guestCount >= kMaxGuests) {
                          // Immediate feedback validation
                          LuxeToast.warning(
                            context,
                            "You can't add more than $kMaxGuests guests.",
                          );
                          return;
                        }
                        setState(() => _guestCount++);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _guestCount == 1 ? 'Guest' : 'Guests',
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ],
            ),
          ).fadeInUp(delay: 100.ms),
          const SizedBox(height: 24),

          // Quick select buttons
          Text(
            'Quick Select',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ).fadeInUp(delay: 150.ms),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [2, 4, 6, 8, 10, 12, 15, 20].asMap().entries.map((entry) {
              final count = entry.value;
              final isSelected = _guestCount == count;

              return GestureDetector(
                onTap: () => setState(() => _guestCount = count),
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD4AF37).withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : Colors.white70,
                    ),
                  ),
                ),
              ).staggeredItem(entry.key);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({required IconData icon, VoidCallback? onTap}) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isEnabled
              ? const Color(0xFFD4AF37).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled
                ? const Color(0xFFD4AF37)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          color: isEnabled ? const Color(0xFFD4AF37) : Colors.white30,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildContactStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Details',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).fadeInUp(),
            const SizedBox(height: 8),
            Text(
              'We\'ll use this to send your confirmation',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ).fadeInUp(delay: 50.ms),
            const SizedBox(height: 24),

            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: InputValidators.validateName,
            ).fadeInUp(delay: 100.ms),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ).fadeInUp(delay: 150.ms),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: InputValidators.validatePhone,
            ).fadeInUp(delay: 200.ms),
            const SizedBox(height: 24),

            Text(
              'Dietary Requirements',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).fadeInUp(delay: 250.ms),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dietaryOptions.asMap().entries.map((entry) {
                final option = entry.value;
                final isSelected = _selectedDietary.contains(option);

                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (option == 'None') {
                        _selectedDietary.clear();
                        _selectedDietary.add('None');
                      } else {
                        _selectedDietary.remove('None');
                        if (selected) {
                          _selectedDietary.add(option);
                        } else {
                          _selectedDietary.remove(option);
                        }
                        if (_selectedDietary.isEmpty)
                          _selectedDietary.add('None');
                      }
                    });
                  },
                  backgroundColor: Colors.white.withOpacity(0.05),
                  selectedColor: const Color(0xFFD4AF37).withOpacity(0.2),
                  checkmarkColor: const Color(0xFFD4AF37),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? const Color(0xFFD4AF37)
                        : Colors.white70,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFFD4AF37)
                        : Colors.white.withOpacity(0.1),
                  ),
                );
              }).toList(),
            ).fadeInUp(delay: 300.ms),
            const SizedBox(height: 24),

            _buildTextField(
              controller: _specialRequestsController,
              label: 'Special Requests (Optional)',
              icon: Icons.note_outlined,
              maxLines: 3,
            ).fadeInUp(delay: 350.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    final formatCurrency = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Booking',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).fadeInUp(),
          const SizedBox(height: 24),

          // Booking summary card
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildReviewRow(
                  Icons.restaurant_menu,
                  'Experience',
                  widget.package.name,
                ),
                const Divider(color: Colors.white12, height: 24),
                _buildReviewRow(
                  Icons.calendar_today,
                  'Date',
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                ),
                const Divider(color: Colors.white12, height: 24),
                _buildReviewRow(
                  Icons.access_time,
                  'Time',
                  _selectedTime?.format(context) ?? 'Not selected',
                ),
                const Divider(color: Colors.white12, height: 24),
                _buildReviewRow(
                  Icons.people,
                  'Guests',
                  '$_guestCount ${_guestCount == 1 ? 'person' : 'people'}',
                ),
                const Divider(color: Colors.white12, height: 24),
                _buildReviewRow(Icons.person, 'Contact', _nameController.text),
              ],
            ),
          ).fadeInUp(delay: 100.ms),
          const SizedBox(height: 24),

          // Price breakdown
          GlassContainer(
            padding: const EdgeInsets.all(20),
            color: Colors.black,
            opacity: 0.3,
            child: Column(
              children: [
                _buildPriceRow('Subtotal', formatCurrency.format(_subtotal)),
                const SizedBox(height: 12),
                _buildPriceRow(
                  'Service Charge (10%)',
                  formatCurrency.format(_serviceCharge),
                ),
                const Divider(color: Colors.white24, height: 24),
                _buildPriceRow(
                  'Total',
                  formatCurrency.format(_total),
                  isTotal: true,
                ),
              ],
            ),
          ).fadeInUp(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildReviewRow(IconData icon, String label, String value) {
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
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.white.withOpacity(isTotal ? 1 : 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 24 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFFD4AF37) : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySidebar() {
    final formatCurrency = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
    );

    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Summary',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.package.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.package.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            _buildSummaryItem(
              Icons.calendar_today,
              DateFormat('MMM d, y').format(_selectedDate),
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              Icons.access_time,
              _selectedTime?.format(context) ?? '--:--',
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(Icons.people, '$_guestCount guests'),
            const Spacer(),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(color: Colors.white70)),
                AnimatedPrice(
                  price: _total,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 18),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child:
                  OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back'),
                      )
                      .animate(autoPlay: false, target: 1)
                      .scaleXY(begin: 1, end: 0.98, duration: 100.ms),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AnimatedScale(
              scale: _isLoading ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : isLastStep
                    ? _submitBooking
                    : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        isLastStep ? 'CONFIRM BOOKING' : 'CONTINUE',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
