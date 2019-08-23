import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:async';
import 'bottomcontrols.dart';
import 'musicplayer.dart' as musicplayer;
import 'package:music_player/theme.dart';
import 'package:fluttery/gestures.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:vector_math/vector_math.dart' as Vector;

class PlayPage extends StatefulWidget {
  PlayPageState createState() => PlayPageState();
}

class PlayPageState extends State<PlayPage> with TickerProviderStateMixin {
  final Random random = new Random();

  AnimationController animationController;
  List<Offset> animList1 = [];

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  ScrollController _scrollController;

  bool webview = false;

  void initState() {
    super.initState();
    // data = _generateRandomData();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 2));

    animationController.addListener(() {
      animList1.clear();
      for (int i = -2 - 0;
          i <= MediaQuery.of(context).size.width.toInt() + 2;
          i++) {
        animList1.add(new Offset(
            i.toDouble() + 0,
            sin((animationController.value * 360 - i) %
                        360 *
                        Vector.degrees2Radians) *
                    20 +
                50 +
                0));
      }
    });

    _positionSubscription = musicplayer.audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() {
              musicplayer.position = p;
            }));

            
    _audioPlayerStateSubscription =
        musicplayer.audioPlayer.onPlayerStateChanged.listen((s) {
          
      if (s == AudioPlayerState.PLAYING) {
        print("test");
        setState(() {
          animationController.forward();
          musicplayer.duration = musicplayer.audioPlayer.duration;
        });
      } else if (s == AudioPlayerState.STOPPED) {
        setState(() {
          animationController.reset();
        });
        /*
        setState(() {musicplayer.position = musicplayer.duration;
          if (musicplayer.shuffle) {
            musicplayer.stop();
            Random _random = new Random();
            int r = _random.nextInt(musicplayer.allFilePaths.length);
  
            musicplayer.currTrack = r;
            musicplayer.play(musicplayer.allFilePaths[musicplayer.currTrack]);

            musicplayer.playerState = musicplayer.PlayerState.playing;
            musicplayer.currTrackName =
                musicplayer.allFilePaths[musicplayer.currTrack];
          } else {
            if (musicplayer.currTrack != musicplayer.allFilePaths.length - 1) {
              musicplayer.stop();
              musicplayer.currTrack = musicplayer.currTrack + 1;
              musicplayer.play(musicplayer.allFilePaths[musicplayer.currTrack]);

              musicplayer.playerState = musicplayer.PlayerState.playing;
              musicplayer.currTrackName =
                  musicplayer.allFilePaths[musicplayer.currTrack];
            }
          }
        });*/
      }
    }, onError: (msg) {
      setState(() {
        // musicplayer.playerState = PlayerState.stopped;
        musicplayer.duration = new Duration(seconds: 0);
        musicplayer.position = new Duration(seconds: 0);
      });
    });
  }

  /*
List<CircularStackEntry> _generateRandomData() {
    int stackCount = random.nextInt(10);
    List<CircularStackEntry> data = new List.generate(stackCount, (i) {
      int segCount = random.nextInt(10);
      List<CircularSegmentEntry> segments =  new List.generate(segCount, (j) {
        Color randomColor = ColorPalette.primary.random(random);
        return new CircularSegmentEntry(random.nextDouble(), randomColor);
      });
      return new CircularStackEntry(segments);
    });

    return data;
  }
  */
  List<double> _generateRandomData(int count) {
    List<double> result = <double>[];
    for (int i = 0; i < count; i++) {
      result.add(random.nextDouble() * 100);
    }
    return result;
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();

    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> musicList;
    musicList = new List<String>();
    var data = _generateRandomData(50);
/*
Timer.periodic(Duration(seconds: 2), (timer) {
  setState(() {
    
  data = _generateRandomData(50);
  });
});
*/
    musicplayer.allFilePaths.forEach((f) {
      musicList.add(f.toString());
    });

    return new Scaffold(
      appBar: new AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: new IconButton(
            icon: new Icon(
              Icons.arrow_back_ios,
            ),
            color: Colors.orangeAccent[200],
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: new Text(''),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.font_download),
              color: Colors.orangeAccent[200],
              onPressed: () {
                setState(() {
                  webview = true;
                });
              },
            ),
          ]),
      body: new Column(
        children: <Widget>[
          // Seek bar
          Expanded(
              child: new AudioRadialSeekBar(
            albumArtUrl: musicplayer.currTrackName,
          )),

// Visualizer
          new AnimatedBuilder(
            animation: new CurvedAnimation(
              parent: animationController,
              curve: Curves.easeInOut,
            ),
            builder: (context, child) => new ClipPath(
              child: new Container(
                width: MediaQuery.of(context).size.width,
                height: 200.0,
                color: Colors.deepOrangeAccent,
              ),
              clipper: new WaveClipper(animationController.value, animList1),
            ),
          ),

          // Song title, artist name, and controls
          new BottomControls(parentAction: _updateAlbum)
        ],
      ),
    );
  }

  _updateAlbum() {
    setState(() {
      if (musicplayer.playerState == musicplayer.PlayerState.paused ||
          musicplayer.playerState == musicplayer.PlayerState.stopped)
        animationController.reset();
    });
    
  }
}

