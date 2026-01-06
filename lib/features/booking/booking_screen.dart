import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models.dart';
import '../../data/repositories.dart';
import '../../core/glass_widgets.dart';
import '../../core/validators.dart';
import '../../core/logger.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final MenuPackage package;
  final Booking? existingBooking;

  const BookingScreen({super.key, required this.package, this.existingBooking});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

  // State
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  int _guestCount = 2;

  // Validation states
  bool _dateSelected = true; // Default is tomorrow, so valid
  bool _timeSelected = false;
  String? _timeError;

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  // Dietary
  final List<String> _dietaryOptions = [
    'None',
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Halal',
    'Kosher',
  ];
  final Set<String> _selectedDietary = {'None'};

  // Guest count limits
  static const int _minGuests = 1;
  static const int _maxGuests = 35; // Updated to 35 for convenience

  // Loading

  bool _isLoading = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      if (widget.existingBooking != null) {
        _initializeFromBooking(widget.existingBooking!);
      } else {
        _selectedDate = DateTime.now().add(const Duration(days: 1));
        _loadUserData();
      }
      _isInit = false;
    }
  }

  void _initializeFromBooking(Booking booking) {
    _selectedDate = booking.eventDateTime;
    _selectedTime = TimeOfDay.fromDateTime(booking.eventDateTime);
    _guestCount = booking.numberOfGuests;

    // Parse special requests for Contact and Dietary
    // Format: "Contact: Name (Phone)\nContact Info...\nDietary: Valid, List"
    final requestText = booking.specialRequests ?? '';

    // Simple contact parsing logic (imperfect but functional for this app context)
    final contactRegex = RegExp(r'Contact: (.*) \((.*)\)');
    final match = contactRegex.firstMatch(requestText);
    if (match != null) {
      _nameController.text = match.group(1) ?? '';
      _phoneController.text = match.group(2) ?? '';
    }

    // Dietary parsing
    if (requestText.contains('Dietary:')) {
      final dietaryPart = requestText.split('Dietary:')[1].split('\n')[0];
      final dietaryItems = dietaryPart.split(',').map((e) => e.trim());
      _selectedDietary.clear();
      _selectedDietary.addAll(
        dietaryItems.where((e) => _dietaryOptions.contains(e)),
      );
      if (_selectedDietary.isEmpty) _selectedDietary.add('None');
    }

    // Remaining special requests (strip out known prefixes if possible, or just load all)
    // For simplicity, we just load the whole thing into the controller but cleaning it would be better.
    // Let's try to strip the Contact line and Dietary line to avoid duplication on re-save
    String cleanRequests = requestText;
    cleanRequests = cleanRequests.replaceAll(RegExp(r'Contact: .*\n?'), '');
    cleanRequests = cleanRequests.replaceAll(RegExp(r'Dietary: .*\n?'), '');
    _specialRequestsController.text = cleanRequests.trim();
  }

  Future<void> _loadUserData() async {
    final user = await ref.read(authRepositoryProvider).getCurrentUserData();
    if (user != null) {
      if (mounted) {
        setState(() {
          _nameController.text = user.name ?? '';
          _phoneController.text = user.phoneNumber ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  // Logic
  double get _serviceCharge =>
      (widget.package.pricePerGuest * _guestCount) * 0.10;
  double get _totalPrice =>
      (widget.package.pricePerGuest * _guestCount) + _serviceCharge;

  void _incrementGuests() {
    if (_guestCount < _maxGuests) {
      setState(() => _guestCount++);
    } else {
      _showErrorSnackBar("You can't add more than $_maxGuests guests.");
    }
  }

  void _decrementGuests() {
    if (_guestCount > _minGuests) setState(() => _guestCount--);
  }

  /// Validate phone number format (Malaysian format supported)
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Remove spaces and dashes for validation
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    // Malaysian phone: starts with 01, 10-11 digits OR international format
    final phoneRegex = RegExp(r'^(\+?6?01[0-9]{8,9}|01[0-9]{8,9})$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Enter a valid phone number (e.g., 012-3456789)';
    }
    return null;
  }

  /// Validate name field
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Name is too long';
    }
    return null;
  }

  Future<void> _submitBooking() async {
    // Clear previous time error
    setState(() => _timeError = null);

    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fill in all required fields correctly.');
      return;
    }

    // Validate time selection
    if (_selectedTime == null) {
      setState(() => _timeError = 'Please select a dining time');
      _showErrorSnackBar('Please select a dining time');
      return;
    }

    // Validate guest count
    if (_guestCount < _minGuests || _guestCount > _maxGuests) {
      _showErrorSnackBar(
        'Guest count must be between $_minGuests and $_maxGuests',
      );
      return;
    }

    // Validate date is not in the past
    final eventDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (eventDateTime.isBefore(DateTime.now())) {
      _showErrorSnackBar('Please select a future date and time');
      return;
    }

    setState(() => _isLoading = true);

    AppLogger.booking(
      'Submitting booking',
      packageName: widget.package.name,
      guestCount: _guestCount,
    );

    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUserData();
      if (user == null) {
        AppLogger.warning('Booking attempt without authentication');
        if (mounted) {
          _showErrorSnackBar('Please sign in to complete your booking.');
          // Navigate to login
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) context.push('/login');
          });
        }
        return;
      }

      // Sanitize user inputs before creating booking
      final sanitizedName = InputSanitizers.sanitizeName(_nameController.text);
      final sanitizedPhone = InputSanitizers.sanitizePhone(
        _phoneController.text,
      );
      final sanitizedRequests = InputSanitizers.sanitizeSpecialRequests(
        _specialRequestsController.text,
      );

      // Combine dietary info into special requests for simplicity or append
      String finalRequests = sanitizedRequests;
      if (_selectedDietary.isNotEmpty && !_selectedDietary.contains('None')) {
        final dietaryString = "Dietary: ${_selectedDietary.join(', ')}";
        finalRequests = finalRequests.isEmpty
            ? dietaryString
            : "$finalRequests\n$dietaryString";
      }
      // Prepend contact info to special requests to ensure the admin sees it
      final contactInfo = "Contact: $sanitizedName ($sanitizedPhone)";
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
        totalPrice: _totalPrice,
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
        _showErrorSnackBar(message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          widget.existingBooking != null
              ? 'Booking Updated'
              : 'Reservation Confirmed',
        ),
        content: const Text(
          'We have received your booking request. Our team will verify the details and confirm shortly.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/bookings');
            },
            child: const Text('Return Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: widget.existingBooking != null
            ? 'Update Reservation'
            : 'Complete Reservation',
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.package.imageUrl),
            fit: BoxFit.cover,
            opacity: 0.2, // Darken background to let glass pop
          ),
          color: theme.scaffoldBackgroundColor, // Fallback/Blend
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPackageHeader(theme),
                  const SizedBox(height: 24),
                  _buildDateSelector(theme),
                  const SizedBox(height: 24),
                  _buildTimeSelector(theme),
                  const SizedBox(height: 24),
                  _buildGuestCounter(theme),
                  const SizedBox(height: 24),
                  _buildContactDetails(theme),
                  const SizedBox(height: 24),
                  _buildDietaryOptions(theme),
                  const SizedBox(height: 24),
                  _buildPriceSummary(theme),
                  const SizedBox(height: 32),
                  _buildSubmitButton(theme),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageHeader(ThemeData theme) {
    final formatCurrency = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
    );

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.package.imageUrl,
              height: 100,
              width: 100,
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${formatCurrency.format(widget.package.pricePerGuest)} per guest",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                // Simple availability tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    "Available",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text("Select Date", style: theme.textTheme.titleMedium),
              const SizedBox(width: 4),
              Text(
                "*",
                style: TextStyle(color: Colors.red.shade400, fontSize: 16),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 85,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 30, // Next 30 days for more flexibility
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index + 1));
              final isSelected = DateUtils.isSameDay(date, _selectedDate);
              final isWeekend =
                  date.weekday == DateTime.saturday ||
                  date.weekday == DateTime.sunday;

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDate = date;
                  _dateSelected = true;
                }),
                child: GlassContainer(
                  color: isSelected
                      ? theme.primaryColor
                      : const Color(0xFFE0F7FA),
                  opacity: isSelected ? 0.3 : 0.05,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  border: isSelected
                      ? Border.all(color: theme.primaryColor, width: 2)
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isWeekend && !isSelected
                              ? const Color(0xFFFFD700)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d').format(date),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(date),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Row(
            children: [
              const Icon(Icons.event, size: 16, color: Colors.white54),
              const SizedBox(width: 6),
              Text(
                DateFormat('EEEE, d MMMM y').format(_selectedDate),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(ThemeData theme) {
    // Available time slots: 6:00 PM to 9:30 PM
    final slots = [
      const TimeOfDay(hour: 18, minute: 0),
      const TimeOfDay(hour: 18, minute: 30),
      const TimeOfDay(hour: 19, minute: 0),
      const TimeOfDay(hour: 19, minute: 30),
      const TimeOfDay(hour: 20, minute: 0),
      const TimeOfDay(hour: 20, minute: 30),
      const TimeOfDay(hour: 21, minute: 0),
      const TimeOfDay(hour: 21, minute: 30),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text("Select Time", style: theme.textTheme.titleMedium),
              const SizedBox(width: 4),
              Text(
                "*",
                style: TextStyle(color: Colors.red.shade400, fontSize: 16),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: slots.map((time) {
            final isSelected = _selectedTime == time;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedTime = time;
                _timeSelected = true;
                _timeError = null;
              }),
              child: GlassContainer(
                color: isSelected
                    ? theme.primaryColor
                    : const Color(0xFFE0F7FA),
                opacity: isSelected ? 0.3 : 0.05,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: isSelected
                    ? Border.all(color: theme.primaryColor, width: 2)
                    : (_timeError != null
                          ? Border.all(color: Colors.red.shade400, width: 1)
                          : null),
                child: Text(
                  time.format(context),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Error message for time
        if (_timeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _timeError!,
              style: TextStyle(color: Colors.red.shade400, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildGuestCounter(ThemeData theme) {
    final isAtMin = _guestCount <= _minGuests;
    final isAtMax = _guestCount >= _maxGuests;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Number of Guests",
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "*",
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Min: $_minGuests • Max: $_maxGuests attendees",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: isAtMin ? null : _decrementGuests,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: isAtMin ? Colors.grey : theme.iconTheme.color,
                    tooltip: 'Decrease guests',
                  ),
                  Container(
                    width: 50,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_guestCount',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: isAtMax ? null : _incrementGuests,
                    icon: const Icon(Icons.add_circle_outline),
                    color: isAtMax ? Colors.grey : theme.primaryColor,
                    tooltip: 'Increase guests',
                  ),
                ],
              ),
            ],
          ),
          // Quick select buttons
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [2, 4, 6, 8, 10, 15, 20].map((count) {
                final isSelected = _guestCount == count;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _guestCount = count),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primaryColor.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? theme.primaryColor
                              : Colors.white24,
                        ),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: isSelected
                              ? theme.primaryColor
                              : Colors.white70,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text("Contact Details", style: theme.textTheme.titleMedium),
              const SizedBox(width: 4),
              Text(
                "*",
                style: TextStyle(color: Colors.red.shade400, fontSize: 16),
              ),
            ],
          ),
        ),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                style: theme.textTheme.bodyMedium,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'Enter your full name',
                ),
                validator: _validateName,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                style: theme.textTheme.bodyMedium,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '012-3456789',
                ),
                validator: _validatePhone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDietaryOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Dietary Requirements",
            style: theme.textTheme.titleMedium,
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _dietaryOptions.map((option) {
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
                    if (_selectedDietary.isEmpty) _selectedDietary.add('None');
                  }
                });
              },
              backgroundColor: theme.cardColor.withValues(alpha: 0.5),
              selectedColor: theme.primaryColor.withValues(alpha: 0.3),
              checkmarkColor: theme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.primaryColor
                    : theme.textTheme.bodyMedium?.color,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextFormField(
            controller: _specialRequestsController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Any specific allergies or other requests?',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(ThemeData theme) {
    final formatCurrency = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
    );

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      color: Colors.black, // Darker background for summary
      opacity: 0.3,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal", style: theme.textTheme.bodyMedium),
              Text(
                formatCurrency.format(
                  widget.package.pricePerGuest * _guestCount,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Service Charge (10%)", style: theme.textTheme.bodyMedium),
              Text(formatCurrency.format(_serviceCharge)),
            ],
          ),
          const Divider(height: 24, color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatCurrency.format(_totalPrice),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedScale(
        scale: _isLoading ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shadowColor: theme.primaryColor.withValues(alpha: 0.5),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isLoading ? null : _submitBooking,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.black)
              : Text(
                  widget.existingBooking != null
                      ? "UPDATE BOOKING"
                      : "CONFIRM BOOKING",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
