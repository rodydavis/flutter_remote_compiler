import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_remote_compiler/src/utils/run_command.dart';
import 'package:pubspec/pubspec.dart';
import 'package:shortid/shortid.dart';

import 'project_file.dart';

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
    String description,
    Map<String, DependencyReference> dependencies,
  }) async {
    PubSpec _current = await getPubspec();
    if (name != null) {
      _current = _current.copy(name: name);
    }
    if (description != null) {
      _current = _current.copy(description: description);
    }
    if (dependencies != null) {
      _current = _current.copy(dependencies: dependencies);
    }
    return _current.save(directory);
  }

  Future<String> getName() => getPubspec().then((value) => value.name);

  List<FileSystemEntity> getFiles() => directory.listSync(recursive: true);

  Future<void> create(String name, {String org = 'com.example'}) async {
    if (!exists) {
      await directory.create();
    }
    await runCommand(
      'flutter',
      ['config', '--enable-web', 'true'],
      verbose: true,
      workingDirectory: path,
    );
    await runCommand(
      'flutter',
      ['create', '--project-name', name, '--org', org, '.'],
      verbose: true,
      workingDirectory: path,
    );
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

  Future<void> build({
    bool canvasKit = false,
    bool profile = false,
  }) async {
    await runCommand(
      'flutter',
      [
        'build',
        'web',
        '--${profile ? 'profile' : 'release'}',
        '--dart-define=FLUTTER_WEB_USE_EXPERIMENTAL_CANVAS_TEXT=$canvasKit',
      ],
      verbose: true,
      workingDirectory: path,
    );
  }

  Future<File> updateFile(String relativePath, List<int> bytes) async {
    final _file = File('generated/$id/$relativePath');
    if (!_file.existsSync()) {
      await _file.create(recursive: true);
    }
    return _file.writeAsBytes(bytes);
  }

  Future<File> archive({bool wholeProject = false}) async {
    Directory _dir;
    if (wholeProject) {
      _dir = directory;
    } else {
      _dir = Directory('$path/build/web');
      if (!_dir.existsSync()) {
        return null;
      }
    }
    final encoder = ZipFileEncoder();
    encoder.zipDirectory(_dir);
    return File('${_dir.path}.zip');
  }

  void  setProjectFiles(List<ProjectFile> files) {
    for (final file in files) {
      final _file = File('$path/${file.path}');
      if (!_file.existsSync()) {
        _file.createSync(recursive: true);
      }
      _file.writeAsStringSync(file.source);
    }
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
