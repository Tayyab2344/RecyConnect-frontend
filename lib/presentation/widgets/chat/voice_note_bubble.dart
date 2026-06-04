import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class VoiceNoteBubble extends StatefulWidget {
  final String voiceUrl;
  final bool isMe;

  const VoiceNoteBubble({
    Key? key,
    required this.voiceUrl,
    required this.isMe,
  }) : super(key: key);

  @override
  State<VoiceNoteBubble> createState() => _VoiceNoteBubbleState();
}

class _VoiceNoteBubbleState extends State<VoiceNoteBubble> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _completionSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listen to changes in player state
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });

    // Listen to audio duration changes
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    // Listen to audio current position changes
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Listen to playback completion
    _completionSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _completionSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.voiceUrl));
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlaying = _playerState == PlayerState.playing;
    final Color textColor = widget.isMe ? Colors.white : Colors.black87;
    final Color iconColor = widget.isMe ? Colors.white : Colors.green.shade700;
    final Color sliderActiveColor = widget.isMe ? Colors.white : Colors.green;
    final Color sliderInactiveColor = widget.isMe ? Colors.white24 : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause Button
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              size: 36,
              color: iconColor,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: _playPause,
          ),
          const SizedBox(width: 8),

          // Progress and Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Slider
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                    activeTrackColor: sliderActiveColor,
                    inactiveTrackColor: sliderInactiveColor,
                    thumbColor: sliderActiveColor,
                    overlayColor: sliderActiveColor.withOpacity(0.2),
                  ),
                  child: Slider(
                    min: 0.0,
                    max: _duration.inMilliseconds.toDouble() > 0.0
                        ? _duration.inMilliseconds.toDouble()
                        : 1.0,
                    value: _position.inMilliseconds.toDouble().clamp(
                          0.0,
                          _duration.inMilliseconds.toDouble() > 0.0
                              ? _duration.inMilliseconds.toDouble()
                              : 1.0,
                        ),
                    onChanged: (value) async {
                      final duration = Duration(milliseconds: value.toInt());
                      await _audioPlayer.seek(duration);
                    },
                  ),
                ),
                // Timer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 10),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
