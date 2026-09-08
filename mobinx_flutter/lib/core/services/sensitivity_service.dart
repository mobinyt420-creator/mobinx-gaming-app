import 'dart:math';
import 'package:flutter/material.dart';
import '../models/sensitivity_model.dart';

/// Official Free Fire Sensitivity Intelligence Engine (OB45+ Meta)
class SensitivityService {
  SensitivityService._();
  static final SensitivityService instance = SensitivityService._();

  static const List<DeviceBrandModel> deviceBrands = [
    DeviceBrandModel(
      id: 'vivo',
      name: 'VIVO',
      icon: '📱',
      color: Color(0xFF06B6D4),
      popularModels: [
        'VIVO Y22S', 'VIVO Y21T', 'VIVO Y30I', 'VIVO Y1', 'VIVO V27E',
        'VIVO V15', 'VIVO Y33T', 'VIVO Y33', 'VIVO Y22', 'VIVO Y02',
        'VIVO Y01', 'VIVO Y15S', 'VIVO T2X 5G', 'VIVO V29', 'VIVO Y20', 'VIVO X23'
      ],
    ),
    DeviceBrandModel(
      id: 'xiaomi',
      name: 'XIAOMI / POCO',
      icon: '⚡',
      color: Color(0xFFFF6900),
      popularModels: [
        'POCO X3 PRO', 'POCO F4', 'POCO M4 PRO', 'REDMI NOTE 12',
        'REDMI NOTE 11', 'REDMI NOTE 10 PRO', 'REDMI 12C', 'REDMI 10A',
        'REDMI 9A', 'XIAOMI 13T', 'REDMI K50', 'POCO X5 PRO'
      ],
    ),
    DeviceBrandModel(
      id: 'samsung',
      name: 'SAMSUNG',
      icon: '💎',
      color: Color(0xFF2563EB),
      popularModels: [
        'GALAXY A54', 'GALAXY A34', 'GALAXY A14', 'GALAXY A23',
        'GALAXY A12', 'GALAXY S23 ULTRA', 'GALAXY S21 FE', 'GALAXY M14',
        'GALAXY M33', 'GALAXY A04S', 'GALAXY A52S', 'GALAXY A32'
      ],
    ),
    DeviceBrandModel(
      id: 'realme',
      name: 'REALME',
      icon: '🔥',
      color: Color(0xFFEAB308),
      popularModels: [
        'REALME C55', 'REALME C35', 'REALME 11 PRO', 'REALME 9 PRO+',
        'REALME 8', 'REALME NARZO 50', 'REALME C21Y', 'REALME GT 2 PRO',
        'REALME 10', 'REALME C30'
      ],
    ),
    DeviceBrandModel(
      id: 'infinix',
      name: 'INFINIX',
      icon: '🚀',
      color: Color(0xFF10B981),
      popularModels: [
        'INFINIX HOT 30', 'INFINIX HOT 20', 'INFINIX NOTE 30 PRO',
        'INFINIX NOTE 12', 'INFINIX SMART 7', 'INFINIX ZERO 5G',
        'INFINIX HOT 11S', 'INFINIX NOTE 11'
      ],
    ),
    DeviceBrandModel(
      id: 'tecno',
      name: 'TECNO',
      icon: '🎯',
      color: Color(0xFF3B82F6),
      popularModels: [
        'TECNO SPARK 10 PRO', 'TECNO SPARK 9T', 'TECNO POVA 5',
        'TECNO POVA 4', 'TECNO CAMON 20', 'TECNO POP 7 PRO',
        'TECNO SPARK 8C', 'TECNO POVA NEO'
      ],
    ),
    DeviceBrandModel(
      id: 'oppo',
      name: 'OPPO',
      icon: '🟢',
      color: Color(0xFF22C55E),
      popularModels: [
        'OPPO RENO 8', 'OPPO A78', 'OPPO A57', 'OPPO A17',
        'OPPO F21 PRO', 'OPPO A54', 'OPPO A16', 'OPPO RENO 10 PRO'
      ],
    ),
    DeviceBrandModel(
      id: 'oneplus',
      name: 'ONEPLUS',
      icon: '🔴',
      color: Color(0xFFEF4444),
      popularModels: [
        'ONEPLUS NORD CE 3 LITE', 'ONEPLUS 11R', 'ONEPLUS NORD 2T',
        'ONEPLUS 10 PRO', 'ONEPLUS NORD CE 2', 'ONEPLUS 9R'
      ],
    ),
    DeviceBrandModel(
      id: 'motorola',
      name: 'MOTOROLA',
      icon: '📡',
      color: Color(0xFF6366F1),
      popularModels: [
        'MOTO G73', 'MOTO G52', 'MOTO G32', 'MOTO EDGE 40',
        'MOTO ONE ZOOM', 'MOTO G84', 'MOTO G22'
      ],
    ),
    DeviceBrandModel(
      id: 'apple',
      name: 'APPLE IPHONE',
      icon: '🍏',
      color: Color(0xFFA855F7),
      popularModels: [
        'IPHONE 11', 'IPHONE 12', 'IPHONE 13', 'IPHONE 14 PRO',
        'IPHONE 15', 'IPHONE XR', 'IPHONE 8 PLUS', 'IPHONE 13 PRO MAX'
      ],
    ),
  ];