class AudioRadialSeekBar extends StatefulWidget {
  final String albumArtUrl;

  AudioRadialSeekBar({
    this.albumArtUrl,
  });

  @override
  AudioRadialSeekBarState createState() {
    return new AudioRadialSeekBarState();
  }
}

class AudioRadialSeekBarState extends State<AudioRadialSeekBar> {
  double _seekPercent;

  @override
  Widget build(BuildContext context) {
    double playbackProgress = 0.0;
    if (musicplayer.position != null) {
      playbackProgress = musicplayer.position.inMilliseconds /
          musicplayer.duration.inMilliseconds;
    }
    return new RadialSeekBar(
      progress: playbackProgress,
      seekPercent: _seekPercent,
      onSeekRequested: (double seekPercent) {
        setState(() => _seekPercent = seekPercent);

        if (seekPercent != null) {
          final seekMillis =
              (musicplayer.duration.inMilliseconds * seekPercent).round();

          musicplayer.seek(seekMillis);
        }
      },
      child: new Container(
        color: accentColor,
        child: musicplayer.getImage(
            musicplayer.allMetaData[musicplayer.currTrack][2], context),
      ),
    );
    // },
    //);
  }
}

class RadialSeekBar extends StatefulWidget {
  final double progress;
  final double seekPercent;
  final Function(double) onSeekRequested;
  final Widget child;

  RadialSeekBar({
    this.progress = 0.0,
    this.seekPercent = 0.0,
    this.onSeekRequested,
    this.child,
  });

  @override
  RadialSeekBarState createState() {
    return new RadialSeekBarState();
  }
}

class RadialSeekBarState extends State<RadialSeekBar> {
  double _progress = 0.0;
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _currentDragPercent;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
  }

  @override
  void didUpdateWidget(RadialSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _progress = widget.progress;
  }

  void _onDragStart(PolarCoord coord) {
    _startDragCoord = coord;
    _startDragPercent = _progress;
  }

  void _onDragUpdate(PolarCoord coord) {
    final dragAngle = coord.angle - _startDragCoord.angle;
    final dragPercent = dragAngle / (2 * pi);

    setState(() {
      _currentDragPercent = (_startDragPercent + dragPercent) % 1.0;
    });
  }

  void update() {
    setState(() {});
  }

  void _onDragEnd() {
    if (widget.onSeekRequested != null) {
      widget.onSeekRequested(_currentDragPercent);
    }

    setState(() {
      
      _currentDragPercent = null;
      _startDragCoord = null;
      _startDragPercent = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double thumbPosition = _progress;
    if (_currentDragPercent != null) {
      thumbPosition = _currentDragPercent;
    } 
    

    return new RadialDragGestureDetector(
      onRadialDragStart: _onDragStart,
      onRadialDragUpdate: _onDragUpdate,
      onRadialDragEnd: _onDragEnd,
      child: new Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: new Center(
            child: new Container(
          width: 240.0,
          height: 240.0,
          child: new RadialProgressBar(
            trackColor: const Color(0xFFDDDDDD),
            progressPercent: _progress,
            progressColor: accentColor,
            thumbPosition: thumbPosition,
            thumbColor: lightAccentColor,
            innerPadding: const EdgeInsets.all(10.0),
            child: new ClipOval(
              clipper: new CircleClipper(),
              child: widget.child,
            ),
          ),
        )),
      ),
    );
  }
}

