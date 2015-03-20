import 'package:webrtc_utils/server.dart';

void main() {
  new SignalingServer().listen(1337);
}