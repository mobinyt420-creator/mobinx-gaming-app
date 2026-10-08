import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_service.dart';

class AdMobService {
  AdMobService._();
  static final AdMobService instance = AdMobService._();

  // Official Google Sample Test Ad Unit IDs (100% policy-safe for development & testing)
  static const String testRewardedAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String testBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';

  // Real Ad Unit IDs (When ready, can also be dynamically updated from Firebase)
  String? realRewardedAdUnitId = 'ca-app-pub-8241003118710445/7900529481';
  String? realBannerAdUnitId = 'ca-app-pub-8241003118710445/6290180322';
  String? realInterstitialAdUnitId = 'ca-app-pub-8241003118710445/2020771981';

  // Master switch (can be toggled from Admin Panel / Firestore or debug)
  bool isAdsEnabled = true;

  // In test mode, always use official Google sample IDs to protect user account
  bool isTestMode = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;
  int _rewardedRetryAttempts = 0;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoading = false;
  DateTime? _lastInterstitialShownAt;

  String get rewardedAdUnitId {
    if (isTestMode || realRewardedAdUnitId == null || realRewardedAdUnitId!.trim().isEmpty) {
      return testRewardedAdUnitIdAndroid;
    }
    return realRewardedAdUnitId!.trim();
  }

  String get bannerAdUnitId {
    if (isTestMode || realBannerAdUnitId == null || realBannerAdUnitId!.trim().isEmpty) {
      return testBannerAdUnitIdAndroid;
    }
    return realBannerAdUnitId!.trim();
  }

  String get interstitialAdUnitId {
    if (isTestMode || realInterstitialAdUnitId == null || realInterstitialAdUnitId!.trim().isEmpty) {
      return testInterstitialAdUnitIdAndroid;
    }
    return realInterstitialAdUnitId!.trim();
  }

  /// Initialize Mobile Ads SDK and pre-load ads
  Future<void> init() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      debugPrint('🟢 [AdMobService] Google Mobile Ads Initialized Successfully');
      
      // Load remote ad configuration from Firestore if available
      _fetchRemoteConfig();
      
