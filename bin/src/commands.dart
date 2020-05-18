import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:process_run/process_run.dart';
import 'package:shortid/shortid.dart';

// void testNewProject() async {
//   final id = shortid.generate();
//   final name = 'example';
//   String _result;
//   _result = await createNewProject(id, name);
//   final _archive = await buildProjectById(id);
//   // print(_archive.length);
// }

Future<Directory> buildProjectById(String id, [bool canvasKit = false]) async {
  final _path = getProjectPath(id);
  String result = await runCommand(
    'flutter',
    [
      'build',
      'web',
      '--dart-define=FLUTTER_WEB_USE_EXPERIMENTAL_CANVAS_TEXT=$canvasKit',
    ],
    verbose: true,
    workingDirectory: _path,
  );
  return Directory('$_path/build/web');
}

Future<Uint8List> archiveDirectory(Directory _dir) {
  var encoder = ZipFileEncoder();
  encoder.zipDirectory(_dir);
  return File('${_dir.path}.zip').readAsBytes();
}

Future<Directory> runProjectById(String id, bool canvasKit) async {
  final dir = await buildProjectById(id, canvasKit);
  return dir;
}

Future<String> createNewProject(String id, String name) async {
  final _path = getProjectPath(id);
  final _dir = Directory(_path)..createSync();
  final result = await runCommand(
    'flutter',
    ['create', '--project-name', name, '.'],
    verbose: true,
    workingDirectory: _dir.path,
  );
  return result;
}

// Future<Directory> compileFileDDC(String id, CompileRequest request,
//     [bool canvasKit = false]) async {
//   final _path = getProjectFile(id);
//   final _file = File(_path)..createSync();
//   String result = await runCommand(
//     'flutter',
//     [
//       'build',
//       'web',
//       '--dart-define=FLUTTER_WEB_USE_EXPERIMENTAL_CANVAS_TEXT=$canvasKit',
//     ],
//     verbose: true,
//     workingDirectory: _path,
//   );
//   return Directory('$_path/build/web');
// }

String getProjectPath(String id) => 'generated/projects/$id';
String getProjectFile(String id) => 'generated/sandbox/lib/src/$id.dart';
bool projectExists(String id) => Directory(getProjectPath(id)).existsSync();

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

class CompileRequest {
  final String source;
  final Map<String, String> packages;
  CompileRequest({
    this.source,
    this.packages,
  });

  CompileRequest copyWith({
    String source,
    Map<String, String> packages,
  }) {
    return CompileRequest(
      source: source ?? this.source,
      packages: packages ?? this.packages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'packages': packages,
    };
  }

  static CompileRequest fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return CompileRequest(
      source: map['source'],
      packages: Map<String, String>.from(map['packages']),
    );
  }

  String toJson() => json.encode(toMap());

  static CompileRequest fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() => 'CompileRequest(source: $source, packages: $packages)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return o is CompileRequest &&
        o.source == source &&
        mapEquals(o.packages, packages);
  }

  @override
  int get hashCode => source.hashCode ^ packages.hashCode;
}
