import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdInitialized = false; // Prevent re-running in didChangeDependencies

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Prevent loading ad multiple times
    if (!_isAdInitialized) {
      _isAdInitialized = true;
      _loadBannerAd();
    }
  }

  Future<void> _initialize() async {
    await Future.delayed(Duration(seconds: 2));
    // TODO: Add navigation logic here, like Navigator.pushReplacement
  }

  void _loadBannerAd() {
    final adUnitId = Theme.of(context).platform == TargetPlatform.iOS
        ? dotenv.env['BANNER_AD_UNIT_ID_IOS']
        : dotenv.env['BANNER_AD_UNIT_ID_ANDROID'];

    if (adUnitId == null || adUnitId.isEmpty) {
      print("Ad Unit ID is not set in .env file.");
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad load failed: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text("Splash Screen ($_isAdLoaded)"),
            ),
          ),
          if (_isAdLoaded && _bannerAd != null)
            SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