      // Pre-load initial ads immediately
      loadRewardedAd();
      loadInterstitialAd();
    } catch (e) {
      debugPrint('⚠️ [AdMobService] Init notice: $e');
    }
  }

  void _fetchRemoteConfig() {
    if (!FirebaseService.isInitialized) return;
    try {
      FirebaseService.firestore.collection('settings').doc('admob').snapshots().listen((doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          isAdsEnabled = data['enabled'] as bool? ?? true;
          isTestMode = data['is_test_mode'] as bool? ?? true;
          realRewardedAdUnitId = data['rewarded_ad_id'] as String?;
          realBannerAdUnitId = data['banner_ad_id'] as String?;
          realInterstitialAdUnitId = data['interstitial_ad_id'] as String?;
          debugPrint('🔄 [AdMobService] Remote Config synced: AdsEnabled=$isAdsEnabled, TestMode=$isTestMode');
        }
      });
    } catch (e) {
      debugPrint('⚠️ [AdMobService] Remote config listen notice: $e');
    }
  }

  /// Pre-load Rewarded Ad in background so it's ready instantaneously
  void loadRewardedAd() {
    try {
      if (kIsWeb || !isAdsEnabled) return;
      if (_rewardedAd != null || _isRewardedAdLoading) return;

      _isRewardedAdLoading = true;
      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅ [AdMobService] Rewarded Ad Loaded and Ready');
            _rewardedAd = ad;
            _isRewardedAdLoading = false;
            _rewardedRetryAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('⚠️ [AdMobService] Rewarded Ad Failed to Load: $error');
            _rewardedAd = null;
            _isRewardedAdLoading = false;
            _rewardedRetryAttempts++;
            // Exponential backoff retry up to 3 times
            if (_rewardedRetryAttempts <= 3) {
              Future.delayed(Duration(seconds: _rewardedRetryAttempts * 5), () {
                loadRewardedAd();
              });
            }
          },
        ),
      );
    } catch (e) {
      _isRewardedAdLoading = false;
      debugPrint('⚠️ [AdMobService] loadRewardedAd exception: $e');
    }
  }

  /// Show Rewarded Ad. If user watches and completes, [onRewardEarned] is fired.
  /// If ad is not ready or failed, gracefully fallback to [onRewardEarned] to never frustrate the user.
  void showRewardedAd({
    required BuildContext context,
    required VoidCallback onRewardEarned,
    VoidCallback? onCancelled,
  }) {
    // If ads are disabled, directly grant reward
    if (!isAdsEnabled || kIsWeb) {
      onRewardEarned();
      return;
    }

    if (_rewardedAd == null) {
      debugPrint('ℹ️ [AdMobService] Rewarded Ad not ready yet, launching directly to keep user happy');
      onRewardEarned();
      loadRewardedAd();
      return;
    }

    bool userEarnedReward = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('🎬 [AdMobService] Rewarded Ad Showed Full Screen');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('🏁 [AdMobService] Rewarded Ad Dismissed');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Immediately pre-cache next ad

        if (userEarnedReward) {
          onRewardEarned();
        } else {
          if (onCancelled != null) {
            onCancelled();
          }
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('⚠️ [AdMobService] Failed to show Rewarded Ad: $error');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        // Fallback: don't penalize user if ad fails to show
        onRewardEarned();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('🎁 [AdMobService] User successfully earned reward: ${reward.amount} ${reward.type}');
        userEarnedReward = true;
      },
    );
  }

  /// Pre-load Interstitial Ad (5-6 seconds skippable ad)
  void loadInterstitialAd() {
    try {
      if (kIsWeb || !isAdsEnabled) return;
      if (_interstitialAd != null || _isInterstitialAdLoading) return;

      _isInterstitialAdLoading = true;
      InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅ [AdMobService] Interstitial Ad Loaded and Ready');
            _interstitialAd = ad;
            _isInterstitialAdLoading = false;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('⚠️ [AdMobService] Interstitial Ad Failed to Load: $error');
            _interstitialAd = null;
            _isInterstitialAdLoading = false;
          },
        ),
      );
    } catch (e) {
      _isInterstitialAdLoading = false;
      debugPrint('⚠️ [AdMobService] loadInterstitialAd exception: $e');
    }
  }

  /// Show Interstitial Ad (Google Policy: frequency capped, non-intrusive)
  void showInterstitialAd({
    required VoidCallback onDismissed,
  }) {
    if (!isAdsEnabled || kIsWeb) {
      onDismissed();
      return;
    }

    // Google Policy: Respect frequency capping (minimum 45s cooldown)
    final now = DateTime.now();
    if (_lastInterstitialShownAt != null && now.difference(_lastInterstitialShownAt!).inSeconds < 45) {
      onDismissed();
      return;
    }

    if (_interstitialAd == null) {
      onDismissed();
      loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _lastInterstitialShownAt = DateTime.now();
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onDismissed();
      },
    );

    _interstitialAd!.setImmersiveMode(true);
    _interstitialAd!.show();
  }
}

/// Reusable Sleek AdMob Banner Ad Widget
class AdMobBannerWidget extends StatefulWidget {
  final EdgeInsetsGeometry padding;

  const AdMobBannerWidget({
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    if (kIsWeb || !AdMobService.instance.isAdsEnabled) return;

    _bannerAd = BannerAd(
      adUnitId: AdMobService.instance.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('⚠️ [AdMobBanner] Banner failed to load: $error');
          ad.dispose();
          _bannerAd = null;
          if (mounted) {
            setState(() => _isLoaded = false);
          }
        },
      ),
    );

    try {
      _bannerAd!.load();
    } catch (e) {
      debugPrint('⚠️ [AdMobBanner] Load exception: $e');
      _bannerAd?.dispose();
      _bannerAd = null;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: widget.padding,
      alignment: Alignment.center,
      color: Colors.white,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble() + 16,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