class RadialProgressBar extends StatefulWidget {
  final double trackWidth;
  final Color trackColor;
  final double progressWidth;
  final Color progressColor;
  final double progressPercent;
  final double thumbSize;
  final Color thumbColor;
  final double thumbPosition;
  final EdgeInsets outerPadding;
  final EdgeInsets innerPadding;
  final Widget child;

  RadialProgressBar({
    this.trackWidth = 3.0,
    this.trackColor = Colors.grey,
    this.progressWidth = 5.0,
    this.progressColor = Colors.black,
    this.progressPercent = 0.0,
    this.thumbSize = 10.0,
    this.thumbColor = Colors.black,
    this.thumbPosition = 0.0,
    this.outerPadding = const EdgeInsets.all(0.0),
    this.innerPadding = const EdgeInsets.all(0.0),
    this.child,
  });

  @override
  _RadialProgressBarState createState() => new _RadialProgressBarState();
}

class _RadialProgressBarState extends State<RadialProgressBar> {
  EdgeInsets _insetsForPainter() {
    // Make room for the painted track, progress, and thumb.  We divide by 2.0
    // because we want to allow flush painting against the track, so we only
    // need to account the thickness outside the track, not inside.
    final outerThickness = max(
          widget.trackWidth,
          max(
            widget.progressWidth,
            widget.thumbSize,
          ),
        ) /
        2.0;
    return new EdgeInsets.all(outerThickness);
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: widget.outerPadding,
      child: new CustomPaint(
        foregroundPainter: new RadialSeekBarPainter(
          trackWidth: widget.trackWidth,
          trackColor: widget.trackColor,
          progressWidth: widget.progressWidth,
          progressColor: widget.progressColor,
          progressPercent: widget.progressPercent,
          thumbSize: widget.thumbSize,
          thumbColor: widget.thumbColor,
          thumbPosition: widget.thumbPosition,
        ),
        child: new Padding(
          padding: _insetsForPainter() + widget.innerPadding,
          child: widget.child,
        ),
      ),
    );
  }
}

class RadialSeekBarPainter extends CustomPainter {
  final double trackWidth;
  final Paint trackPaint;
  final double progressWidth;
  final Paint progressPaint;
  final double progressPercent;
  final double thumbSize;
  final Paint thumbPaint;
  final double thumbPosition;

  RadialSeekBarPainter({
    @required this.trackWidth,
    @required trackColor,
    @required this.progressWidth,
    @required progressColor,
    @required this.progressPercent,
    @required this.thumbSize,
    @required thumbColor,
    @required this.thumbPosition,
  })  : trackPaint = new Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackWidth,
        progressPaint = new Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = progressWidth
          ..strokeCap = StrokeCap.round,
        thumbPaint = new Paint()
          ..color = thumbColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final outerThickness = max(trackWidth, max(progressWidth, thumbSize));
    Size constrainedSize = new Size(
      size.width - outerThickness,
      size.height - outerThickness,
    );

    final center = new Offset(size.width / 2, size.height / 2);
    final radius = min(constrainedSize.width, constrainedSize.height) / 2;

    // Paint track.
    canvas.drawCircle(
      center,
      radius,
      trackPaint,
    );

    // Paint progress.
    final progressAngle = 2 * pi * progressPercent;
    canvas.drawArc(
      new Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -pi / 2,
      progressAngle,
      false,
      progressPaint,
    );

    // Paint thumb.
    final thumbAngle = 2 * pi * thumbPosition - (pi / 2);
    final thumbX = cos(thumbAngle) * radius;
    final thumbY = sin(thumbAngle) * radius;
    final thumbCenter = new Offset(thumbX, thumbY) + center;
    final thumbRadius = thumbSize / 2.0;
    canvas.drawCircle(
      thumbCenter,
      thumbRadius,
      thumbPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animation;

  List<Offset> waveList1 = [];

  WaveClipper(this.animation, this.waveList1);

  @override
  Path getClip(Size size) {
    Path path = new Path();

    path.addPolygon(waveList1, false);

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      animation != oldClipper.animation;
}
