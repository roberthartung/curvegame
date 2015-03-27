library curvegame;

import 'package:webrtc_utils/client.dart';
import 'package:webrtc_utils/game.dart';
import 'dart:async';
import 'dart:html';
import 'dart:convert';
import 'dart:math';

part 'game.dart';
part 'scenes.dart';
part 'player.dart';
part 'communication.dart';
part 'powerups.dart';
part 'curve.dart';
part 'room.dart';

const int DEFAULT_LINE_WIDTH = 4;
const int DEFAULT_ARC_RADIUS = 20;
// Browser should render at 60 FPS
const int TICK_DELAY = 25;
const int TICKS_PER_SECONDS = (1000.0 ~/ TICK_DELAY);
const num ROTATION_STEP = 3; // 2° per tick
const num LINE_STEP = 1; // 1px per tick
enum ArcDirection {LEFT, RIGHT}