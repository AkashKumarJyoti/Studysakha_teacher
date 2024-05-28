import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:studysakha_teacher/calling/services.dart';

class CallStart extends StatefulWidget {
  String docId;
  String roomUrl;
  String roomId;
  CallStart({Key? key, required this.docId, required this.roomUrl, required this.roomId}) : super(key: key);

  @override
  State<CallStart> createState() => _CallStartState();
}

class _CallStartState extends State<CallStart> implements HMSUpdateListener, HMSActionResultListener {

  late HMSSDK hmsSDK;
  final List<PeerTrackNode> _listeners = [];
  final List<PeerTrackNode> _speakers = [];
  HMSPeer? _localPeer;
  bool _isMicrophoneMuted = false;
  bool speaker = false;
  bool isScreenShareOn = false;
  HMSPeer? localPeer, remotePeer;
  HMSVideoTrack? localPeerVideoTrack, remotePeerVideoTrack;
  late Stream<QuerySnapshot> quizStream;
  int currentIndex = 0;
  bool showQuiz = false;
  late List<DocumentSnapshot> quizzes;
  var docId = FirebaseAuth.instance.currentUser?.uid;

  void getPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
  }

  Future<void> joinRoom() async {
    String? name = FirebaseAuth.instance.currentUser?.displayName;
    HMSConfig config = HMSConfig(authToken: widget.roomUrl, userName: name!);
    await hmsSDK.join(config: config);
    hmsSDK.addUpdateListener(listener: this);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermissions();
    initHMSSDK();

    quizStream = FirebaseFirestore.instance
        .collection('teachers')
        .doc(docId)
        .collection('quiz')
        .snapshots();
    quizzes = [];
  }

  void initHMSSDK() async {
    hmsSDK = HMSSDK();
    await hmsSDK.build();
    joinRoom();
  }

  @override
  void dispose() {
    _speakers.clear();
    _listeners.clear();
    remotePeerVideoTrack = null;
    localPeerVideoTrack = null;
    super.dispose();
  }

  @override
  void onAudioDeviceChanged({HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice}) {
    hmsSDK.switchAudioOutput(
        audioDevice: speaker ? HMSAudioDevice.SPEAKER_PHONE : HMSAudioDevice
            .EARPIECE);
    // currentAudioDevice : audio device to which audio is curently being routed to
    // availableAudioDevice : all other available audio devices
  }

  @override
  void onChangeTrackStateRequest({required HMSTrackChangeRequest hmsTrackChangeRequest}) {
    // TODO: implement onChangeTrackStateRequest
  }

  @override
  void onException({required HMSActionResultListenerMethod methodType,
    Map<String, dynamic>? arguments,
    required HMSException hmsException}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.leave:
        log("Not able to leave error occured");
        break;
      default:
        break;
    }
  }

  @override
  void onHMSError({required HMSException error}) {
    // TODO: implement onHMSError
  }

  @override
  void onJoin({required HMSRoom room}) {
    //Checkout the docs about handling onJoin here: https://www.100ms.live/docs/flutter/v2/how--to-guides/set-up-video-conferencing/join#join-a-room
    room.peers?.forEach((peer) {
      if (peer.isLocal) {
        localPeer = peer;
        if (peer.videoTrack != null) {
          localPeerVideoTrack = peer.videoTrack;
        }
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers[index].peer = peer;
            } else {
              _speakers.add(PeerTrackNode(
                uid: "${peer.peerId}speaker",
                peer: peer,
              ));
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners[index].peer = peer;
            } else {
              _listeners.add(
                  PeerTrackNode(uid: "${peer.peerId}listener", peer: peer));
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
      }
    });
  }

  @override
  void onMessage({required HMSMessage message}) {
    // TODO: implement onMessage
  }

  @override
  void onPeerListUpdate({required List<HMSPeer> addedPeers, required List<HMSPeer> removedPeers}) {
    // TODO: implement onPeerListUpdate
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (peer.isLocal) {
      _localPeer = peer;
    }
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        if(!peer.isLocal) {
          if(mounted) {
            setState(() {
              remotePeer = peer;
            });
          }
        }
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers[index].peer = peer;
            } else {
              _speakers.add(PeerTrackNode(
                uid: "${peer.peerId}speaker",
                peer: peer,
              ));
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners[index].peer = peer;
            } else {
              _listeners.add(
                  PeerTrackNode(uid: "${peer.peerId}listener", peer: peer));
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
        break;
      case HMSPeerUpdate.peerLeft:
        if (!peer.isLocal) {
          if (mounted) {
            setState(() {
              remotePeer = null;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              localPeer = null;
            });
          }
        }
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers.removeAt(index);
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners.removeAt(index);
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
        break;
      case HMSPeerUpdate.roleUpdated:
        if (peer.role.name == "speaker") {
          //This means previously the user must be a listener earlier in our case
          //So we remove the peer from listener and add it to speaker list
          int index = _listeners
              .indexWhere((node) => node.uid == "${peer.peerId}listener");
          if (index != -1) {
            _listeners.removeAt(index);
          }
          _speakers.add(PeerTrackNode(
            uid: "${peer.peerId}speaker",
            peer: peer,
          ));
          if (peer.isLocal) {
            _isMicrophoneMuted = peer.audioTrack?.isMute ?? true;
          }
          setState(() {});
        } else if (peer.role.name == "listener") {
          //This means previously the user must be a speaker earlier in our case
          //So we remove the peer from speaker and add it to listener list
          int index = _speakers
              .indexWhere((node) => node.uid == "${peer.peerId}speaker");
          if (index != -1) {
            _speakers.removeAt(index);
          }
          _listeners.add(PeerTrackNode(
            uid: "${peer.peerId}listener",
            peer: peer,
          ));
          setState(() {});
        }
        break;
      case HMSPeerUpdate.metadataChanged:
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers[index].peer = peer;
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners[index].peer = peer;
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
        break;
      case HMSPeerUpdate.nameChanged:
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers[index].peer = peer;
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners[index].peer = peer;
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
        break;
      case HMSPeerUpdate.defaultUpdate:
      // TODO: Handle this case.
        break;
      case HMSPeerUpdate.networkQualityUpdated:
      // TODO: Handle this case.
        break;
      default:
        break;
    }
  }

  @override
  void onReconnected() {
    // TODO: implement onReconnected
  }

  @override
  void onReconnecting() {
    // TODO: implement onReconnecting
  }

  @override
  void onRemovedFromRoom({required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    // TODO: implement onRemovedFromRoom
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {
    // TODO: implement onRoleChangeRequest
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    // TODO: implement onRoomUpdate
  }

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {
    // TODO: implement onSessionStoreAvailable
  }

  @override
  void onSuccess({required HMSActionResultListenerMethod methodType,
    Map<String, dynamic>? arguments}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.leave:
        hmsSDK.removeUpdateListener(listener: this);
        hmsSDK.destroy();
        break;
      default:
        break;
    }
  }

  @override
  void onTrackUpdate(
      {required HMSTrack track,
        required HMSTrackUpdate trackUpdate,
        required HMSPeer peer}) {
    if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      if (trackUpdate == HMSTrackUpdate.trackRemoved) {
        if (peer.isLocal) {
          if (mounted) {
            setState(() {
              localPeerVideoTrack = null;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              remotePeerVideoTrack = null;
            });
          }
        }
        return;
      }
      if (peer.isLocal) {
        if (mounted) {
          setState(() {
            localPeerVideoTrack = track as HMSVideoTrack;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            remotePeerVideoTrack = track as HMSVideoTrack;
          });
        }
      }
    }
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
    // TODO: implement onUpdateSpeakers
  }

  void startScreenShare({HMSActionResultListener? hmsActionResultListener}) {
    hmsSDK.startScreenShare(hmsActionResultListener: hmsActionResultListener);
  }

  void stopScreenShare({HMSActionResultListener? hmsActionResultListener}) {
    hmsSDK.stopScreenShare(hmsActionResultListener: hmsActionResultListener);
  }

  void toggleScreenShare() {
    if (!isScreenShareOn) {
      setState(() {
        isScreenShareOn = true;
      });
      CallService.screenShareVar(widget.docId, isScreenShareOn);
      startScreenShare();
    } else {
      setState(() {
        isScreenShareOn = false;
      });
      CallService.screenShareVar(widget.docId, isScreenShareOn);
      stopScreenShare();
    }
  }

  void endRoom(
      {required bool lock,
        required String reason,
        HMSActionResultListener? hmsActionResultListener}) async {
    //this is the instance of class which implements HMSActionResultListener
    hmsSDK.endRoom(
        lock: lock,
        reason:  "Class end",
        hmsActionResultListener: this);
  }
  bool toggle = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            isScreenShareOn == true ?
            Column(
              children: [
                const SizedBox(height: 300),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: ()
                      {
                        toggleScreenShare();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                          Text("Stop Screenshare", style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18
                          ),)
                        ],
                      )),
                ),
              ],
            ) : showQuiz == false ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 250),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: ()
                      {
                        toggleScreenShare();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.screen_share, color: Colors.white),
                          ),
                          Text("Start Screenshare", style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18
                          ),)
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: ()
                      {
                        setState(() {
                          showQuiz = true;
                        });
                        FirebaseFirestore.instance.collection('live_room').doc(widget.docId).update({
                          'quizTime': true
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.share, color: Colors.white),
                          ),
                          Text("Share quiz", style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18
                          ),)
                        ],
                      )),
                )
              ],
            ) : Container(
              child: Column(
                children: [
                  const SizedBox(height: 250),
                  StreamBuilder<QuerySnapshot>(
                    stream: quizStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No quizzes available.'));
                      } else {
                        quizzes = snapshot.data!.docs;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Q. ${quizzes[currentIndex]['question']}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  Text("A. ${quizzes[currentIndex]['option1']}", style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14
                                  )),
                                  Text("B. ${quizzes[currentIndex]['option2']}", style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14
                                  )),
                                  Text("C. ${quizzes[currentIndex]['option3']}", style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14
                                  )),
                                  Text("D. ${quizzes[currentIndex]['option4']}", style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14
                                  ))
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 7),
                  if(toggle)
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      currentIndex != 0 ? ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentIndex =
                                (currentIndex - 1).clamp(0, quizzes.length - 1);
                          });
                        },
                        child: const Text('Previous'),
                      ) : Container(),
                      ElevatedButton(
                          onPressed: ()
                          {
                            addQuizToLiveClass(quizzes[currentIndex]);
                            setState(() {
                              toggle = false;
                            });
                            delayedFunction(10).then((result) {
                              setState(() {
                                toggle = true;
                              });
                            });

                          },
                          child: const Text("Send")),
                      currentIndex != quizzes.length - 1 ? ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentIndex =
                                (currentIndex + 1).clamp(0, quizzes.length - 1);
                          });
                        },
                        child: const Text('Next'),
                      ) : Container(),
                    ],
                  ),
                  if(!toggle)
                    animatedLinearProgressIndicator(),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    onTap: ()
                    {
                      setState(() {
                        speaker = !speaker;
                      });
                      onAudioDeviceChanged();
                    },
                    child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(speaker ? Icons.volume_up : Icons.volume_down, color: Colors.white, size: 45)
                    )
                ),
                InkWell(
                  onTap: () {
                    toggleScreenShare();
                  },
                  child: const Icon(Icons.screen_share, color: Colors.white,)
                ),
                InkWell(
                  onTap: ()
                  {
                    if(isScreenShareOn)
                    {
                      stopScreenShare();
                    }
                    endRoom(lock: true, reason: "Class Finish");
                    hmsSDK.leave(hmsActionResultListener: this);
                    CallService.leaveRoom(widget.roomId);
                    FirebaseFirestore.instance.collection('teachers').doc(docId).collection('upcoming_classes').doc(widget.docId).delete();
                    FirebaseFirestore.instance.collection('live_room').doc(widget.docId).delete();
                    Navigator.pop(context);
                  },
                  child: const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFE91D42),
                    child: Icon(Icons.call_end, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }

  Future<void> delayedFunction(int seconds) async {
    print('Function execution started');

    // Use Future.delayed to introduce a delay
    await Future.delayed(Duration(seconds: seconds));

    // Your actual function logic goes here
    print('Function executed after $seconds seconds');
  }

  void addQuizToLiveClass(DocumentSnapshot quiz)
  {
    DocumentReference documentReference = FirebaseFirestore.instance.collection('live_room').doc(widget.docId).collection('quiz').doc(widget.docId);
    documentReference.set({
      'question': quiz['question'],
      'A': quiz['option1'],
      'B': quiz['option2'],
      'C': quiz['option3'],
      'D': quiz['option4'],
      'correctOption': quiz['correctOption'],
      'countA': 0,
      'countB': 0,
      'countC': 0,
      'countD': 0,
    });
  }

  Widget animatedLinearProgressIndicator()
  {
    return AnimatedContainer(
        duration: Duration(seconds: 10),
      width: MediaQuery.of(context).size.width - 50,
      height: 10,
      child: const LinearProgressIndicator(
        backgroundColor: Colors.grey,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),

      )
    );
  }

  Widget peerTile(
      Key key, HMSVideoTrack? videoTrack, HMSPeer? peer, BuildContext context) {
    return Container(
      key: key,
      color: Colors.black,
      child: (videoTrack != null && !(videoTrack.isMute))
          ? HMSVideoView(
        track: videoTrack,
      )
          : Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(4),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.blue,
                blurRadius: 20.0,
                spreadRadius: 5.0,
              ),
            ],
          ),
          child: Text(
            peer?.name.substring(0, 1) ?? "D",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

}

class PeerTrackNode {
  String uid;
  HMSPeer peer;
  bool isRaiseHand;
  HMSTrack? audioTrack;

  PeerTrackNode(
      {required this.uid,
        required this.peer,
        this.audioTrack,
        this.isRaiseHand = false});

  @override
  String toString() {
    return 'PeerTrackNode{uid: $uid, peerId: ${peer.peerId},track: $audioTrack}';
  }

}