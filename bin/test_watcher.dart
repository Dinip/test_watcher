import 'package:args/args.dart';
import 'package:test_watcher/test_watcher.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption(
      'pattern',
      defaultsTo: '*_test.dart',
      help: 'The pattern of files to watch (default: *_test.dart)',
    );

  final argResults = parser.parse(args);

  if (argResults.rest.isEmpty) {
    print('Please provide a directory to watch.');
    return;
  }

  final directoryToWatch = argResults.rest[0];
  final pattern = argResults['pattern'] as String;

  final extraArgs = argResults.rest.sublist(1);

  final watcher = TestWatcher(directoryToWatch, pattern, extraArgs);
  watcher.startWatching();
}
