import 'package:flutter/material.dart';
import '../models/device.dart';
import '../widgets/device_card.dart';
import '../widgets/add_device_dialog.dart';
import '../theme/app_theme.dart';
import 'device_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<SmartDevice> devices = [
    SmartDevice(id: '1', name: 'Living Room Light', type: 'Light', room: 'Living Room', isOn: true, value: 0.8),
    SmartDevice(id: '2', name: 'Bedroom Fan', type: 'Fan', room: 'Bedroom', isOn: false, value: 0.5),
    SmartDevice(id: '3', name: 'Kitchen AC', type: 'AC', room: 'Kitchen', isOn: true, value: 0.6),
    SmartDevice(id: '4', name: 'Front Camera', type: 'Camera', room: 'Garage', isOn: true, value: 1.0),
    SmartDevice(id: '5', name: 'Study Lamp', type: 'Light', room: 'Study Room', isOn: false, value: 0.7),
    SmartDevice(id: '6', name: 'Garage Light', type: 'Light', room: 'Garage', isOn: true, value: 1.0),
  ];

  void _toggleDevice(int index) {
    setState(() {
      devices[index] = devices[index].copyWith(isOn: !devices[index].isOn);
    });
  }

  void _addNewDevice() {
    showDialog(
      context: context,
      builder: (context) => AddDeviceDialog(
        onDeviceAdded: (newDevice) {
          setState(() {
            devices.add(newDevice);
          });
        },
      ),
    );
  }

  void _updateDeviceValue(int index, double newValue) {
    setState(() {
      devices[index] = devices[index].copyWith(value: newValue);
    });
  }

  void _deleteDevice(int index) {
    setState(() {
      devices.removeAt(index);
    });
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuOption(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, 'Settings opened');
              },
            ),
            _buildMenuOption(
              icon: Icons.room_preferences,
              title: 'Room Management',
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, 'Room Management opened');
              },
            ),
            _buildMenuOption(
              icon: Icons.analytics,
              title: 'Device Statistics',
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, 'Device Statistics opened');
              },
            ),
            _buildMenuOption(
              icon: Icons.schedule,
              title: 'Schedules & Timers',
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, 'Schedules & Timers opened');
              },
            ),
            _buildMenuOption(
              icon: Icons.security,
              title: 'Security Settings',
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, 'Security Settings opened');
              },
            ),
            _buildMenuOption(
              icon: Icons.energy_savings_leaf,
              title: 'Energy Usage',
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, 'Energy Usage opened');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: const TextStyle(color: AppTheme.textColor)),
      onTap: onTap,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int _calculateGridCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 4;
    if (screenWidth > 800) return 3;
    if (screenWidth > 600) return 2;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildDeviceGrid(isPortrait),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDevice,
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _showMenu(context),
          ),
          const Expanded(
            child: Text(
              'Smart Home Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceGrid(bool isPortrait) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateGridCrossAxisCount(context);

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isPortrait ? 0.9 : 1.2,
          ),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            return DeviceCard(
              device: devices[index],
              onTap: () => _navigateToDetailScreen(context, index),
              onToggle: () => _toggleDevice(index),
              onLongPress: () => _deleteDevice(index),
            );
          },
        );
      },
    );
  }

  void _navigateToDetailScreen(BuildContext context, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DeviceDetailScreen(
          device: devices[index],
          onValueChanged: (newValue) => _updateDeviceValue(index, newValue),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }
}