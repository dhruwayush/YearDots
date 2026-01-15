import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:year_dots/core/constants/app_colors.dart';
import 'package:year_dots/presentation/viewmodels/home_viewmodel.dart';
import 'package:year_dots/data/services/background_service.dart';

// Helper for the "System Optimization" gradient card
class InfoCard extends StatelessWidget {
  final VoidCallback onOpenSettings;
  const InfoCard({super.key, required this.onOpenSettings});
  // ... build method with gradient blue/black ...
}

// Helper for Troubleshooting items
class ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;
  // ...
}
