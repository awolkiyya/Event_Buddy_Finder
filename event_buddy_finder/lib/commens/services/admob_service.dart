import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  static const String bannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB';
  static const String interstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/IIIIIIIIII';
  static const String rewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/RRRRRRRRRR';

  BannerAd? bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  void loadBannerAd(Function onAdLoaded) {
    bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('BannerAd failed: $error');
        },
      ),
    )..load();
  }

  void loadInterstitialAd(Function onReady) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          onReady();
        },
        onAdFailedToLoad: (error) => print('Interstitial failed: $error'),
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  void loadRewardedAd(Function onReady) {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          onReady();
        },
        onAdFailedToLoad: (error) => print('Rewarded failed: $error'),
      ),
    );
  }

  void showRewardedAd(Function(int) onRewardEarned) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned(reward.amount.toInt());
        },
      );
      _rewardedAd = null;
    }
  }

  void dispose() {
    bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
