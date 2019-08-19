import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:async';
import 'musicplayer.dart' as musicplayer;
import 'package:music_player/theme.dart';
import 'package:fluttery/gestures.dart';

class BottomControls extends StatefulWidget {
  final void Function() parentAction;
  const BottomControls({Key key, this.parentAction}) : super(key: key);

  BottomControlsState createState() => BottomControlsState();
}

class BottomControlsState extends State<BottomControls> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      width: double.infinity,
      child: new Material(
        shadowColor: const Color(0x44000000),
        color: Colors.deepOrangeAccent,
        child: new Padding(
          padding: const EdgeInsets.only(top: 40.0, bottom: 50.0),
          child: new Column(
            children: <Widget>[
              /*  new AudioPlaylistComponent(
                playlistBuilder: (BuildContext context, Playlist playlist, Widget child) {
                  final songTitle = musicplayer.allFilePaths[playlist.activeIndex];
                  final artistName = musicplayer.allFilePaths[playlist.activeIndex];
*/
              new RichText(
                text: new TextSpan(text: '', children: [
                  new TextSpan(
                    text: musicplayer.getBaseName(musicplayer
                        .currTrack), // '${songTitle.toUpperCase()}\n',
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                      height: 1.5,
                    ),
                  ),
                ]),
                textAlign: TextAlign.center,
                //   );
                // },
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: new Row(
                  children: <Widget>[
                    new Expanded(child: new Container()),
                    previousButton(),
                    new Expanded(child: new Container()),
                    playButton(),
                    new Expanded(child: new Container()),
                    nextButton(),
                    new Expanded(child: new Container()),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget nextButton() {
    return new IconButton(
      splashColor: lightAccentColor,
      highlightColor: Colors.transparent,
      icon: new Icon(
        Icons.skip_next,
        color: musicplayer.currTrack == musicplayer.allFilePaths.length - 1
            ? Colors.grey
            : Colors.white,
        size: 35.0,
      ),
      onPressed: playNextTrack,
    );
  }

  void playNextTrack() {
    if (musicplayer.currTrack != musicplayer.allFilePaths.length - 1) {
      setState(() {
        musicplayer.stop();
        musicplayer.currTrack = musicplayer.currTrack + 1;
        musicplayer.play(musicplayer.allFilePaths[musicplayer.currTrack]);

        musicplayer.playerState = musicplayer.PlayerState.playing;
        musicplayer.currTrackName =
            musicplayer.allFilePaths[musicplayer.currTrack];

        widget.parentAction();
      });
    }
  }

  Widget playButton() {
    IconData icon = Icons.music_note;
    Color buttonColor = lightAccentColor;
    Function onPressed;
    if (musicplayer.playerState == musicplayer.PlayerState.playing) {
      icon = Icons.pause;
      onPressed = pause;
      buttonColor = Colors.white;
    } else if (musicplayer.playerState == musicplayer.PlayerState.paused ||
        musicplayer.playerState == musicplayer.PlayerState.stopped) {
      icon = Icons.play_arrow;
      onPressed = play;
      buttonColor = Colors.white;
    }

    return new RawMaterialButton(
      shape: new CircleBorder(),
      fillColor: buttonColor,
      splashColor: lightAccentColor,
      highlightColor: lightAccentColor.withOpacity(0.5),
      elevation: 10.0,
      highlightElevation: 5.0,
      onPressed: onPressed,
      child: new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Icon(
          icon,
          color: darkAccentColor,
          size: 35.0,
        ),
      ),
    );
  }

  void play() {
    musicplayer.play(musicplayer.allFilePaths[musicplayer.currTrack]);

    setState(() {
      musicplayer.playerState = musicplayer.PlayerState.playing;
      musicplayer.currTrackName =
          musicplayer.allFilePaths[musicplayer.currTrack];
          
        widget.parentAction();
    });
  }

  void pause() {
    musicplayer.pause();
    setState(() {
      musicplayer.playerState = musicplayer.PlayerState.paused;
      
        widget.parentAction();
    });
  }

  Widget previousButton() {
    return new IconButton(
      splashColor: lightAccentColor,
      highlightColor: Colors.transparent,
      icon: new Icon(
        Icons.skip_previous,
        color: musicplayer.currTrack == 0 ? Colors.grey : Colors.white,
        size: 35.0,
      ),
      onPressed: playPreviousTrack,
    );
  }

  void playPreviousTrack() {
    if (musicplayer.currTrack != 0) {
      setState(() {
        musicplayer.stop();
        musicplayer.currTrack = musicplayer.currTrack - 1;
        musicplayer.play(musicplayer.allFilePaths[musicplayer.currTrack]);

        musicplayer.playerState = musicplayer.PlayerState.playing;
        musicplayer.currTrackName =
            musicplayer.allFilePaths[musicplayer.currTrack];
            
        widget.parentAction();
      });
    }
  }
}

class CircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return new Rect.fromCircle(
      center: new Offset(size.width / 2, size.height / 2),
      radius: min(size.width, size.height) / 2,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
