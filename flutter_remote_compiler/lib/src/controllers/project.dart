import 'package:flutter_remote_compiler/flutter_remote_compiler.dart';
import 'package:flutter_remote_compiler/src/classes/project.dart';
import 'package:flutter_remote_compiler/src/classes/project_dir.dart';

class ProjectController extends ResourceController {
  /// Testing Purposes only
  @Operation.get()
  Future<Response> getAllProjects() async {
    final _directory = Directory('generated');
    final List<Map<String, dynamic>> _projects = [];
    final _dirs = _directory.listSync().whereType<Directory>().toList();
    for (final item in _dirs) {
      final _dir = ProjectDir(item);
      _projects.add(await _dir.toJson());
    }
    return Response.ok(_projects);
  }

  @Operation.get('id')
  Future<Response> getProjectByID(@Bind.path('id') String id) async {
    final _project = ProjectDir.fromID(id);

    if (!_project.exists) {
      return Response.notFound();
    }

    if (!(await _project.created)) {
      await _project.create('example');
    }

    return Response.ok(await _project.toJson());
  }

  @Operation.post()
  Future<Response> createProject(
      @Bind.body(ignore: ["id"]) Project inputProject) async {
    final _project = ProjectDir.generate();
    await _project.create(
      inputProject.name,
      org: inputProject.organization,
    );
    return Response.ok(await _project.toJson());
  }
}
