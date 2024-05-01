import 'dart:async';
import 'dart:convert';
import 'dart:io';

Stream<String>? _stdin;

/// A broadcast stream of data from stdin.
///
/// As stdin can't be listened to more than once, this stream is created to allow
/// multiple listeners to listen to stdin.
Stream<String> get stdinBroadcast => _stdin ??= _createBroadcastStdin();

/// Creates a broadcast stream of data from stdin.
Stream<String> _createBroadcastStdin() {
  stdin.echoMode = false;
  stdin.lineMode = false;
  var controller = StreamController<String>.broadcast();
  stdin.transform(utf8.decoder).listen(controller.add);
  return controller.stream;
}
