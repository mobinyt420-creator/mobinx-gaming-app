import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/sensitivity_model.dart';
import '../../core/services/sensitivity_service.dart';

enum SensitivityViewMode {
  brands,
  models,
  result,
  custom,
}

/// Full Free Fire OB45 Meta Sensitivity Maker (100% Matching Screenshot 4 & SensitivityView.js)
class SensitivityScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SensitivityScreen({super.key, this.onBack});

  @override
  State<SensitivityScreen> createState() => _SensitivityScreenState();
}

class _SensitivityScreenState extends State<SensitivityScreen> {
  SensitivityViewMode _mode = SensitivityViewMode.brands;
  DeviceBrandModel _selectedBrand = SensitivityService.deviceBrands[0];
  String _selectedDeviceName = 'VIVO Y1';
  DeviceSensitivityResult? _currentSensiData;
  int _activePresetIndex = 0;
  bool _isNoDpiMode = false;

  final TextEditingController _globalSearchCtrl = TextEditingController();
  final TextEditingController _modelSearchCtrl = TextEditingController();
  String _globalQuery = '';
  String _modelQuery = '';

  // Custom spec form controllers
  String _customBrand = 'vivo';
  final TextEditingController _customModelCtrl = TextEditingController();
  int _customRam = 4;
  int _customStorage = 128;
  int _customRefresh = 90;

  @override
  void initState() {
    super.initState();
    _currentSensiData = SensitivityService.instance.generateForDevice(_selectedDeviceName, brandId: _selectedBrand.id);
  }

