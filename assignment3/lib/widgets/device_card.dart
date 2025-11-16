import 'package:flutter/material.dart';
import '../models/device.dart';
import '../theme/app_theme.dart';

class DeviceCard extends StatelessWidget {
  final SmartDevice device;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback? onLongPress;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    required this.onToggle,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Card(
          child: Container(
            decoration: BoxDecoration(
              gradient: device.isOn
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.3),
                  AppTheme.accentColor.withOpacity(0.1),
                ],
              )
                  : AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDeviceIcon(),
                  _buildDeviceInfo(),
                  _buildToggleSwitch(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceIcon() {
    IconData icon;
    Color color = device.isOn ? AppTheme.accentColor : AppTheme.textSecondaryColor;

    // Using standard Flutter icons that actually exist
    switch (device.type) {
      case 'Light':
        icon = device.isOn ? Icons.lightbulb : Icons.lightbulb_outline;
        break;
      case 'Fan':
        icon = Icons.air; // Using 'air' icon for fan
        break;
      case 'AC':
        icon = Icons.ac_unit;
        break;
      case 'Camera':
        icon = device.isOn ? Icons.videocam : Icons.videocam_off;
        break;
      default:
        icon = Icons.device_unknown;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: device.isOn ? AppTheme.accentColor.withOpacity(0.2) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Icon(icon, size: 30, color: color),
    );
  }

  Widget _buildDeviceInfo() {
    return Column(
      children: [
        Text(
          device.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          device.room,
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          device.isOn ? '${device.type} is ON' : '${device.type} is OFF',
          style: TextStyle(
            color: device.isOn ? AppTheme.accentColor : Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSwitch() {
    return Transform.scale(
      scale: 1.2,
      child: Switch.adaptive(
        value: device.isOn,
        onChanged: (value) => onToggle(),
        activeColor: AppTheme.accentColor,
        activeTrackColor: AppTheme.accentColor.withOpacity(0.5),
      ),
    );
  }
}