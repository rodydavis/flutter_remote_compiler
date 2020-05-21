import 'package:flutter_remote_compiler/flutter_remote_compiler.dart';
import 'package:pubspec/pubspec.dart';

class Project extends Serializable {
  Project({
    this.id,
    this.name,
    this.organization,
    this.description,
    this.dependencies,
  });

  String id;
  String name;
  String organization;
  String description;
  Map<String, DependencyReference> dependencies;

  @override
  Map<String, dynamic> asMap() {
    return {
      'id': id,
      'name': name,
      'organization': organization,
      'description': description,
      'dependencies': dependencies?.map((key, value) {
        final _value = value.toJson();
        return MapEntry(key, _value);
      }),
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    name = 'Example';
    organization = 'com.example';
    description = 'A new Flutter Project.';
    if (object['id'] != null) {
      id = object['id'] as String;
    }
    if (object['name'] != null) {
      name = object['name'] as String;
    }
    if (object['organization'] != null) {
      organization = object['organization'] as String;
    }
    if (object['description'] != null) {
      description = object['description'] as String;
    }
    if (object['dependencies'] != null) {
      final _json = object['dependencies'] as Map<String, dynamic>;
      dependencies = _json.map<String, DependencyReference>((key, value) {
        return MapEntry(key, DependencyReference.fromJson(value));
      });
    }
  }
}
