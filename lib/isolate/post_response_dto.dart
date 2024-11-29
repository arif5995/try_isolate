import 'dart:async';
import 'dart:isolate';
import 'package:try_isolate/entities/post.dart';


class PostResponseDTO{
  final ReceivePort _receivePort;
  final SendPort _sendPort;
  late Completer<Object?> _completer;
  bool _closed = false;

  PostResponseDTO._(this._receivePort, this._sendPort) {
    _receivePort.listen(_handleResponsesFromIsolate);
  }

  static Future<PostResponseDTO> spawn() async {
    // Create a receive port and add its initial message handler
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
      ReceivePort.fromRawReceivePort(initPort),
      commandPort,
      ));
    };
    // Spawn the isolate.
    try {
      await Isolate.spawn(_postToDTO, (initPort.sendPort));
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
    await connection.future;

    return PostResponseDTO._(receivePort, sendPort);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    final Object? response = message as Object?;
    final completer = _completer;

    if (response is RemoteError) {
      completer.completeError(response);
    } else {
      completer.complete(response);
    }

    if (_closed) _receivePort.close();
  }



  Future<List<Post>> toListPost(List<dynamic> datas)async{
    if (_closed) throw StateError('Closed');
    final completer = Completer<Object?>.sync();
    _completer = completer;
    _sendPort.send(datas);
    return await completer.future as List<Post>;
  }


  static void _postToDTO(SendPort sendPort){
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    _handleCommandsToIsolate(receivePort, sendPort);
  }

  static void _handleCommandsToIsolate(
      ReceivePort receivePort,
      SendPort sendPort,
      ) {
    receivePort.listen((message) {
      if (message == 'shutdown') {
        receivePort.close();
        return;
      }

      final completer = Completer<Object?>.sync();
      final List<dynamic> dataRes = message as List<dynamic>;
      List<Post> datas = [];

      try {
        for (var data in dataRes){
            datas.add(Post(id: data["id"], title: data["title"], body: data["body"]));
        }
        sendPort.send(datas);
      } catch (e) {
        sendPort.send(RemoteError(e.toString(), ''));
      }
    });
  }

  void close() {
    if (!_closed) {
      _closed = true;
      _sendPort.send('shutdown');
      print('--- port closed --- ');
    }
  }
}
