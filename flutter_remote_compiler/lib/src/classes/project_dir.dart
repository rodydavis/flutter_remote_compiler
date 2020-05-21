import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter_remote_compiler/src/utils/run_command.dart';
import 'package:pubspec/pubspec.dart';
import 'package:shortid/shortid.dart';

class ProjectDir {
  ProjectDir(this.directory);
  ProjectDir.fromID(String id) : directory = Directory('generated/$id');
  ProjectDir.fromPath(String path) : directory = Directory(path);

  /// Root Directory of Project
  final Directory directory;

  static ProjectDir generate() => ProjectDir.fromID(shortid.generate());

  bool get exists => directory.existsSync();
  String get id => path.split('/').last;
  String get path => directory.path;
  Future<bool> get created async {
    if (directory.existsSync()) {
      final _file = File('$path/pubspec.yaml');
      return _file.existsSync();
    }
    return false;
  }

  Future<PubSpec> getPubspec() async {
    if (await created) {
      return PubSpec.load(directory);
    }
    return null;
  }

  Future<void> setPubspec(PubSpec val) => val.save(directory);
  Future<void> updatePubspec({
    String name,
    Map<String, DependencyReference> dependencies,
  }) async {
    PubSpec _current = await getPubspec();
    if (name != null) {
      _current = _current.copy(name: name);
    }
    if (dependencies != null) {
      _current = _current.copy(dependencies: dependencies);
    }
    return _current.save(directory);
  }

  Future<String> getName() => getPubspec().then((value) => value.name);

  List<FileSystemEntity> getFiles() => directory.listSync(recursive: true);

  Future<void> create(String name) async {
    if (!exists) {
      await directory.create();
    }
    final config = await runCommand(
      'flutter',
      ['config', '--enable-web', 'true'],
      verbose: true,
      workingDirectory: path,
    );
    print(config);
    final result = await runCommand(
      'flutter',
      ['create', '--project-name', name, '.'],
      verbose: true,
      workingDirectory: path,
    );
    print(result);
    final List<Directory> _toRemove = [];
    _toRemove.add(Directory('$path/ios'));
    _toRemove.add(Directory('$path/android'));
    _toRemove.add(Directory('$path/windows'));
    _toRemove.add(Directory('$path/linux'));
    _toRemove.add(Directory('$path/macos'));
    _toRemove.add(Directory('$path/test'));
    for (final dir in _toRemove) {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
        print('Deleted: ${dir.path}');
      }
    }
  }

  Future<void> build({bool canvasKit = false}) async {
    final result = await runCommand(
      'flutter',
      [
        'build',
        'web',
        '--dart-define=FLUTTER_WEB_USE_EXPERIMENTAL_CANVAS_TEXT=$canvasKit',
      ],
      verbose: true,
      workingDirectory: path,
    );
    print(result);
  }

  Future<Uint8List> archive({
    bool canvasKit = false,
    bool wholeProject = false,
  }) async {
    Directory _dir;
    if (wholeProject) {
      _dir = directory;
    } else {
      _dir = Directory('$path/build/web');
      if (!_dir.existsSync()) {
        await build(canvasKit: canvasKit);
      }
    }
    final encoder = ZipFileEncoder();
    encoder.zipDirectory(_dir);
    return File('${_dir.path}.zip').readAsBytes();
  }

  Future<Map<String, dynamic>> toJson() async {
    final _pubspec = await getPubspec();
    final _files = directory.listSync(recursive: true).map((e) {
      return e.path.replaceAll('generated/', '');
    }).toList();
    return {
      "id": id,
      "created": await created,
      "pubspec": _pubspec?.toJson(),
      "files": _files,
    };
  }
}
