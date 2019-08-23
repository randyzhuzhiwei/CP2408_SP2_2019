import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'musicplayer.dart' as musicplayer;
import 'package:audioplayer/audioplayer.dart';
import 'PlayPage.dart';

enum ControlState { list, cover }

class HomePage extends StatefulWidget {
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  ScrollController _scrollController;

  ControlState view = ControlState.list;

  int randnum;
  void initAudioPlayer() {
    musicplayer.audioPlayer = new AudioPlayer();
    _positionSubscription = musicplayer.audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() {
              musicplayer.position = p;
            }));
    _audioPlayerStateSubscription =
        musicplayer.audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => musicplayer.duration = musicplayer.audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED && musicplayer.action==false) {
        setState(() {
          musicplayer.position = musicplayer.duration;
          if (musicplayer.shuffle) {
            print("random");
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
            else
            {
               musicplayer.stop();
                musicplayer.playerState = musicplayer.PlayerState.stopped;
            }
          }
        });
      }
    }, onError: (msg) {
      setState(() {
        // musicplayer.playerState = PlayerState.stopped;
        musicplayer.duration = new Duration(seconds: 0);
        musicplayer.position = new Duration(seconds: 0);
      });
    });
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    musicplayer.audioPlayer.stop();
    super.dispose();
  }

  scrollQueue() {
    // scrolls to current track
    try {
      _scrollController.jumpTo(musicplayer.currTrack * 108.0);
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    initAudioPlayer();
    musicplayer.getFavTrackList().then((l) {
      musicplayer.favList = l;
    });
    musicplayer.getPlayListNames().then((l) {
      musicplayer.playlistNames = l;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollQueue());
    musicplayer.hideAppBarAgain();
    musicplayer.allMetaData.forEach((f) {
      //  print(f);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = size.height / 8;
    final double itemWidth = size.width / 2;

    return Scaffold(
        //drawer: musicplayer.AppDrawer(),
        backgroundColor: Colors.deepOrangeAccent,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Music Player",
                        style: TextStyle(fontSize: 22.0, color: Colors.white),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 70.0, right: 70.0),
                        child: Divider(color: Colors.white),
                      )
                    ],
                  )),
              Expanded(
                  child: view == ControlState.list
                      ? ListView.builder(
                          itemCount: musicplayer.allFilePaths.length,
                          itemBuilder: (BuildContext context, int index) {
                            String basename = musicplayer.getBaseName(index);

                            return Card(
                                elevation: 10.0,
                                color: musicplayer.currTrackName ==
                                        musicplayer.allFilePaths[index]
                                    ? musicplayer.playerState ==
                                            musicplayer.PlayerState.playing
                                        ? Colors.blue[100]
                                        : Colors.green
                                    : Colors.deepOrangeAccent[100],
                                child: ListTile(
                                  leading: Container(
                                    padding: EdgeInsets.only(right: 12.0),
                                    decoration: new BoxDecoration(
                                        border: new Border(
                                            right: new BorderSide(
                                                width: 1.0,
                                                color: Colors.white24))),
                                    child: Icon(Icons.music_note,
                                        color: Colors.white),
                                  ),
                                  title: Text(basename),
                                  onTap: () async {
                                    if (musicplayer.currTrackName ==
                                        musicplayer.allFilePaths[index]) {
                                      if (musicplayer.playerState !=
                                          musicplayer.PlayerState.playing) {
                                        await musicplayer.play(
                                            musicplayer.allFilePaths[index]);
                                        musicplayer.currTrackName =
                                            musicplayer.allFilePaths[index];
                                        setState(() {
                                          musicplayer.playerState =
                                              musicplayer.PlayerState.playing;
                                        });
                                      } else {
                                        await musicplayer.pause();
                                        setState(() {
                                          musicplayer.playerState =
                                              musicplayer.PlayerState.paused;
                                        });
                                      }
                                    } else {
                                      musicplayer.action=true;
                                      await musicplayer.stop();
                                      await musicplayer.play(
                                          musicplayer.allFilePaths[index]);
                                          
                                      musicplayer.action=false;
                                      musicplayer.currTrackName =
                                          musicplayer.allFilePaths[index];
                                      setState(() {
                                        musicplayer.playerState =
                                            musicplayer.PlayerState.playing;
                                      });
                                    }

                                    musicplayer.currTrack = index;
                                    print( musicplayer.currTrack);
                                  },
                                ));
                          })
                      : ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                          scrollDirection: Axis.horizontal,
                          itemCount: musicplayer.allFilePaths.length,
                          itemBuilder: (context, index) {
                            String basename = musicplayer.getBaseName(index);
                            
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  color: musicplayer.currTrackName ==
                                          musicplayer.allFilePaths[index]
                                      ? musicplayer.playerState ==
                                              musicplayer.PlayerState.playing
                                          ? Colors.blue[100]
                                          : Colors.green[100]
                                      : Colors.deepOrangeAccent[100],
                                  child: InkWell(
                                      onTap: () {
                                        if (musicplayer.currTrackName ==
                                            musicplayer.allFilePaths[index]) {
                                          if (musicplayer.playerState !=
                                              musicplayer.PlayerState.playing) {
                                            musicplayer.play(musicplayer
                                                .allFilePaths[index]);
                                            musicplayer.currTrackName =
                                                musicplayer.allFilePaths[index];
                                            setState(() {
                                              musicplayer.playerState =
                                                  musicplayer
                                                      .PlayerState.playing;
                                            });
                                          } else {
                                            musicplayer.pause();
                                            setState(() {
                                              musicplayer.playerState =
                                                  musicplayer
                                                      .PlayerState.paused;
                                            });
                                          }
                                        } else {
                                          
                                      musicplayer.action=true;
                                          musicplayer.stop();
                                          musicplayer.play(
                                              musicplayer.allFilePaths[index]);
                                              
                                      musicplayer.action=false;
                                          musicplayer.currTrackName =
                                              musicplayer.allFilePaths[index];
                                          setState(() {
                                            musicplayer.playerState =
                                                musicplayer.PlayerState.playing;
                                          });
                                        }

                                        musicplayer.currTrack = index;
                                      },
                                      child: Column(children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(top: 40.0),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: musicplayer.allMetaData[index]
                                                      [2] ==
                                                  null
                                              ? Icon(Icons.music_note,size:300.0,color: Colors.white,)
                                              : musicplayer.getImage(
                                                  musicplayer.allMetaData[index]
                                                      [2],
                                                  context),
                                        ),
                                        Container(
                                            padding: EdgeInsets.only(top: 20.0),
                                            child: Text(
                                              basename,
                                              style: TextStyle(
                                                  fontSize: 17.0,
                                                  color: Colors.black),
                                            ))
                                      ]))),
                            );
                          })),
              Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      offset: Offset(5.0, 5.0),
                      spreadRadius: 5.0,
                      blurRadius: 15.0,
                      color: Colors.orangeAccent)
                ]),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: (itemWidth / itemHeight),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 1.0, bottom: 1.0),
                      child: Material(
                        color: view == ControlState.list
                            ? Colors.limeAccent[100]
                            : Colors.white,
                        child: InkWell(
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.list,
                                  size: 50.0,
                                  color: Colors.deepOrangeAccent,
                                ),
                                Text(
                                  "List",
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.red),
                                ),
                              ],
                              mainAxisSize: MainAxisSize.min,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              view = ControlState.list;
                            });
                         
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 1.0, bottom: 1.0),
                      child: Material(
                        color: view == ControlState.cover
                            ? Colors.limeAccent[100]
                            : Colors.white,
                        child: InkWell(
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.image,
                                  size: 50.0,
                                  color: Colors.deepOrangeAccent,
                                ),
                                Text(
                                  "Cover",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                              mainAxisSize: MainAxisSize.min,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              view = ControlState.cover;
                            });
                            },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 1.0, bottom: 1.0),
                      child: Material(
                        child: InkWell(
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.play_arrow,
                                  size: 50.0,
                                  color: Colors.deepOrangeAccent,
                                ),
                                Text(
                                  "Playing",
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.red),
                                ),
                              ],
                              mainAxisSize: MainAxisSize.min,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => PlayPage(),
                            ));
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 1.0, bottom: 1.0),
                      child: Material(
                         color: musicplayer.shuffle
                            ? Colors.limeAccent[100]
                            : Colors.white,
                        child: InkWell(
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.shuffle,
                                  size: 50.0,
                                  color: Colors.deepOrangeAccent,
                                ),
                                Text(
                                  "Shuffle",
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.red),
                                ),
                              ],
                              mainAxisSize: MainAxisSize.min,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              if (musicplayer.shuffle)
                                musicplayer.shuffle = false;
                              else
                                musicplayer.shuffle = true;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class GridBlock extends StatelessWidget {
  String route;
  String blockTitle;

  GridBlock({Key key, @required this.route, @required this.blockTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
                // offset, the X,Y coordinates to offset the shadow
                offset: Offset(0.0, 0.0),
                // blurRadius, the higher the number the more smeared look
                blurRadius: 10.0,
                spreadRadius: 1.0)
          ],
        ),
        child: Material(
          child: InkWell(
            borderRadius: BorderRadius.circular(10.0),
            onTap: () {
              Navigator.of(context).pushNamed(route);
            },
            child: Container(
              child: Center(child: Text(blockTitle)),
            ),
          ),
          color: Colors.transparent,
        ),
      ),
    );
  }
}
