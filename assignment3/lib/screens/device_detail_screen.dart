import 'package:flutter/material.dart';
import '../models/device.dart';
import '../theme/app_theme.dart';

class DeviceDetailScreen extends StatefulWidget {
  final SmartDevice device;
  final Function(double) onValueChanged;

  const DeviceDetailScreen({
    super.key,
    required this.device,
    required this.onValueChanged,
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  late double currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.device.value;
  }

  IconData _getDeviceIcon() {
    // Using standard Flutter icons that actually exist
    switch (widget.device.type) {
      case 'Light':
        return widget.device.isOn ? Icons.lightbulb : Icons.lightbulb_outline;
      case 'Fan':
        return Icons.air; // Using 'air' icon for fan
      case 'AC':
        return Icons.ac_unit;
      case 'Camera':
        return widget.device.isOn ? Icons.videocam : Icons.videocam_off;
      default:
        return Icons.device_unknown;
    }
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
              _buildAppBar(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _buildContent(isPortrait),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            widget.device.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent(bool isPortrait) {
    if (isPortrait) {
      return _buildPortraitLayout();
    } else {
      return _buildLandscapeLayout();
    }
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildDeviceIcon(),
          const SizedBox(height: 24),
          _buildStatusInfo(),
          const SizedBox(height: 32),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDeviceIcon(),
                const SizedBox(height: 24),
                _buildStatusInfo(),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: widget.device.isOn
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF06D6A0)],
        )
            : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey, Color(0xFF424242)],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(_getDeviceIcon(), size: 50, color: Colors.white),
    );
  }

  Widget _buildStatusInfo() {
    return Column(
      children: [
        Text(
          widget.device.isOn ? '${widget.device.type} is ON' : '${widget.device.type} is OFF',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: widget.device.isOn ? AppTheme.accentColor : Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Room: ${widget.device.room}',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    if (widget.device.type == 'Camera') {
      return _buildCameraControls();
    } else {
      return _buildDeviceControls();
    }
  }

  Widget _buildDeviceControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${widget.device.type == 'Light' ? 'Brightness' : widget.device.type == 'Fan' ? 'Speed' : 'Temperature'}: ${(currentValue * 100).toInt()}%',
          style: const TextStyle(fontSize: 18, color: AppTheme.textColor),
        ),
        const SizedBox(height: 20),
        Slider(
          value: currentValue,
          onChanged: widget.device.isOn
              ? (value) {
            setState(() {
              currentValue = value;
            });
            widget.onValueChanged(value);
          }
              : null,
          divisions: 10,
          min: 0.0,
          max: 1.0,
          activeColor: AppTheme.accentColor,
          inactiveColor: const Color(0xFF475569),
          label: '${(currentValue * 100).toInt()}%',
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton('25%', 0.25),
            _buildControlButton('50%', 0.5),
            _buildControlButton('75%', 0.75),
            _buildControlButton('100%', 1.0),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton(String label, double value) {
    return ElevatedButton(
      onPressed: widget.device.isOn
          ? () {
        setState(() {
          currentValue = value;
        });
        widget.onValueChanged(value);
      }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildCameraControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentColor, width: 2),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(Icons.videocam, color: Colors.white, size: 50),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCameraButton(Icons.record_voice_over, 'Record'),
            _buildCameraButton(Icons.photo_camera, 'Capture'),
            _buildCameraButton(Icons.fullscreen, 'Fullscreen'),
          ],
        ),
      ],
    );
  }

  Widget _buildCameraButton(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30),
          color: AppTheme.accentColor,
          onPressed: () {},
        ),
        Text(label, style: const TextStyle(color: AppTheme.textColor)),
      ],
    );
  }
}