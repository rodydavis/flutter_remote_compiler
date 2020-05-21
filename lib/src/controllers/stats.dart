import 'package:flutter_remote_compiler/flutter_remote_compiler.dart';
import 'package:flutter_remote_compiler/src/classes/project_dir.dart';

class ProjectStatsController extends ResourceController {
  @Operation.get('id')
  Future<Response> getInfo(@Bind.path('id') String id) async {
    final _project = ProjectDir.fromID(id);
    if (!_project.exists) {
      return Response.notFound();
    }
    return Response.ok(await _project.toJson());
  }
}
