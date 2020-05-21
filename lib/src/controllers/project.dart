import 'package:flutter_remote_compiler/flutter_remote_compiler.dart';
import 'package:flutter_remote_compiler/src/classes/project.dart';
import 'package:flutter_remote_compiler/src/classes/project_dir.dart';

class ProjectController extends ResourceController {
  @Operation.get('id')
  Future<Response> getProjectByID(@Bind.path('id') String id) async {
    final _project = ProjectDir.fromID(id);

    if (!_project.exists) {
      return Response.notFound();
    }

    if (!(await _project.created)) {
      await _project.create(Project()..name = 'Example');
    }

    return Response.ok(await _project.toJson());
  }

  @Operation.delete('id')
  Future<Response> deleteProjectByID(@Bind.path('id') String id) async {
    final _project = ProjectDir.fromID(id);

    if (!_project.exists) {
      return Response.notFound();
    }

    await _project.directory.delete(recursive: true);

    return Response.ok({
      "id": id,
      "status": 'deleted',
    });
  }

  @Operation.put('id')
  Future<Response> updateProject(
      @Bind.path('id') String id, @Bind.body() Project inputProject) async {
    final _project = ProjectDir.fromID(id);
    await _project.updatePubspec(
      dependencies: inputProject?.dependencies,
      description: inputProject?.description,
    );
    if (inputProject?.files != null) {
      _project.setProjectFiles(inputProject.files);
    }
    return Response.ok(await _project.toJson());
  }

  @Operation.post()
  Future<Response> createProject(
      @Bind.body(ignore: ["id"]) Project inputProject) async {
    final _project = ProjectDir.generate();
    await _project.create(inputProject);
    await _project.updatePubspec(
      dependencies: inputProject?.dependencies,
      description: inputProject?.description,
    );
    if (inputProject?.files != null) {
      _project.setProjectFiles(inputProject.files);
    }
    return Response.ok(await _project.toJson());
  }
}
