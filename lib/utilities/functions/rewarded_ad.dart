import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

RewardedAd? _rewardedAd;
// TODO: Figure out how to load the ad first and then show it after loading it
// TODO: replace this test ad unit with your own ad unit.
final adUnitId = Platform.isAndroid ? 'ca-app-pub-3940256099942544/5224354917' : 'ca-app-pub-3940256099942544/1712485313';

/// Loads a rewarded ad.
Future<void> loadAd() async {
  await RewardedAd.load(
    adUnitId: adUnitId,
    request: const AdRequest(),
    rewardedAdLoadCallback: RewardedAdLoadCallback(
      // Called when an ad is successfully received.
      onAdLoaded: (ad) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
            // Called when the ad showed the full screen content.
            onAdShowedFullScreenContent: (ad) {
          debugPrint("Ad showed in fullscreen");
        },
            // Called when an impression occurs on the ad.
            onAdImpression: (ad) {
          debugPrint("impression on ad");
        },
            // Called when the ad failed to show full screen content.
            onAdFailedToShowFullScreenContent: (ad, err) {
          // Dispose the ad here to free resources.
          debugPrint("failed to show ad. Disposing");
          ad.dispose();
        },
            // Called when the ad dismissed full screen content.
            onAdDismissedFullScreenContent: (ad) {
          // Dispose the ad here to free resources.
          debugPrint("Ad dismissed. Disposing");
          ad.dispose();
        },
            // Called when a click is recorded for an ad.
            onAdClicked: (ad) {
          debugPrint("ad clicked");
        });
        debugPrint('$ad loaded.');
        // Keep a reference to the ad so you can show it later.
        _rewardedAd = ad;
      },
      // Called when an ad request failed.
      onAdFailedToLoad: (LoadAdError error) {
        debugPrint('RewardedAd failed to load: $error');
      },
    ),
  );
}

Future<void> showAd() async {
  final rewardedAd = _rewardedAd;
  if (rewardedAd != null) {
    await rewardedAd.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      // Reward the user for watching an ad.
      debugPrint("reward received");
    });
  }
}
