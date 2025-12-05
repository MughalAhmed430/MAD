import 'package:flutter/material.dart';

// Color Constants
const Color kBackgroundColor = Color(0xFF0A0F1E);
const Color kCardBackground = Color(0xFF11172A);
const Color kPrimaryColor = Color(0xFF00FF9C);
const Color kSecondaryColor = Color(0xFF00D1FF);
const Color kTextPrimary = Colors.white;
const Color kTextSecondary = Color(0xFF94A3B8);

// Category Colors
Map<String, Color> categoryColors = {
  'Tech': Color(0xFF00D1FF),
  'Cultural': Color(0xFFFF4081),
  'Sports': Color(0xFF4CAF50),
  'Workshop': Color(0xFFFF9800),
  'Seminar': Color(0xFF9C27B0),
  'Social': Color(0xFFE91E63),
  'Academic': Color(0xFF2196F3),
  'Career': Color(0xFFFF5722),
  'All': Color(0xFF00FF9C),
};

// Text Styles
const TextStyle kHeaderTextStyle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);

const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

const TextStyle kBodyTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: Color(0xFF94A3B8),
);

const TextStyle kCaptionTextStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: Color(0xFF64748B),
);

// Padding & Sizes
const double kDefaultPadding = 16.0;
const double kCardBorderRadius = 16.0;
const double kButtonBorderRadius = 12.0;