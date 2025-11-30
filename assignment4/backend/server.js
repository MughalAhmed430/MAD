const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = 3000;
const DATA_FILE = path.join(__dirname, 'activities.json');

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Initialize data file
const initializeDataFile = () => {
  if (!fs.existsSync(DATA_FILE)) {
    fs.writeFileSync(DATA_FILE, JSON.stringify([]));
  }
};

// Read activities from file
const readActivities = () => {
  try {
    const data = fs.readFileSync(DATA_FILE, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Error reading activities:', error);
    return [];
  }
};

// Write activities to file
const writeActivities = (activities) => {
  try {
    fs.writeFileSync(DATA_FILE, JSON.stringify(activities, null, 2));
    return true;
  } catch (error) {
    console.error('Error writing activities:', error);
    return false;
  }
};

// Initialize data file on server start
initializeDataFile();

// Routes

// GET /api/activities - Get all activities
app.get('/api/activities', (req, res) => {
  try {
    const activities = readActivities();
    console.log(` Returning ${activities.length} activities`);
    res.json({
      success: true,
      data: activities,
      count: activities.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch activities',
      message: error.message
    });
  }
});

// GET /api/activities/:id - Get single activity
app.get('/api/activities/:id', (req, res) => {
  try {
    const activities = readActivities();
    const activity = activities.find(a => a.id === req.params.id);

    if (!activity) {
      return res.status(404).json({
        success: false,
        error: 'Activity not found'
      });
    }

    res.json({
      success: true,
      data: activity
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch activity',
      message: error.message
    });
  }
});

// POST /api/activities - Create new activity
app.post('/api/activities', (req, res) => {
  try {
    const { title, description, latitude, longitude, userId, imageUrl } = req.body;

    // Validation
    if (!title || !description || latitude === undefined || longitude === undefined) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: title, description, latitude, longitude'
      });
    }

    const activities = readActivities();

    const newActivity = {
      id: uuidv4(),
      title,
      description,
      latitude: parseFloat(latitude),
      longitude: parseFloat(longitude),
      userId: userId || 'anonymous',
      imageUrl: imageUrl || null,
      timestamp: new Date().toISOString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    activities.push(newActivity);

    if (writeActivities(activities)) {
      console.log(` Created activity: ${newActivity.title} (${newActivity.id})`);
      res.status(201).json({
        success: true,
        data: newActivity,
        message: 'Activity created successfully'
      });
    } else {
      res.status(500).json({
        success: false,
        error: 'Failed to save activity'
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to create activity',
      message: error.message
    });
  }
});

// PUT /api/activities/:id - Update activity
app.put('/api/activities/:id', (req, res) => {
  try {
    const activities = readActivities();
    const index = activities.findIndex(a => a.id === req.params.id);

    if (index === -1) {
      return res.status(404).json({
        success: false,
        error: 'Activity not found'
      });
    }

    const updatedActivity = {
      ...activities[index],
      ...req.body,
      id: req.params.id, // Prevent ID change
      updatedAt: new Date().toISOString()
    };

    activities[index] = updatedActivity;

    if (writeActivities(activities)) {
      console.log(`✏ Updated activity: ${updatedActivity.title} (${updatedActivity.id})`);
      res.json({
        success: true,
        data: updatedActivity,
        message: 'Activity updated successfully'
      });
    } else {
      res.status(500).json({
        success: false,
        error: 'Failed to update activity'
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to update activity',
      message: error.message
    });
  }
});

// DELETE /api/activities/:id - Delete activity
app.delete('/api/activities/:id', (req, res) => {
  try {
    const activities = readActivities();
    const index = activities.findIndex(a => a.id === req.params.id);

    if (index === -1) {
      return res.status(404).json({
        success: false,
        error: 'Activity not found'
      });
    }

    const deletedActivity = activities.splice(index, 1)[0];

    if (writeActivities(activities)) {
      console.log(`🗑️ Deleted activity: ${deletedActivity.title} (${deletedActivity.id})`);
      res.json({
        success: true,
        data: deletedActivity,
        message: 'Activity deleted successfully'
      });
    } else {
      res.status(500).json({
        success: false,
        error: 'Failed to delete activity'
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to delete activity',
      message: error.message
    });
  }
});

// GET /api/health - Health check
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'SmartTracker API is running 🚀',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(` SmartTracker API Server running on port ${PORT}`);
  console.log(` Local: http://localhost:${PORT}`);
  console.log(` Network: http://0.0.0.0:${PORT}`);
  console.log(` API Documentation:`);
  console.log(`   GET    http://localhost:${PORT}/api/health`);
  console.log(`   GET    http://localhost:${PORT}/api/activities`);
  console.log(`   POST   http://localhost:${PORT}/api/activities`);
  console.log(`   PUT    http://localhost:${PORT}/api/activities/:id`);
  console.log(`   DELETE http://localhost:${PORT}/api/activities/:id`);
});

module.exports = app;