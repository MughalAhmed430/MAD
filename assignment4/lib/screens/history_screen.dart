import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../models/activity_model.dart'; // Add this import
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final activities = _searchQuery.isEmpty
        ? activityProvider.activities
        : activityProvider.searchActivities(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          // Online/Offline Status Indicator
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
          // Sync Button
          if (!activityProvider.isOnline)
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () {
                _showSyncDialog(context, activityProvider);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search activities by title or description...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Connection Status Banner
          if (!activityProvider.isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Offline Mode - Using local storage',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activities (${activities.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  Text(
                    'Search results for "$_searchQuery"',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Activities List
          Expanded(
            child: activityProvider.isLoading
                ? _buildLoadingState()
                : activities.isEmpty
                ? _buildEmptyState(_searchQuery)
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildActivityCard(activity, activityProvider);
              },
            ),
          ),
        ],
      ),
      // Sync FAB when offline
      floatingActionButton: !activityProvider.isOnline
          ? FloatingActionButton(
        onPressed: () {
          _showSyncDialog(context, activityProvider);
        },
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.sync, color: Colors.white),
      )
          : null,
    );
  }

  Widget _buildActivityCard(Activity activity, ActivityProvider activityProvider) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activity.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: AppTheme.textSecondary),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteDialog(context, activity, activityProvider);
                  } else if (value == 'edit') {
                    _showEditDialog(context, activity, activityProvider);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            activity.description,
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Location and Time Row
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${activity.latitude.toStringAsFixed(4)}, ${activity.longitude.toStringAsFixed(4)}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                _formatDateTime(activity.timestamp),
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // API Sync Status
          if (!activityProvider.isOnline)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_upload, size: 12, color: Colors.orange[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Pending sync',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
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

  Widget _buildEmptyState(String searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isEmpty ? Icons.history_toggle_off : Icons.search_off,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No activities yet'
                : 'No results found',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Your activity history will appear here'
                : 'Try different search terms',
            style: TextStyle(
              color: AppTheme.textSecondary.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Activity activity, ActivityProvider activityProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete "${activity.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () {
              activityProvider.deleteActivity(activity.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${activity.title}" deleted'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Activity activity, ActivityProvider activityProvider) {
    final titleController = TextEditingController(text: activity.title);
    final descriptionController = TextEditingController(text: activity.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Activity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
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
              final updatedActivity = Activity(
                id: activity.id,
                userId: activity.userId,
                title: titleController.text,
                description: descriptionController.text,
                latitude: activity.latitude,
                longitude: activity.longitude,
                timestamp: activity.timestamp,
              );

              activityProvider.updateActivity(updatedActivity);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Activity updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSyncDialog(BuildContext context, ActivityProvider activityProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Activities'),
        content: const Text('Do you want to sync all local activities with the API?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              activityProvider.syncAllActivities();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Syncing activities with API...'),
                ),
              );
            },
            child: const Text('Sync Now'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}