import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/event_service.dart';
import '../services/auth_service.dart';
import '../models/event_model.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  static const String routeName = '/add-event';

  final Event? eventToEdit;

  const AddEventScreen({Key? key, this.eventToEdit}) : super(key: key);

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _requirementsController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategory;
  XFile? _imageFile;
  Uint8List? _imageBytes;
  bool _isFeatured = false;
  bool _isFree = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'Tech',
    'Cultural',
    'Sports',
    'Workshop',
    'Seminar',
    'Social',
    'Academic',
    'Career',
    'General'
  ];

  @override
  void initState() {
    super.initState();

    if (widget.eventToEdit != null) {
      _titleController.text = widget.eventToEdit!.title;
      _descriptionController.text = widget.eventToEdit!.description;
      _venueController.text = widget.eventToEdit!.venue;
      _selectedDate = widget.eventToEdit!.date;
      _selectedTime = TimeOfDay(
        hour: widget.eventToEdit!.time.hour,
        minute: widget.eventToEdit!.time.minute,
      );
      _selectedCategory = widget.eventToEdit!.category;
      _isFeatured = widget.eventToEdit!.isFeatured;
      _isFree = widget.eventToEdit!.isFree;

      if (!widget.eventToEdit!.isFree) {
        _priceController.text = widget.eventToEdit!.price.toString();
      }

      if (widget.eventToEdit!.maxParticipants > 0) {
        _maxParticipantsController.text = widget.eventToEdit!.maxParticipants.toString();
      }

      _requirementsController.text = widget.eventToEdit!.requirements ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _priceController.dispose();
    _maxParticipantsController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kPrimaryColor,
              onPrimary: Colors.black,
              surface: kCardBackground,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: kBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kPrimaryColor,
              onPrimary: Colors.black,
              surface: kCardBackground,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: kBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });

        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          if (mounted) {
            setState(() {
              _imageBytes = bytes;
            });
          }
        }
      }
    } catch (e) {
      _showError('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      _showError('Please select date and time');
      return;
    }

    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final eventService = Provider.of<EventService>(context, listen: false);

      final DateTime date = _selectedDate!;
      final DateTime time = DateTime(
        date.year,
        date.month,
        date.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      File? fileForUpload;
      Uint8List? imageBytes;
      XFile? imageXFile;

      if (_imageFile != null) {
        if (kIsWeb) {
          imageXFile = _imageFile;
          if (_imageBytes != null) {
            imageBytes = _imageBytes;
          } else {
            imageBytes = await _imageFile!.readAsBytes();
          }
        } else {
          fileForUpload = File(_imageFile!.path);
        }
      }

      if (widget.eventToEdit != null) {
        await eventService.updateEvent(
          eventId: widget.eventToEdit!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          venue: _venueController.text.trim(),
          date: date,
          time: time,
          category: _selectedCategory!,
          isFeatured: _isFeatured,
          isFree: _isFree,
          price: _isFree ? 0.0 : double.parse(_priceController.text.trim()),
          maxParticipants: _maxParticipantsController.text.isEmpty
              ? 0
              : int.parse(_maxParticipantsController.text.trim()),
          requirements: _requirementsController.text.trim().isEmpty
              ? null
              : _requirementsController.text.trim(),
          imageFile: fileForUpload,
          imageBytes: imageBytes,
          imageXFile: imageXFile,
        );

        _showSuccess('Event updated successfully!');
      } else {
        await eventService.createEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          venue: _venueController.text.trim(),
          date: date,
          time: time,
          category: _selectedCategory!,
          organizer: authService.currentUser!.uid,
          isFeatured: _isFeatured,
          isFree: _isFree,
          price: _isFree ? 0.0 : double.parse(_priceController.text.trim()),
          maxParticipants: _maxParticipantsController.text.isEmpty
              ? 0
              : int.parse(_maxParticipantsController.text.trim()),
          requirements: _requirementsController.text.trim().isEmpty
              ? null
              : _requirementsController.text.trim(),
          imageFile: fileForUpload,
          imageBytes: imageBytes,
          imageXFile: imageXFile,
        );

        _showSuccess('Event created successfully!');
      }

      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop(true);
      }

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to save event: ${e.toString()}');
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: kPrimaryColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Event',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this event? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        final eventService = Provider.of<EventService>(context, listen: false);
        await eventService.deleteEvent(widget.eventToEdit!.id);

        _showSuccess('Event deleted successfully');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        _showError('Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.eventToEdit != null ? 'Edit Event' : 'Create Event',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: kCardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.eventToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteEvent,
              tooltip: 'Delete Event',
            ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Event Title',
                      hint: 'Enter event title',
                      maxLines: 1,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter event title';
                        }
                        if (value.length < 3) {
                          return 'Title must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Describe your event...',
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        if (value.length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _venueController,
                      label: 'Venue',
                      hint: 'Enter event location',
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter venue';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDateTimePicker(),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),
                    _buildPriceAndCapacity(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _requirementsController,
                      label: 'Requirements (Optional)',
                      hint: 'e.g., Bring laptop, wear sports shoes...',
                      maxLines: 2,
                      validator: (value) => null,
                    ),
                    const SizedBox(height: 16),
                    _buildFeaturedSwitch(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Event Image',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            if (widget.eventToEdit == null || _imageFile != null)
              Text(
                '(Optional)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: kCardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: _imageFile != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: kIsWeb && _imageBytes != null
                  ? Image.memory(
                _imageBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
                  : !kIsWeb
                  ? Image.file(
                File(_imageFile!.path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
                  : Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
              ),
            )
                : widget.eventToEdit != null && widget.eventToEdit!.imageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                widget.eventToEdit!.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: kPrimaryColor,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white.withOpacity(0.5),
                      size: 50,
                    ),
                  );
                },
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_photo_alternate,
                    color: kPrimaryColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to add image',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '(Recommended for better visibility)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
            filled: true,
            fillColor: kCardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            errorStyle: const TextStyle(color: Colors.red),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: kCardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : DateFormat('EEE, MMM d, yyyy').format(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null
                                ? Colors.white.withOpacity(0.5)
                                : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: kCardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedTime == null
                              ? 'Select Time'
                              : _selectedTime!.format(context),
                          style: TextStyle(
                            color: _selectedTime == null
                                ? Colors.white.withOpacity(0.5)
                                : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: kCardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: kPrimaryColor),
              dropdownColor: kCardBackground,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: _categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: categoryColors[value] ?? kPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
              hint: Text(
                'Select Category',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndCapacity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Event Details',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: kCardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(
                _isFree ? Icons.money_off : Icons.attach_money,
                color: kPrimaryColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isFree ? 'Free Event' : 'Paid Event',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: _isFree,
                onChanged: (value) {
                  setState(() {
                    _isFree = value;
                    if (_isFree) {
                      _priceController.clear();
                    }
                  });
                },
                activeColor: kPrimaryColor,
                activeTrackColor: kPrimaryColor.withOpacity(0.5),
                inactiveThumbColor: Colors.white.withOpacity(0.7),
                inactiveTrackColor: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ),
        if (!_isFree) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Price',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              hintText: 'Enter price (e.g., 10.00)',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.attach_money, color: kPrimaryColor),
              filled: true,
              fillColor: kCardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimaryColor, width: 2),
              ),
            ),
            validator: (value) {
              if (!_isFree && (value == null || value.isEmpty)) {
                return 'Please enter price for paid event';
              }
              if (!_isFree && double.tryParse(value!) == null) {
                return 'Please enter a valid price';
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 12),
        TextFormField(
          controller: _maxParticipantsController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Max Participants (Optional)',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            hintText: 'Leave empty for unlimited',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIcon: const Icon(Icons.people, color: kPrimaryColor),
            filled: true,
            fillColor: kCardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final intValue = int.tryParse(value);
              if (intValue == null || intValue < 0) {
                return 'Please enter a valid number';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: _isFeatured ? kPrimaryColor : Colors.white.withOpacity(0.5),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Featured Event',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Featured events appear at the top of the home screen',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isFeatured,
            onChanged: (value) {
              setState(() {
                _isFeatured = value;
              });
            },
            activeColor: kPrimaryColor,
            activeTrackColor: kPrimaryColor.withOpacity(0.5),
            inactiveThumbColor: Colors.white.withOpacity(0.7),
            inactiveTrackColor: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitEvent,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.eventToEdit != null ? Icons.update : Icons.add,
            color: Colors.black,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.eventToEdit != null ? 'Update Event' : 'Create Event',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}