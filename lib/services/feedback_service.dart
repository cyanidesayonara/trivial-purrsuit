import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../models/game_types.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final Map<GameObjectSound, AudioPlayer> _players = {};
  final Map<GameObjectSound, DateTime> _lastPlayTime = {};
  bool _initialized = false;

  // Minimum time between sounds in milliseconds
  static const _minTimeBetweenSounds = {
    GameObjectSound.mouse: 100,
    GameObjectSound.bug: 100,
    GameObjectSound.laser: 100,
    GameObjectSound.feather: 100,
    GameObjectSound.yarnBall: 200,  // Longer delay for yarn ball to prevent rapid bounces
  };

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      print('Initializing feedback service...');
      print('Current platform: ${defaultTargetPlatform}');

      // Initialize global audio context
      await AudioPlayer.global.setGlobalAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: [
              AVAudioSessionOptions.mixWithOthers,
            ],
          ),
        ),
      );

      // Initialize audio players for each sound
      for (var sound in GameObjectSound.values) {
        try {
          print('Initializing sound for $sound...');
          final player = await _initializePlayer(sound);
          _players[sound] = player;
          
          // Set up player event listeners
          player.onPlayerStateChanged.listen((state) {
            print('Player state changed for $sound: $state');
          });

          player.onPlayerComplete.listen((_) {
            print('Player completed for $sound');
          });

          print('Successfully initialized player for $sound');
        } catch (e, stackTrace) {
          print('Failed to initialize sound for $sound: $e');
          print('Stack trace: $stackTrace');
          // Remove the failed player
          await _players[sound]?.dispose();
          _players.remove(sound);
        }
      }

      print('Sound initialization complete. Active sounds: ${_players.keys.length}');
    } catch (e, stackTrace) {
      print('Failed to initialize audio system: $e');
      print('Stack trace: $stackTrace');
    }

    _initialized = true;
  }

  Future<AudioPlayer> _initializePlayer(GameObjectSound sound) async {
    final player = AudioPlayer(playerId: sound.toString());
    await player.setVolume(1.0);
    return player;
  }

  String _getSoundFileName(GameObjectSound sound) {
    switch (sound) {
      case GameObjectSound.mouse:
        return 'cat_toy.mp3';
      case GameObjectSound.bug:
        return 'squish.mp3';
      case GameObjectSound.laser:
        return 'beep.mp3';
      case GameObjectSound.feather:
        return 'whoosh.mp3';
      case GameObjectSound.yarnBall:
        return 'bounce.mp3';
    }
  }

  Future<void> playFeedback(GameObjectSound sound, {bool isBounce = false}) async {
    try {
      // Check if enough time has passed since the last sound
      final now = DateTime.now();
      final lastPlay = _lastPlayTime[sound] ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeSinceLastPlay = now.difference(lastPlay).inMilliseconds;
      
      if (timeSinceLastPlay < _minTimeBetweenSounds[sound]!) {
        print('Skipping sound for $sound - too soon (${timeSinceLastPlay}ms < ${_minTimeBetweenSounds[sound]}ms)');
        return;
      }
      _lastPlayTime[sound] = now;

      // Play sound if available
      final player = _players[sound];
      if (player != null) {
        print('Playing sound for $sound');
        try {
          // Always create a new player for each sound to avoid state issues
          final newPlayer = AudioPlayer(playerId: '${sound}_${now.millisecondsSinceEpoch}');
          await newPlayer.setVolume(1.0);
          print('Set volume to 1.0 for $sound');
          
          await newPlayer.play(AssetSource('sounds/${_getSoundFileName(sound)}'));
          print('Started playback for $sound');
          
          // Clean up the old player
          await player.dispose();
          _players[sound] = newPlayer;
          
          // Set up player event listeners
          newPlayer.onPlayerStateChanged.listen((state) {
            print('Player state changed for $sound: $state');
          });

          newPlayer.onPlayerComplete.listen((_) {
            print('Player completed for $sound');
            // Clean up completed player
            newPlayer.dispose().then((_) {
              if (_players[sound] == newPlayer) {
                _players.remove(sound);
              }
            });
          });
        } catch (e, stackTrace) {
          print('Failed to play sound for $sound: $e');
          print('Stack trace: $stackTrace');
          
          // Try to recover by creating a new player
          try {
            _players[sound] = await _initializePlayer(sound);
          } catch (e2) {
            print('Failed to recover player for $sound: $e2');
          }
        }
      } else {
        print('No sound player available for $sound');
        // Try to create a new player
        try {
          _players[sound] = await _initializePlayer(sound);
        } catch (e) {
          print('Failed to create new player for $sound: $e');
        }
      }

      // Only vibrate if enough time has passed
      if (timeSinceLastPlay >= _minTimeBetweenSounds[sound]!) {
        try {
          final hasVibrator = await Vibration.hasVibrator() ?? false;
          final hasAmplitudeControl = await Vibration.hasCustomVibrationsSupport() ?? false;
          print('Vibrator available: $hasVibrator, has amplitude control: $hasAmplitudeControl');

          if (hasVibrator) {
            int duration;
            int amplitude = hasAmplitudeControl ? 128 : -1;  // Use -1 if no amplitude control

            switch (sound) {
              case GameObjectSound.mouse:
                duration = 40;
                if (hasAmplitudeControl) amplitude = 255;  
                break;
              case GameObjectSound.bug:
                duration = 60;
                if (hasAmplitudeControl) amplitude = 255;
                break;
              case GameObjectSound.laser:
                duration = 30;
                if (hasAmplitudeControl) amplitude = 255;
                break;
              case GameObjectSound.feather:
                duration = 50;
                if (hasAmplitudeControl) amplitude = 255;  
                break;
              case GameObjectSound.yarnBall:
                // For yarn ball, use simpler vibration when bouncing rapidly
                if (timeSinceLastPlay < 500) {  // If bouncing very fast
                  duration = 40;
                  if (hasAmplitudeControl) amplitude = 255;  
                  await Vibration.vibrate(duration: duration, amplitude: amplitude);
                  return;
                }
                
                // Otherwise use the full pattern
                duration = isBounce ? 80 : 60;
                if (hasAmplitudeControl) amplitude = 255;
                
                print('Starting yarn ball vibration pattern');
                if (isBounce) {
                  await Vibration.vibrate(
                    pattern: [0, 80, 50, 60, 50, 40],
                    intensities: hasAmplitudeControl ? [255, 255, 200] : [],  
                  );
                } else {
                  await Vibration.vibrate(
                    pattern: [0, 60, 40, 40],
                    intensities: hasAmplitudeControl ? [255, 255] : [],  
                  );
                }
                print('Yarn ball vibration pattern completed');
                return;
            }

            print('Attempting to vibrate: duration=$duration, amplitude=$amplitude');
            if (hasAmplitudeControl) {
              await Vibration.vibrate(duration: duration, amplitude: amplitude);
            } else {
              await Vibration.vibrate(duration: duration);
            }
            print('Vibration command sent successfully');
          } else {
            print('No vibrator available on this device');
          }
        } catch (e, stackTrace) {
          print('Failed to vibrate for $sound: $e');
          print('Vibration error stack trace: $stackTrace');
        }
      }
    } catch (e, stackTrace) {
      print('Failed to play feedback for $sound: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> dispose() async {
    for (var player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _initialized = false;
  }
}
