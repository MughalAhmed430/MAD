import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/location_provider.dart';
import '../providers/activity_provider.dart';
import '../models/activity_model.dart'; // Add this import
import '../theme/app_theme.dart';
import 'camera_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _centerOnLocation(Position position) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        16.0, // Increased zoom level
      ),
    );
  }

  void _showCreateActivityDialog(BuildContext context, Position position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Activity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title',
                border: OutlineInputBorder(),
                hintText: 'e.g., Park Visit, Meeting',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                hintText: 'Describe your activity...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty &&
                  _descriptionController.text.isNotEmpty) {
                _createActivity(context, position);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createActivity(BuildContext context, Position position) {
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);

    // Create activity object with required id parameter
    final activity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Add required id
      userId: 'current_user',
      title: _titleController.text,
      description: _descriptionController.text,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
    );

    activityProvider.addActivity(activity);

    _titleController.clear();
    _descriptionController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Activity created successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Map'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          // Connection Status
          IconButton(
            icon: Icon(
              activityProvider.isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: activityProvider.isOnline ? Colors.green : Colors.orange,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    activityProvider.isOnline
                        ? '✅ Online - Syncing with API'
                        : '⚠️ Offline - Using local storage',
                  ),
                  backgroundColor: activityProvider.isOnline ? Colors.green : Colors.orange,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (locationProvider.currentPosition != null) {
                _centerOnLocation(locationProvider.currentPosition!);
              } else {
                locationProvider.getCurrentLocation().then((_) {
                  if (locationProvider.currentPosition != null) {
                    _centerOnLocation(locationProvider.currentPosition!);
                  }
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(33.6844, 73.0479), // Default to Islamabad
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _buildMarkers(locationProvider, activityProvider),
            compassEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Current Location Button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                if (locationProvider.currentPosition != null) {
                  _centerOnLocation(locationProvider.currentPosition!);
                } else {
                  locationProvider.getCurrentLocation().then((_) {
                    if (locationProvider.currentPosition != null) {
                      _centerOnLocation(locationProvider.currentPosition!);
                    }
                  });
                }
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // Create Activity Button
          Positioned(
            bottom: 180,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                if (locationProvider.currentPosition != null) {
                  _showCreateActivityDialog(
                      context,
                      locationProvider.currentPosition!
                  );
                } else {
                  locationProvider.getCurrentLocation().then((_) {
                    if (locationProvider.currentPosition != null) {
                      _showCreateActivityDialog(
                          context,
                          locationProvider.currentPosition!
                      );
                    }
                  });
                }
              },
              backgroundColor: AppTheme.accentColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),

          // Location Accuracy Info
          if (locationProvider.currentPosition != null)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      color: Colors.green[400],
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Accuracy: ${locationProvider.currentPosition!.accuracy.toStringAsFixed(1)}m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Location Status
          if (locationProvider.isLoading)
            const Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          if (locationProvider.error != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locationProvider.error!,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 18),
                      onPressed: locationProvider.clearError,
                    ),
                  ],
                ),
              ),
            ),

          // No Location Warning
          if (locationProvider.currentPosition == null && !locationProvider.isLoading)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap the GPS button to get your location',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Refresh Activities Button
          if (activityProvider.activities.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: FloatingActionButton(
                heroTag: 'refresh_activities',
                onPressed: () => activityProvider.loadActivities(),
                backgroundColor: AppTheme.secondaryColor,
                mini: true,
                child: const Icon(Icons.refresh, color: Colors.white, size: 20),
              ),
            ),
          // Get Location Button
          FloatingActionButton(
            heroTag: 'get_location',
            onPressed: locationProvider.getCurrentLocation,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.gps_fixed, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(LocationProvider locationProvider, ActivityProvider activityProvider) {
    final markers = <Marker>{};

    // Current location marker
    if (locationProvider.currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            locationProvider.currentPosition!.latitude,
            locationProvider.currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Current Location',
            snippet: 'Tap + to create activity here',
          ),
          zIndex: 2,
        ),
      );
    }

    // Activity markers
    for (int i = 0; i < activityProvider.activities.length; i++) {
      final activity = activityProvider.activities[i];
      markers.add(
        Marker(
          markerId: MarkerId('activity_${activity.id}'),
          position: LatLng(activity.latitude, activity.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: activity.title,
            snippet: activity.description,
          ),
          zIndex: 1,
        ),
      );
    }

    return markers;
  }

  @override
  void initState() {
    super.initState();
    // Get location when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      locationProvider.getCurrentLocation().then((_) {
        if (locationProvider.currentPosition != null && _mapController != null) {
          _centerOnLocation(locationProvider.currentPosition!);
        }
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}