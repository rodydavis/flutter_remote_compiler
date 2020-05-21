import 'package:flutter_remote_compiler/flutter_remote_compiler.dart';
import 'package:flutter_remote_compiler/src/classes/project_dir.dart';

class CompilerController extends ResourceController {
  @Operation.get('id')
  Future<Response> build(
    @Bind.path('id') String id, {
    @Bind.query('skia') bool canvasKit = false,
    @Bind.query('profile') bool profile = false,
    @Bind.query('archive') bool archive = false,
  }) async {
    final _project = ProjectDir.fromID(id);
    if (!_project.exists) {
      return Response.notFound();
    }
    await _project.build(canvasKit: canvasKit, profile: profile);
    if (archive) {
      final _archive = await _project.archive();
      return Response.ok(await _archive.readAsBytes())
        ..contentType = ContentType("application", "zip");
    }
    return Response.ok({
      "id": id,
      "build_status": 'complete',
    });
  }
}