  @override
  void dispose() {
    _globalSearchCtrl.dispose();
    _modelSearchCtrl.dispose();
    _customModelCtrl.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_mode == SensitivityViewMode.models) {
      setState(() => _mode = SensitivityViewMode.brands);
    } else if (_mode == SensitivityViewMode.custom) {
      setState(() => _mode = SensitivityViewMode.brands);
    } else if (_mode == SensitivityViewMode.result) {
      setState(() => _mode = SensitivityViewMode.brands);
    } else {
      if (widget.onBack != null) {
        widget.onBack!();
      } else {
        Navigator.maybePop(context);
      }
    }
  }

  void _openDeviceResult(String deviceName, String brandId) {
    setState(() {
      _selectedDeviceName = deviceName;
      _currentSensiData = SensitivityService.instance.generateForDevice(deviceName, brandId: brandId);
      _activePresetIndex = 0;
      _isNoDpiMode = false;
      _mode = SensitivityViewMode.result;
    });
  }

  void _openBrandModels(DeviceBrandModel brand) {
    setState(() {
      _selectedBrand = brand;
      _modelQuery = '';
      _modelSearchCtrl.clear();
      _mode = SensitivityViewMode.models;
    });
  }

  void _calculateCustomSpecs() {
    final result = SensitivityService.instance.generateForCustomSpecs(
      brand: _customBrand,
      model: _customModelCtrl.text,
      ramGb: _customRam,
      storageGb: _customStorage,
      refreshRateHz: _customRefresh,
    );
    setState(() {
      _selectedDeviceName = result.deviceName;
      _currentSensiData = result;
      _activePresetIndex = 0;
      _isNoDpiMode = false;
      _mode = SensitivityViewMode.result;
    });
  }

  void _copySettings(SensitivityPreset preset) {
    final genVal = _isNoDpiMode ? preset.noDpiGeneral : preset.general;
    final dpiVal = _isNoDpiMode ? 'Default (No DPI)' : preset.dpi;
    final text = '''
🎯 Mobin X Free Fire OB45 Sensitivity ($_selectedDeviceName):
Preset: ${preset.title}
- General: $genVal
- Red Dot: ${preset.redDot}
- 2x Scope: ${preset.scope2x}
- 4x Scope: ${preset.scope4x}
- Sniper Scope: ${preset.sniper}
- Free Look: ${preset.freeLook}
- Fire Button Size: ${preset.buttonSize}
- Recommended DPI: $dpiVal
⚡ 100% Free Fire Headshot Accuracy Calibrated by Mobin X
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💾 Sensitivity settings copied to clipboard! Paste into Free Fire.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF2563EB),
      ),
    );
  }

  void _shareSettings(SensitivityPreset preset) {
    final genVal = _isNoDpiMode ? preset.noDpiGeneral : preset.general;
    final dpiVal = _isNoDpiMode ? 'Default (No DPI)' : preset.dpi;
    final text = '''
🎯 Mobin X Free Fire OB45 Sensitivity ($_selectedDeviceName):
Preset: ${preset.title}
- General: $genVal
- Red Dot: ${preset.redDot}
- 2x Scope: ${preset.scope2x}
- 4x Scope: ${preset.scope4x}
- Fire Button: ${preset.buttonSize}
- DPI: $dpiVal
🔥 Download Mobin X Gaming App for verified OB45 Free Fire meta!
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('↗️ Sensitivity details copied to clipboard! Share with your squad.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF0284C7),
      ),
    );
  }

  void _handleVote(String voteType) {
    if (_currentSensiData == null) return;
    setState(() {
      if (_currentSensiData!.userVote == voteType) {
        // undo vote
        if (voteType == 'itWorks') {
          _currentSensiData!.upVotes = (_currentSensiData!.upVotes - 1).clamp(0, 9999);
        } else {
          _currentSensiData!.downVotes = (_currentSensiData!.downVotes - 1).clamp(0, 9999);
        }
        _currentSensiData!.userVote = null;
      } else {
        if (_currentSensiData!.userVote == 'itWorks') {
          _currentSensiData!.upVotes = (_currentSensiData!.upVotes - 1).clamp(0, 9999);
        } else if (_currentSensiData!.userVote == 'notWorking') {
          _currentSensiData!.downVotes = (_currentSensiData!.downVotes - 1).clamp(0, 9999);
        }
        if (voteType == 'itWorks') {
          _currentSensiData!.upVotes += 1;
        } else {
          _currentSensiData!.downVotes += 1;
        }
        _currentSensiData!.userVote = voteType;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(voteType == 'itWorks' ? '👍 Thanks for your positive feedback!' : '👎 Feedback recorded. We will re-calibrate this device.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildCurrentView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    String title = 'Sensitivity Maker';
    if (_mode == SensitivityViewMode.models) {
      title = '${_selectedBrand.name} Devices';
    } else if (_mode == SensitivityViewMode.result) {
      title = _selectedDeviceName;
    } else if (_mode == SensitivityViewMode.custom) {
      title = 'Custom Sensitivity Builder';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: const Center(
                child: Icon(Icons.chevron_left_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text('🎯', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.6)),
            ),
            child: Text(
              'Free Fire OB45 Meta',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF38BDF8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_mode) {
      case SensitivityViewMode.brands:
        return _buildBrandsView();
      case SensitivityViewMode.models:
        return _buildModelsView();
      case SensitivityViewMode.result:
        return _buildResultView();
      case SensitivityViewMode.custom:
        return _buildCustomView();
    }
  }

  // ================= VIEW 1: BRANDS & QUICK SEARCH =================
  Widget _buildBrandsView() {
    final filteredBrands = SensitivityService.deviceBrands.where((b) {
      if (_globalQuery.isEmpty) return true;
      final q = _globalQuery.toLowerCase();
      if (b.name.toLowerCase().contains(q)) return true;
      return b.popularModels.any((m) => m.toLowerCase().contains(q));
    }).toList();

    return SingleChildScrollView(
      key: const ValueKey('brands_view'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Prominent Custom Sensitivity Maker Banner (Matching Screenshot 4)
          GestureDetector(
            onTap: () => setState(() => _mode = SensitivityViewMode.custom),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(Icons.add_rounded, color: Colors.white, size: 26),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Custom Sensitivity Maker',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Build by Phone Model, RAM & Storage',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'BUILD',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF0284C7)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Search Box
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: TextField(
              controller: _globalSearchCtrl,
              onChanged: (v) => setState(() => _globalQuery = v.trim()),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'SEARCH YOUR PHONE MODEL (e.g. Y22, A54)...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white38,
                  letterSpacing: 0.3,
                ),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF38BDF8), size: 20),
                suffixIcon: _globalQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                        onPressed: () {
                          _globalSearchCtrl.clear();
                          setState(() => _globalQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Popular Devices
          Row(
            children: [
              const Icon(Icons.bolt, color: Color(0xFFFBBF24), size: 16),
              const SizedBox(width: 4),
              Text(
                'QUICK POPULAR DEVICES',
                style: GoogleFonts.outfit(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: SensitivityService.quickFeaturedDevices.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFF1E293B)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    avatar: const Icon(Icons.trending_up, color: Color(0xFFEF4444), size: 14),
                    label: Text(
                      item['name']!,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => _openDeviceResult(item['name']!, item['brand']!),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // Choose Your Device Brand
          Row(
            children: [
              const Text('📱', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'CHOOSE YOUR DEVICE BRAND',
                style: GoogleFonts.outfit(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2-Column Grid of Dark Brand Cards (Matching Screenshot 4)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredBrands.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.5,
            ),
            itemBuilder: (context, index) {
              final brand = filteredBrands[index];
              return InkWell(
                onTap: () => _openBrandModels(brand),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Row(
                    children: [
                      Text(brand.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          brand.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ================= VIEW 2: MODEL LIST FOR SELECTED BRAND =================
  Widget _buildModelsView() {
    final filteredModels = _selectedBrand.popularModels.where((m) {
      if (_modelQuery.isEmpty) return true;
      return m.toLowerCase().contains(_modelQuery.toLowerCase());
    }).toList();

    return Column(
      key: const ValueKey('models_view'),
      children: [
        // Brand Header Banner
        Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(_selectedBrand.icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedBrand.name} SETTINGS',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Select your exact model for 100% verified crosshair calibrator',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Search Model Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: TextField(
              controller: _modelSearchCtrl,
              onChanged: (v) => setState(() => _modelQuery = v.trim()),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search ${_selectedBrand.name} model...',
                hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF38BDF8), size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Models List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            itemCount: filteredModels.length,
            separatorBuilder: (_, _) => const Divider(color: Color(0xFF1E293B), height: 1),
            itemBuilder: (context, index) {
              final model = filteredModels[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                title: Text(
                  model,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF38BDF8), size: 14),
                onTap: () => _openDeviceResult(model, _selectedBrand.id),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= VIEW 3: SENSI RESULT SCREEN (Matching Screenshot 3 & 4) =================
  Widget _buildResultView() {
    if (_currentSensiData == null) return const SizedBox.shrink();
    final preset = _currentSensiData!.presets[_activePresetIndex];
    final generalVal = _isNoDpiMode ? preset.noDpiGeneral : preset.general;
    final dpiDisplay = _isNoDpiMode ? 'Default (No DPI)' : preset.dpi;

    return SingleChildScrollView(
      key: const ValueKey('result_view'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device Header Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📱', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentSensiData!.deviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'RECOMMENDED SENSI ${preset.tabName} | 100% HEADSHOT ACCURACY',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF38BDF8),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Presets Selector Tabs (# 1, # 2, VIP 3, VIP 4)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_currentSensiData!.presets.length, (idx) {
                final p = _currentSensiData!.presets[idx];
                final isSel = _activePresetIndex == idx;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: p.isVip
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'VIP',
                              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                            ),
                          )
                        : null,
                    label: Text(p.tabName),
                    selected: isSel,
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: const Color(0xFF0F172A),
                    side: BorderSide(
                      color: isSel ? const Color(0xFF38BDF8) : const Color(0xFF1E293B),
                    ),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _activePresetIndex = idx),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),

          // Active Preset Description Pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70, height: 1.35),
                children: [
                  TextSpan(
                    text: '${preset.title}: ',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  TextSpan(text: preset.subtitle),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Sensitivity Sliders Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Column(
              children: [
                _buildSliderRow('General', generalVal),
                _buildSliderRow('Red Dot', preset.redDot),
                _buildSliderRow('2x Scope', preset.scope2x),
                _buildSliderRow('4x Scope', preset.scope4x),
                const SizedBox(height: 8),

                // Button & DPI Row (Ref: BUTTON: 44%, DPI: 480)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('🎯', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('BUTTON', style: GoogleFonts.inter(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w600)),
                                Text(
                                  preset.buttonSize,
                                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF10B981)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('📱', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DPI', style: GoogleFonts.inter(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w600)),
                                Text(
                                  dpiDisplay,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: _isNoDpiMode ? const Color(0xFFEAB308) : const Color(0xFF38BDF8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons Row (Ref: SHARE, NO DPI, SAVE)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: const Text('SHARE'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF1E293B)),
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _shareSettings(preset),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(_isNoDpiMode ? Icons.smartphone_rounded : Icons.auto_awesome, size: 16),
                  label: Text(_isNoDpiMode ? 'USE DPI' : 'NO DPI'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isNoDpiMode ? const Color(0xFFEAB308) : Colors.white,
                    side: BorderSide(color: _isNoDpiMode ? const Color(0xFFEAB308) : const Color(0xFF1E293B)),
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => setState(() => _isNoDpiMode = !_isNoDpiMode),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('SAVE'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _copySettings(preset),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Community Feedback Row (Ref: NOT WORKING / IT WORKS)
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _handleVote('notWorking'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _currentSensiData!.userVote == 'notWorking' ? const Color(0xFF7F1D1D) : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _currentSensiData!.userVote == 'notWorking' ? const Color(0xFFEF4444) : const Color(0xFF1E293B),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👎', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NOT WORKING',
                              style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w900, color: const Color(0xFFEF4444)),
                            ),
                            Text(
                              '${_currentSensiData!.downVotes}',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => _handleVote('itWorks'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _currentSensiData!.userVote == 'itWorks' ? const Color(0xFF064E3B) : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _currentSensiData!.userVote == 'itWorks' ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👍', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IT WORKS',
                              style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w900, color: const Color(0xFF10B981)),
                            ),
                            Text(
                              '${_currentSensiData!.upVotes}',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              Text(
                value.toString(),
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 200).clamp(0.0, 1.0),
              backgroundColor: const Color(0xFF1E293B),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ================= VIEW 4: DEDICATED CUSTOM SENSITIVITY BUILDER =================
  Widget _buildCustomView() {
    return SingleChildScrollView(
      key: const ValueKey('custom_view'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🛠️ Custom Phone Specification Setup',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter your phone hardware specs to calculate calibrated headshot sensitivity & DPI for Free Fire.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),

                // Brand Selector
                Text('Device Brand *', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _customBrand,
                      isExpanded: true,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                      items: const [
                        DropdownMenuItem(value: 'xiaomi', child: Text('Xiaomi / Redmi / Poco')),
                        DropdownMenuItem(value: 'samsung', child: Text('Samsung Galaxy')),
                        DropdownMenuItem(value: 'realme', child: Text('Realme')),
                        DropdownMenuItem(value: 'vivo', child: Text('Vivo / iQOO')),
                        DropdownMenuItem(value: 'oppo', child: Text('Oppo')),
                        DropdownMenuItem(value: 'infinix', child: Text('Infinix')),
                        DropdownMenuItem(value: 'tecno', child: Text('Tecno')),
                        DropdownMenuItem(value: 'oneplus', child: Text('OnePlus')),
                        DropdownMenuItem(value: 'apple', child: Text('Apple iPhone')),
                        DropdownMenuItem(value: 'other', child: Text('Other Android Device')),
                      ],
                      onChanged: (val) => setState(() => _customBrand = val ?? 'vivo'),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Phone Model Input
                Text('Phone Model Name *', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                const SizedBox(height: 6),
                TextField(
                  controller: _customModelCtrl,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: 'e.g. Note 12 Pro 5G / Y20 / A14',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // RAM & Storage 2-column
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RAM *', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _customRam,
                                isExpanded: true,
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                                items: const [
                                  DropdownMenuItem(value: 2, child: Text('2 GB RAM')),
                                  DropdownMenuItem(value: 3, child: Text('3 GB RAM')),
                                  DropdownMenuItem(value: 4, child: Text('4 GB RAM')),
                                  DropdownMenuItem(value: 6, child: Text('6 GB RAM')),
                                  DropdownMenuItem(value: 8, child: Text('8 GB RAM')),
                                  DropdownMenuItem(value: 12, child: Text('12 GB+ RAM')),
                                ],
                                onChanged: (val) => setState(() => _customRam = val ?? 4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Internal Storage *', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _customStorage,
                                isExpanded: true,
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                                items: const [
                                  DropdownMenuItem(value: 32, child: Text('32 GB')),
                                  DropdownMenuItem(value: 64, child: Text('64 GB')),
                                  DropdownMenuItem(value: 128, child: Text('128 GB')),
                                  DropdownMenuItem(value: 256, child: Text('256 GB')),
                                  DropdownMenuItem(value: 512, child: Text('512 GB')),
                                ],
                                onChanged: (val) => setState(() => _customStorage = val ?? 128),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Screen Refresh Rate
                Text('Screen Refresh Rate', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _customRefresh,
                      isExpanded: true,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                      items: const [
                        DropdownMenuItem(value: 60, child: Text('60 Hz Standard Display')),
                        DropdownMenuItem(value: 90, child: Text('90 Hz Smooth Display')),
                        DropdownMenuItem(value: 120, child: Text('120 Hz Ultra Fast Display')),
                      ],
                      onChanged: (val) => setState(() => _customRefresh = val ?? 90),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Calculate Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _calculateCustomSpecs,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'CALCULATE CALIBRATED SENSITIVITY',
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
