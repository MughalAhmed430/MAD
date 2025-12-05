import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import 'login_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  String _currentName = '';
  UserModel? _currentUserData;
  List<Event> _favoriteEvents = [];
  int _favoritesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFavorites();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final user = await authService.currentUserData
          .first
          .timeout(const Duration(seconds: 5));

      if (user != null) {
        _currentName = user.name;
        _currentUserData = user;
        _nameController.text = user.name;
        setState(() {});
      }
    } catch (e) {
      print('Timeout or error loading user data: $e');
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && _currentUserData == null) {
        setState(() {
          _currentUserData = UserModel(
            uid: currentUser.uid,
            name: currentUser.displayName ?? 'User',
            email: currentUser.email ?? '',
            profileImage: currentUser.photoURL,
            favoriteEvents: [],
            registeredEvents: [],
          );
        });
      }
    }
  }

  Future<void> _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final eventService = Provider.of<EventService>(context, listen: false);

    try {
      // Get all events first
      final allEvents = await eventService.getEvents().first;

      // Filter for events that are favorited by current user
      final List<Event> favorites = [];

      for (var event in allEvents) {
        final isFavorite = await eventService.isFavorite(event.id, user.uid);
        if (isFavorite) {
          favorites.add(event);
        }
      }

      setState(() {
        _favoriteEvents = favorites;
        _favoritesCount = favorites.length;
      });

      print('✅ Loaded ${favorites.length} favorite events');
    } catch (e) {
      print('🔴 Error loading favorites: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
          });
        } else {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading image...'),
            backgroundColor: Color(0xFF00D1FF),
          ),
        );

        await _updateProfilePicture(pickedFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProfilePicture(XFile imageFile) async {
    try {
      setState(() => isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.updateProfile(profileImage: imageFile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateName() async {
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (newName == _currentName) {
      return;
    }

    try {
      setState(() => isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.updateProfile(name: newName);

      setState(() {
        _currentName = newName;
        if (_currentUserData != null) {
          _currentUserData = _currentUserData!.copyWith(name: newName);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update name: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditNameDialog() {
    _nameController.text = _currentName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF11172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF00FF9C).withOpacity(0.5), width: 1),
        ),
        title: Text(
          'Edit Name',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: const TextStyle(color: Colors.white54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF00FF9C).withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF00FF9C).withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00FF9C)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateName();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF9C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (isLoading) {
      return const CircularProgressIndicator(
        color: Color(0xFF00FF9C),
      );
    }

    if (_selectedImage != null || _selectedImageBytes != null) {
      if (kIsWeb && _selectedImageBytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Image.memory(
            _selectedImageBytes!,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      } else if (!kIsWeb && _selectedImage != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Image.file(
            _selectedImage!,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    if (_currentUserData?.profileImage != null &&
        _currentUserData!.profileImage!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.network(
          _currentUserData!.profileImage!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CircularProgressIndicator(
              color: Color(0xFF00FF9C),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildInitials();
          },
        ),
      );
    }

    return _buildInitials();
  }

  Widget _buildInitials() {
    final initials = _currentUserData?.initials ??
        FirebaseAuth.instance.currentUser?.displayName?[0] ??
        'U';

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D1FF).withOpacity(0.8),
            const Color(0xFF00FF9C).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0F1E),
        body: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00FF9C),
          ),
        )
            : Column(
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D1FF).withOpacity(0.8),
                    const Color(0xFF00FF9C).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: _buildProfileImage(),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00FF9C),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentUserData?.name ??
                                  FirebaseAuth.instance.currentUser?.displayName ??
                                  'User',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(color: Color(0xFF00FF9C), blurRadius: 12)
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _showEditNameDialog,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00D1FF).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Color(0xFF00FF9C),
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _currentUserData?.email ??
                              FirebaseAuth.instance.currentUser?.email ??
                              '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Stats Cards Row - Much Better Design
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Your Activity',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.favorite,
                                  title: 'Favorites',
                                  value: _favoritesCount.toString(),
                                  color: Colors.pinkAccent,
                                  isActive: true,
                                  onTap: () {
                                    if (_favoriteEvents.isNotEmpty) {
                                      _showFavoriteEventsDialog();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('You have no favorite events yet'),
                                          backgroundColor: Colors.blue,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.event_available,
                                  title: 'Registered',
                                  value: '0',
                                  color: const Color(0xFF00D1FF),
                                  isActive: false,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Event registration feature coming soon!'),
                                        backgroundColor: Color(0xFF00D1FF),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildSectionTitle('Account Settings'),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      subtitle: 'Update your name and profile picture',
                      color: const Color(0xFF00D1FF),
                      onTap: _showEditNameDialog,
                    ),
                    const SizedBox(height: 10),
                    _buildMenuCard(
                      icon: Icons.security,
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      color: const Color(0xFF00FF9C),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Change password feature coming soon!'),
                            backgroundColor: Color(0xFF00D1FF),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildMenuCard(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Manage your notification settings',
                      color: Colors.amber,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification settings coming soon!'),
                            backgroundColor: Colors.amber,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                    _buildSectionTitle('App Info'),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      icon: Icons.info,
                      title: 'About App',
                      subtitle: 'Version 1.0.0 • Campus Event Planner',
                      color: Colors.purpleAccent,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF11172A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: const Color(0xFF00FF9C).withOpacity(0.5), width: 1),
                            ),
                            title: Text(
                              'About Campus Event Planner',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Version 1.0.0',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'A modern campus event management app with neon theme. Manage events, favorites, and more in style.',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Close',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF00FF9C),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // Logout Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withOpacity(0.2),
                            Colors.red.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.logout, color: Colors.red),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Logout',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Sign out from your account',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _logout,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.withOpacity(0.5)),
                              ),
                              child: Text(
                                'Sign Out',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF00FF9C),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color.withOpacity(0.3) : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.2) : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? color : color.withOpacity(0.5),
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isActive ? color : Colors.white60,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isActive)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Coming Soon',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white38,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showFavoriteEventsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF11172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.pinkAccent.withOpacity(0.5), width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.pinkAccent),
            const SizedBox(width: 10),
            Text(
              'Favorite Events ($_favoritesCount)',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _favoriteEvents.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 50,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 15),
                Text(
                  'No favorite events',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Start adding favorites from events!',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.5),  // FIXED
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: _favoriteEvents.length,
            itemBuilder: (context, index) {
              final event = _favoriteEvents[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  // You might want to navigate to event details here
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(event.category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.event,
                            color: _getCategoryColor(event.category),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(event.category).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    event.category,
                                    style: GoogleFonts.poppins(
                                      color: _getCategoryColor(event.category),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  event.formattedDate,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.3),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'tech':
        return const Color(0xFF00D1FF);
      case 'cultural':
        return const Color(0xFF00FF9C);
      case 'sports':
        return Colors.orange;
      case 'workshop':
        return Colors.purpleAccent;
      case 'seminar':
        return Colors.pinkAccent;
      default:
        return const Color(0xFF00D1FF);
    }
  }
}