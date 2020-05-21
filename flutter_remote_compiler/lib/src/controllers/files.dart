import 'package:flutter_remote_compiler/flutter_remote_compiler.dart';
import 'package:flutter_remote_compiler/src/classes/project_dir.dart';
import 'package:flutter_remote_compiler/src/classes/project_file.dart';

class ProjectFilesController extends ResourceController {
  @Operation.post('id')
  Future<Response> updateFiles(
    @Bind.path('id') String id,
    @Bind.body() List<ProjectFile> inputFiles,
  ) async {
    final _project = ProjectDir.fromID(id);
    if (!_project.exists) {
      return Response.notFound();
    }
    _project.setProjectFiles(inputFiles);
    final List<Map<String, dynamic>> _messages = [];
    for (final file in inputFiles) {
      _messages.add({
        "path": file.path,
        "updated": true,
      });
    }
    return Response.ok(_messages);
  }
}
