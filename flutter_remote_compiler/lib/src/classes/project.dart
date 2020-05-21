import 'package:flutter_remote_compiler/flutter_remote_compiler.dart';

class Project extends ManagedObject<_Project> implements _Project {}

class _Project {
  @primaryKey
  int id;

  @Column(indexed: true)
  String name;

  @Column(nullable: true)
  String organization;

  @Column(nullable: true)
  String description;
}
