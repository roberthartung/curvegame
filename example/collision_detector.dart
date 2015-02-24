import 'dart:isolate';
//import 'dart:html';

void main(args, message) {
  print('args: $args message: $message');
  var receivePort = new ReceivePort();
  if(message is SendPort) {
    message.send(receivePort.sendPort);
  }
  
  //CanvasElement canvas = new CanvasElement();
   
  receivePort.listen((data) {
    print('collision received: $data');
  });
  
  int i = 2;
  while(i < 10000000) {
    i = i*i*i*i;
  }
  
  print('done $i');
}