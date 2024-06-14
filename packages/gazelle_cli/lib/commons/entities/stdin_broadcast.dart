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
  /// If stdin is not available, return an empty stream.
  if (!stdin.hasTerminal) {
    stderr.writeln("Terminal is not available!");
    return Stream<String>.empty();
  }

  _setupSignalHandlers();

  stdin.echoMode = false;
  stdin.lineMode = false;

  var controller = StreamController<String>.broadcast(
    onListen: () => stdin.transform(utf8.decoder).listen(controller.add),
    onCancel: () {
      stdin.lineMode = true;
      stdin.echoMode = true;
    },
  );

  return controller.stream;
}

/// Sets up signal handlers to reset the terminal settings when the process is terminated.
void _setupSignalHandlers() {
  ProcessSignal.sigint.watch().listen(_resetTerminalSettings);
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen(_resetTerminalSettings);
  }
}

/// Resets the terminal settings.
void _resetTerminalSettings(ProcessSignal signal) {
  stdin.lineMode = true;
  stdin.echoMode = true;
  exit(0); // Exit the application after cleanup
}
