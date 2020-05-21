import 'package:flutter_remote_compiler/flutter_remote_compiler.dart';

class ProjectFile extends Serializable {
  ProjectFile({
    this.source,
    this.path,
  });

  String source;
  String path;

  @override
  Map<String, dynamic> asMap() {
    return {
      'source': source,
      'path': path,
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    if (object['source'] != null) {
      source = object['source'] as String;
    }
    if (object['path'] != null) {
      path = object['path'] as String;
    }
  }
}
