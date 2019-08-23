import 'package:audioplayer/audioplayer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:random_color/random_color.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

String img = "images/noimage.png";
// for playlists, play queue

int currTrack=0;
String currTrackName;

// data of all tracks on device
List allMetaData;
List allFilePaths;
// for favourites
List<String> favList = [];

// all playlist names
List<String> playlistNames;

RandomColor randomColor = RandomColor();
String appPath;
bool onPlayingPage = false;
bool darkMode=false;
bool shuffle=false;
bool action=false;

enum PlayerState { stopped, playing, paused }
AudioPlayer audioPlayer;
PlayerState playerState=PlayerState.stopped;
Duration duration;
Duration position;

void hideAppBar() {
  SystemChrome.setEnabledSystemUIOverlays([]);
}

void hideAppBarAgain() {
  SystemChrome.restoreSystemUIOverlays();
}

void setOrientation() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

Future clearPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

Future getFavTrackList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> trackList = prefs.getStringList("favTracks");
  return trackList;
}

Future getPlayListNames() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> playListNames = prefs.getStringList("playlistNames");
  return playListNames;
}

Future getPlayList(name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> playList = prefs.getStringList(name);
  return playList;
}

Future<List> loadPlaylistData() async {
  List playlistTracks = [];
  if (playlistNames != null) {
    for (String name in playlistNames) {
      // we get tracks from all playlists from shared preferences
      getPlayList(name).then((l) {
        playlistTracks.add(l);
      });
    }
  }
  return playlistTracks;
}

void savePlaylist(
    String name, List<String> CurrTrackList, List<String> trackList) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (trackList != null) {
    for (var track in trackList) {
      CurrTrackList.add(track);
    }
  }
  prefs.setStringList(name, CurrTrackList);
}

String getBaseName(int index) {
  File f = new File(allFilePaths[index]);
  String basename = p.basename(f.path);
  return basename;
}

Future play(url) async {
  await audioPlayer.play(url, isLocal: true);
}

Future pause() async {
  await audioPlayer.pause();
}

Future stop() async {
  await audioPlayer.stop();
}

Future seek(int pointer) async{
  await audioPlayer.seek(pointer.roundToDouble()/1000);
}
getImage(imageHash, context) {
  if (imageHash != null) {
    var imageData = appPath + "/" + imageHash;
    //  print(imageData);
    return Image.asset(imageData,
        width: MediaQuery.of(context).size.width / 7,
        height: MediaQuery.of(context).size.height / 2.5);
  } else {
    return Image.asset(img,
        width: MediaQuery.of(context).size.width / 7,
        height: MediaQuery.of(context).size.height / 2.5);
  }
}
/*
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          InkWell(
            child: ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
            ),
            onTap: () {
              onPlayingPage = false;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => HomePage()
              )
              );
            },
          ),
          InkWell(
            child: ListTile(
              leading: Icon(Icons.library_music),
              title: Text("Library"),
            ),
            onTap: () {
              onPlayingPage = false;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Library(
                    musicFiles: allFilePaths,
                    //metadata: allMetaData,
                  )
              )
              );
            },
          ),
          InkWell(
            child: ListTile(
              leading: Icon(Icons.favorite_border),
              title: Text("Favourites"),
            ),
            onTap: () {
              onPlayingPage = false;
            
            },
          ),
          InkWell(
            child: ListTile(
              leading: Icon(Icons.list),
              title: Text("Playlists"),
            ),
            onTap: () {
              onPlayingPage = false;
           
            },
          ),
          InkWell(
            child: ListTile(
              leading: Icon(Icons.account_circle),
              title: Text("Artists"),
            ),
            onTap: () {
              onPlayingPage = false;
            
            },
          )
        ],
      ),
    );
  }
}
*/
