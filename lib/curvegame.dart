library curvegame;

import 'package:webrtc_utils/client.dart';
import 'package:webrtc_utils/game.dart';
import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'dart:convert';

part 'game.dart';
part 'scenes.dart';
part 'player.dart';
part 'communication.dart';

const Map rtcConfiguration = const {"iceServers": const [ const {"url": "stun:stun.l.google.com:19302"}]};