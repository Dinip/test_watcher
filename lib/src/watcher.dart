import 'dart:convert';
import 'dart:io';
import 'package:ansi_styles/ansi_styles.dart';
import 'package:watcher/watcher.dart' show ChangeType, DirectoryWatcher;

class TestWatcher {
  const TestWatcher(
    this.directoryToWatch,
    this.pattern,
    this.extraArgs,
  );

  final String directoryToWatch;
  final String pattern;
  final List<String> extraArgs;
  static final Map<String, Process> _runningProcesses = {};
  static String? _lastLine;

  void startWatching() {
    final watcher = DirectoryWatcher(directoryToWatch);

    watcher.events.listen((event) {
      if (event.type == ChangeType.MODIFY && _matchesPattern(event.path)) {
        print(AnsiStyles.cyan('Detected change in: ${event.path}'));
        _runFlutterTest(event.path);
      }
    });

    print(AnsiStyles.green('Watching for changes in $directoryToWatch with pattern $pattern...'));
  }

  bool _matchesPattern(String filePath) {
    final regexPattern = pattern.replaceAll('*', '.*');
    final regex = RegExp(regexPattern);
    return regex.hasMatch(filePath);
  }

  Future<void> _runFlutterTest(String filePath) async {
    var startTimer = DateTime.now();

    if (_runningProcesses.containsKey(filePath)) {
      print(AnsiStyles.yellow('Cancelling ongoing test for $filePath'));
      _runningProcesses[filePath]?.kill();
      await _runningProcesses[filePath]?.exitCode; // Wait for the process to fully terminate
    }

    final process = await Process.start('flutter', ['test', filePath, ...extraArgs]);
    _runningProcesses[filePath] = process;

    print(
      AnsiStyles.cyan(
        'Running flutter test on ${filePath.split('/').lastOrNull ?? filePath} with arguments: $extraArgs',
      ),
    );

    final outputBuffer = StringBuffer();

    await Future.wait([
      process.stdout.transform(utf8.decoder).listen((data) {
        final lines = data.split('\n').map((line) => line.trim());
        for (var line in lines) {
          if (line.isEmpty) continue;

          if (line.contains(RegExp(r'^\d{2}:\d{2} \+\d+:'))) {
            final content = line.replaceFirst(RegExp(r'^\d{2}:\d{2} \+\d+: '), '').trim();
            if (_lastLine != null && _lastLine == content) {
              outputBuffer.write('\r${AnsiStyles.blue(line)}');
            } else {
              outputBuffer.write('\n${AnsiStyles.green(line)}');
              _lastLine = content;
            }
          } else {
            outputBuffer.write('\n${AnsiStyles.white(line)}');
          }

          stdout.write(outputBuffer.toString());
          outputBuffer.clear();
        }
      }).asFuture(),

      process.stderr.transform(utf8.decoder).listen((data) {
        if (data.trim().isNotEmpty) {
          print(AnsiStyles.red(data.trim()));
        }
      }).asFuture(),
    ]);

    final exitCode = await process.exitCode;

    var endTimer = DateTime.now();
    var timeDifference = endTimer.difference(startTimer).inMilliseconds;

    if (exitCode == 0) {
      print(AnsiStyles.green('\nTest passed in ${timeDifference}ms'));
    } else {
      print(AnsiStyles.red('\nTest failed with exit code $exitCode in ${timeDifference}ms'));
    }

    _runningProcesses.remove(filePath);
  }
}
