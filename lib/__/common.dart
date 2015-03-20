library curvegame.common;

import 'dart:math' as math;

part '../src/common/powerup.dart';
part '../src/common/pathsegment.dart';
part '../src/common/linesegment.dart';
part '../src/common/arcsegment.dart';
part '../src/common/game.dart';
part '../src/common/player.dart';
part '../src/common/vector.dart';

const int SERVER_PORT = 1337;
const int DEFAULT_LINE_WIDTH = 4;
const int DEFAULT_ARC_RADIUS = 20;

const int TICK_DELAY = 25;
const int TICKS_PER_SECONDS = (1000.0 ~/ TICK_DELAY);

const num ROTATION_STEP = 3; // 2° per tick
const num LINE_STEP = 1; // 1px per tick

enum ArcDirection {LEFT, RIGHT}