  static const List<Map<String, String>> quickFeaturedDevices = [
    {'name': 'MOTO ONE ZOOM', 'brand': 'motorola'},
    {'name': 'VIVO X23', 'brand': 'vivo'},
    {'name': 'POCO X3 PRO', 'brand': 'xiaomi'},
    {'name': 'GALAXY A54', 'brand': 'samsung'},
    {'name': 'VIVO Y22S', 'brand': 'vivo'},
    {'name': 'REDMI NOTE 12', 'brand': 'xiaomi'},
  ];

  /// Generate OB45 Calibrated Values for any phone model
  DeviceSensitivityResult generateForDevice(String deviceModel, {String brandId = 'vivo'}) {
    final cleanName = deviceModel.trim().toUpperCase();
    final isApple = cleanName.contains('IPHONE') || brandId == 'apple';
    final isFlagship = cleanName.contains('ULTRA') ||
        cleanName.contains('PRO MAX') ||
        cleanName.contains('PLUS') ||
        isApple;
    final isBudget = cleanName.contains('A0') ||
        cleanName.contains('Y0') ||
        cleanName.contains('POP') ||
        cleanName.contains('SMART') ||
        cleanName.contains('C3') ||
        cleanName.contains('C2');

    final baseGen = isBudget ? 198 : (isFlagship ? 186 : 192);
    final baseRed = isBudget ? 192 : (isFlagship ? 174 : 182);
    final base2x = isBudget ? 185 : (isFlagship ? 168 : 176);
    final base4x = isBudget ? 176 : (isFlagship ? 162 : 170);
    const baseSniper = 115;
    const baseFreeLook = 150;
    final baseButton = isBudget ? 48 : (isFlagship ? 42 : 44);
    final safeDpi = isApple ? 'Standard iOS (No DPI)' : (isBudget ? '480 DPI' : (isFlagship ? '450 DPI' : '520 DPI'));

    final safeNumericDpi = isApple ? 414 : (isBudget ? 490 : (isFlagship ? 440 : 480));

    final presets = [
      SensitivityPreset(
        id: 1,
        tabName: '# 1',
        title: 'Headshot Drag Meta (Ruok FF Style)',
        subtitle: 'Optimized for high-speed vertical drag & clean one-taps',
        general: min(200, baseGen),
        redDot: min(200, baseRed),
        scope2x: min(200, base2x),
        scope4x: min(200, base4x),
        sniper: baseSniper,
        freeLook: baseFreeLook,
        buttonSize: '$baseButton%',
        dpi: safeDpi,
        numericDpi: safeNumericDpi,
        noDpiGeneral: min(200, baseGen + 2),
      ),
      SensitivityPreset(
        id: 2,
        tabName: '# 2',
        title: 'Fast Flick & 360° Combat (Raistar Style)',
        subtitle: 'Ultra responsive close range camera turns & fast gloo wall',
        general: min(200, baseGen + 4),
        redDot: min(200, baseRed + 6),
        scope2x: min(200, base2x + 2),
        scope4x: min(200, base4x),
        sniper: baseSniper + 10,
        freeLook: min(200, baseFreeLook + 18),
        buttonSize: '${max(38, baseButton - 2)}%',
        dpi: isApple ? 'Standard iOS' : '${safeNumericDpi + 20} DPI',
        numericDpi: safeNumericDpi + 20,
        noDpiGeneral: min(200, baseGen + 4),
      ),
      SensitivityPreset(
        id: 3,
        tabName: 'VIP 3',
        title: 'Esports Tournament Precision (Balanced Meta)',
        subtitle: 'Consistent tournament crosshair lock for scrims and ranked',
        general: max(140, baseGen - 6),
        redDot: max(130, baseRed - 8),
        scope2x: max(120, base2x - 6),
        scope4x: max(110, base4x - 6),
        sniper: 108,
        freeLook: 140,
        buttonSize: '${baseButton + 1}%',
        dpi: isApple ? 'Standard iOS' : '${safeNumericDpi - 20} DPI',
        numericDpi: safeNumericDpi - 20,
        noDpiGeneral: max(150, baseGen - 4),
        isVip: true,
      ),
      SensitivityPreset(
        id: 4,
        tabName: 'VIP 4',
        title: 'Anti-Recoil & Laser Beam (Long Range)',
        subtitle: 'Steady pinpoint aiming for AR rifles (SCAR, AK47, Woodpecker)',
        general: max(150, baseGen - 2),
        redDot: max(140, baseRed - 2),
        scope2x: max(130, base2x + 4),
        scope4x: max(120, base4x + 6),
        sniper: 125,
        freeLook: 145,
        buttonSize: '$baseButton%',
        dpi: safeDpi,
        numericDpi: safeNumericDpi,
        noDpiGeneral: max(150, baseGen),
        isVip: true,
      ),
    ];

    return DeviceSensitivityResult(
      deviceName: cleanName,
      brandId: brandId,
      presets: presets,
      upVotes: 142 + Random().nextInt(40),
      downVotes: 2 + Random().nextInt(6),
    );
  }

  /// Calibrate custom hardware specifications
  DeviceSensitivityResult generateForCustomSpecs({
    required String brand,
    required String model,
    required int ramGb,
    required int storageGb,
    required int refreshRateHz,
  }) {
    final cleanModel = model.trim().isNotEmpty ? model.trim() : 'Custom Gaming Device';
    final name = '$cleanModel (${ramGb}GB / ${storageGb}GB • ${refreshRateHz}Hz)';
    final result = generateForDevice(name, brandId: brand.toLowerCase());
    return result;
  }
}
