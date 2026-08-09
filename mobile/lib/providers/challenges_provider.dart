import 'package:flutter/material.dart';
import 'package:fluentsoul_mobile/data/challenges_data.dart';
import 'package:fluentsoul_mobile/models/challenge.dart';

class ChallengesProvider with ChangeNotifier {
  int _xp = 640; // Initial mock state matching UI mockup
  int _quietStreak = 2; // Initial mock state showing nudge banner
  int _todayQuietXp = 10;
  final Set<String> _unlockedWeeklyBossIds = {'interruption_test'};

  // Inventory item counts
  int _rescueTokens = 3;
  int _streakShields = 1;
  int _rewinds = 2;

  int get xp => _xp;
  int get quietStreak => _quietStreak;
  int get todayQuietXp => _todayQuietXp;
  Set<String> get unlockedWeeklyBossIds => _unlockedWeeklyBossIds;

  int get rescueTokens => _rescueTokens;
  int get streakShields => _streakShields;
  int get rewinds => _rewinds;

  RankProgress get rankProgress => getRankProgress(_xp);
  bool get shouldNudge => shouldNudgeToVoice(_quietStreak);

  void completeChallenge(Challenge challenge) {
    if (challenge.requiresVoice) {
      _xp += challenge.xp;
      _quietStreak = 0; // Reset quiet streak on voice challenge
    } else {
      final potentialNewQuietTotal = _todayQuietXp + challenge.xp;
      final cappedTotal = capQuietXp(potentialNewQuietTotal);
      final actualXpAwarded = cappedTotal - _todayQuietXp;
      if (actualXpAwarded > 0) {
        _xp += actualXpAwarded;
        _todayQuietXp = cappedTotal;
      }
      _quietStreak += 1;
    }
    notifyListeners();
  }

  void consumeRescueToken() {
    if (_rescueTokens > 0) {
      _rescueTokens--;
      notifyListeners();
    }
  }

  void consumeStreakShield() {
    if (_streakShields > 0) {
      _streakShields--;
      notifyListeners();
    }
  }

  void consumeRewind() {
    if (_rewinds > 0) {
      _rewinds--;
      notifyListeners();
    }
  }
}
