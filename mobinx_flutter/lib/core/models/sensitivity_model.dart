import 'package:flutter/material.dart';

/// Device Brand Model
class DeviceBrandModel {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final List<String> popularModels;

  const DeviceBrandModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.popularModels,
  });
}

/// Sensitivity Preset Model (Free Fire OB45 Meta)
class SensitivityPreset {
  final int id;
  final String tabName;
  final String title;
  final String subtitle;
  final int general;
  final int redDot;
  final int scope2x;
  final int scope4x;
  final int sniper;
  final int freeLook;
  final String buttonSize;
  final String dpi;
  final int numericDpi;
  final int noDpiGeneral;
  final bool isVip;

  const SensitivityPreset({
    required this.id,
    required this.tabName,
    required this.title,
    required this.subtitle,
    required this.general,
    required this.redDot,
    required this.scope2x,
    required this.scope4x,
    required this.sniper,
    required this.freeLook,
    required this.buttonSize,
    required this.dpi,
    required this.numericDpi,
    required this.noDpiGeneral,
    this.isVip = false,
  });
}

/// Calibrated Sensitivity Result for a specific device
class DeviceSensitivityResult {
  final String deviceName;
  final String brandId;
  final List<SensitivityPreset> presets;
  int upVotes;
  int downVotes;
  String? userVote; // 'itWorks' | 'notWorking'

  DeviceSensitivityResult({
    required this.deviceName,
    required this.brandId,
    required this.presets,
    this.upVotes = 148,
    this.downVotes = 4,
    this.userVote,
  });
}
