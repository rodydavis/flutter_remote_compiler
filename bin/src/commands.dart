import 'dart:async';
import 'dart:io';

import 'package:process_run/process_run.dart';
import 'package:shortid/shortid.dart';

void testNewProject() async {
  final id = shortid.generate();
  final name = 'example';
  String _result;
  _result = await createNewProject(id, name);
  _result = await runProjectById(id, name);
  print(_result);
}

Future<String> runProjectById(String id, String name) async {
  var webPort = int.tryParse(Platform.environment['WEB_PORT'] ?? '3000');
  String result = await runCommand(
    'flutter',
    [
      'run',
      '-d',
      'web-server',
      '--web-port',
      '$webPort',
    ],
    verbose: true,
    workingDirectory: id,
  );
  result += await runCommand(
    'flutter',
    [
      'create',
      '--project-name',
      name,
      '.',
    ],
    verbose: true,
    workingDirectory: id,
  );
  return result;
}

Future<String> createNewProject(String id, String name) async {
  final result = await runCommand(
    'flutter',
    ['create', '--project-name', name, id],
    verbose: true,
  );
  return result;
}

Future<String> runCommand(
  String exc,
  List<String> args, {
  bool verbose = false,
  String workingDirectory,
}) async {
  final result = await run(
    exc,
    args,
    verbose: true,
    workingDirectory: workingDirectory,
  );
  String _output = '';
  final stdout = result?.stdout;
  if (stdout != null && stdout.toString().isNotEmpty) {
    _output = stdout.toString();
  }
  final stderr = result?.stderr;
  if (stderr != null && stderr.toString().isNotEmpty) {
    _output = stderr.toString();
  }
  print(_output);
  return _output;
}

Stream<List<int>> streamCommand(
  String exc,
  List<String> args, {
  bool verbose = false,
  String workingDirectory,
}) async* {
  final _streamController = StreamController<List<int>>();
  await run(
    exc,
    args,
    verbose: true,
    workingDirectory: workingDirectory,
    stderr: _streamController,
    stdout: _streamController,
  );
  yield* _streamController.stream;
}
