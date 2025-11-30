import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../providers/location_provider.dart';
import '../models/activity_model.dart';
import '../theme/app_theme.dart';
import 'map_screen.dart';
import 'history_screen.dart';
import 'camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('HomeScreen: Building widget');
    final activityProvider = Provider.of<ActivityProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'SmartTracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // Online Status Indicator
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
                        ? 'Online - Syncing with API'
                        : 'Offline - Using local storage',
                  ),
                  backgroundColor: activityProvider.isOnline ? Colors.green : Colors.orange,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to SmartTracker!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your activities with GPS and photos',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Connection Status
                  Row(
                    children: [
                      Icon(
                        activityProvider.isOnline ? Icons.wifi : Icons.wifi_off,
                        size: 16,
                        color: activityProvider.isOnline ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activityProvider.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: activityProvider.isOnline ? Colors.green : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context: context,
                    icon: Icons.map,
                    title: 'Live Map',
                    subtitle: 'Track location',
                    color: AppTheme.primaryColor,
                    onTap: () {
                      print('HomeScreen: Map button pressed');
                      locationProvider.getCurrentLocation().then((_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MapScreen()),
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context: context,
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    subtitle: 'Capture photo',
                    color: AppTheme.secondaryColor,
                    onTap: () {
                      print('HomeScreen: Camera button pressed');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CameraScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activities Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    if (activityProvider.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      '${activityProvider.activities.length} items',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Activities List
            Expanded(
              child: activityProvider.isLoading && activityProvider.activities.isEmpty
                  ? _buildLoadingState()
                  : activityProvider.activities.isEmpty
                  ? _buildEmptyState(context)
                  : RefreshIndicator(
                onRefresh: () => activityProvider.loadActivities(),
                child: ListView.builder(
                  itemCount: activityProvider.activities.length,
                  itemBuilder: (context, index) {
                    final activity = activityProvider.activities[index];
                    return _buildActivityItem(activity);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('HomeScreen: FAB pressed - Getting location');
          locationProvider.getCurrentLocation().then((_) {
            if (locationProvider.currentPosition != null) {
              print('HomeScreen: Location obtained, showing dialog');
              _showCreateActivityDialog(context, locationProvider, activityProvider);
            } else {
              print('HomeScreen: Location is null');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unable to get current location')),
              );
            }
          }).catchError((error) {
            print('HomeScreen: Location error: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Location error: $error')),
            );
          });
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateActivityDialog(BuildContext context, LocationProvider locationProvider, ActivityProvider activityProvider) {
    print('HomeScreen: Showing create activity dialog');
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Activity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Location: ${locationProvider.currentPosition!.latitude.toStringAsFixed(4)}, ${locationProvider.currentPosition!.longitude.toStringAsFixed(4)}',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title',
                border: OutlineInputBorder(),
                hintText: 'e.g., Morning Walk, Coffee Break',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
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
            onPressed: () {
              print('HomeScreen: Create activity cancelled');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                print('HomeScreen: Creating activity with title: ${titleController.text}');

                final activity = Activity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: 'user_123',
                  title: titleController.text,
                  description: descriptionController.text,
                  latitude: locationProvider.currentPosition!.latitude,
                  longitude: locationProvider.currentPosition!.longitude,
                  timestamp: DateTime.now(),
                );

                print('HomeScreen: Calling activityProvider.addActivity()');
                activityProvider.addActivity(activity);

                titleController.clear();
                descriptionController.clear();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Activity created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                print('HomeScreen: Validation failed - empty fields');
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

  Widget _buildActionCard({
    required BuildContext context,
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.place,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${activity.latitude.toStringAsFixed(4)}, ${activity.longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(activity.timestamp),
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'GPS',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading activities...',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No activities yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first activity',
            style: TextStyle(
              color: AppTheme.textSecondary.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              print('HomeScreen: Create first activity button pressed');
              final locationProvider = Provider.of<LocationProvider>(context, listen: false);
              final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
              locationProvider.getCurrentLocation().then((_) {
                if (locationProvider.currentPosition != null) {
                  _showCreateActivityDialog(context, locationProvider, activityProvider);
                }
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Create First Activity'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}