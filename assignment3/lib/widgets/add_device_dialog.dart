import 'package:flutter/material.dart';
import '../models/device.dart';
import '../theme/app_theme.dart';

class AddDeviceDialog extends StatefulWidget {
  final Function(SmartDevice) onDeviceAdded;

  const AddDeviceDialog({super.key, required this.onDeviceAdded});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String _selectedType = 'Light';
  String _selectedRoom = 'Living Room';
  bool _isOn = false;

  final List<String> deviceTypes = ['Light', 'Fan', 'AC', 'Camera'];
  final List<String> rooms = ['Living Room', 'Bedroom', 'Kitchen', 'Bathroom', 'Garage', 'Study Room'];

  IconData _getDeviceIcon(String type) {
    switch (type) {
      case 'Light': return Icons.lightbulb;
      case 'Fan': return Icons.air;
      case 'AC': return Icons.ac_unit;
      case 'Camera': return Icons.videocam;
      default: return Icons.device_unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Device',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textColor),
                    decoration: InputDecoration(
                      labelText: 'Device Name',
                      labelStyle: const TextStyle(color: AppTheme.textColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a device name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    dropdownColor: AppTheme.cardColor,
                    style: const TextStyle(color: AppTheme.textColor),
                    decoration: InputDecoration(
                      labelText: 'Device Type',
                      labelStyle: const TextStyle(color: AppTheme.textColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                    ),
                    items: deviceTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_getDeviceIcon(type), color: AppTheme.accentColor),
                            const SizedBox(width: 12),
                            Text(type, style: const TextStyle(color: AppTheme.textColor)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRoom,
                    dropdownColor: AppTheme.cardColor,
                    style: const TextStyle(color: AppTheme.textColor),
                    decoration: InputDecoration(
                      labelText: 'Room',
                      labelStyle: const TextStyle(color: AppTheme.textColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                    ),
                    items: rooms.map((String room) {
                      return DropdownMenuItem<String>(
                        value: room,
                        child: Text(room, style: const TextStyle(color: AppTheme.textColor)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRoom = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Initial Status:',
                          style: TextStyle(color: AppTheme.textColor, fontSize: 16),
                        ),
                        Row(
                          children: [
                            Text(
                              _isOn ? 'ON' : 'OFF',
                              style: TextStyle(
                                color: _isOn ? AppTheme.accentColor : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Switch(
                              value: _isOn,
                              onChanged: (value) {
                                setState(() {
                                  _isOn = value;
                                });
                              },
                              activeColor: AppTheme.accentColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: AppTheme.primaryColor),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: AppTheme.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final newDevice = SmartDevice(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: _nameController.text,
                                type: _selectedType,
                                room: _selectedRoom,
                                isOn: _isOn,
                                value: 0.5,
                              );
                              widget.onDeviceAdded(newDevice);
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Add Device',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}