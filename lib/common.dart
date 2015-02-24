library curvegame.common;

import 'dart:math' as math;

part 'src/common/entity.dart';
part 'src/common/pathsegment.dart';
part 'src/common/game.dart';
part 'src/common/player.dart';

const int SERVER_PORT = 1337;

const Map<String, dynamic> ICONS = const {
  'bug': 0xf188,            // Makes yourself slower
  'rocket': 0xf135,           // Makes others faster
  'diamond': 0xf219,        // Gives you extra points
  /*'cubes': 0xf1b3,*/
  'cube': 0xf1b2,           // Place cube(s)
  
  'heart': 0xf004,          // Bypass one line
  /*'road': 0xf018,*/
  'random': 0xf074,         // Switch directions
  // 'bomb': 0xf1e2,        // 
  'ban': 0xf05e             // Don't draw lines 
};

enum Target {OTHERS, SELF, ALL}