// lib/utils/permissions.dart

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionService {
  // Request Activity Recognition Permission
  Future<void> requestActivityRecognitionPermission() async {
    PermissionStatus status = await Permission.activityRecognition.status;
    if (!status.isGranted) {
      status = await Permission.activityRecognition.request();
      if (!status.isGranted) {
        throw Exception('Activity Recognition Permission Denied');
      }
    }
  }
}

// Provider for PermissionService
final permissionProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});
