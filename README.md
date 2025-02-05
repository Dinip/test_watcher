# Test Watcher

Test Watcher is a Dart package that watches for changes in your Flutter test directory and runs the tests automatically.

## Features

- Watches a specified directory for changes
- Allows specifying a pattern to match files (default: \*_test.dart)
- Passes extra arguments to the `flutter test` command

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dev_dependencies:
  test_watcher:
    git:
      url: https://github.com/Dinip/test_watcher.git
      ref: main
```
Then run pub get to install the package.

## Usage
To use the Test Watcher, run the following command:
```bash
dart run test_watcher <directory_to_watch> [--pattern <file_pattern>] -- [extra_args...]
```

### Examples
```bash
dart run test_watcher test/widgets/ --pattern="*_golden_test.dart" -- --update-goldens
```
This command will watch the test/widgets/ directory for changes to files matching the pattern *_golden_test.dart and run the flutter test command with the --update-goldens argument.

```bash
dart run test_watcher test/ --pattern="*_test.dart" -- --coverage
```
This command will watch the test/ directory for changes to files matching the pattern *_test.dart and run the flutter test command with the --coverage argument.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing
Contributions are welcome! Please open an [issue](/issues) or a [pull request](/pulls) to contribute.

## Contact
For any questions or feedback, please open an issue on the GitHub repository.