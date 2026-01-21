/// Mapping of lucide-react icons to Flutter Material Icons
/// This ensures we use the same visual icons as the React app
import 'package:flutter/material.dart';

class LucideIcons {
  // Navigation & Actions
  static const IconData chevronRight = Icons.chevron_right;
  static const IconData chevronLeft = Icons.chevron_left;
  static const IconData chevronDown = Icons.keyboard_arrow_down;
  static const IconData chevronUp = Icons.keyboard_arrow_up;
  static const IconData arrowLeft = Icons.arrow_back;
  static const IconData arrowRight = Icons.arrow_forward;
  static const IconData x = Icons.close;
  static const IconData externalLink = Icons.open_in_new;
  
  // Medical & Clinical
  static const IconData activity = Icons.favorite; // Heart rate / Activity
  static const IconData brain = Icons.psychology; // AI / Brain
  static const IconData user = Icons.person; // Doctor / User
  static const IconData shield = Icons.shield; // Security / Audit
  static const IconData fileText = Icons.description; // Documents
  static const IconData fileCheck = Icons.check_circle_outline; // Completed
  static const IconData pill = Icons.medication; // Medications
  static const IconData alertCircle = Icons.info_outline; // Alerts
  static const IconData alertTriangle = Icons.warning_amber; // Warnings
  
  // Communication
  static const IconData messageSquare = Icons.message;
  static const IconData send = Icons.send;
  static const IconData link2 = Icons.link;
  
  // Time & Calendar
  static const IconData calendar = Icons.calendar_today;
  static const IconData clock = Icons.access_time;
  
  // Status & Actions
  static const IconData checkCircle = Icons.check_circle;
  static const IconData circle = Icons.radio_button_unchecked;
  static const IconData save = Icons.save;
  static const IconData filter = Icons.filter_list;
  static const IconData search = Icons.search;
  static const IconData lock = Icons.lock;
  static const IconData trendingUp = Icons.trending_up;
}
