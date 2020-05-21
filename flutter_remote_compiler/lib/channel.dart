import 'package:flutter_remote_compiler/src/controllers/compiler.dart';
import 'package:flutter_remote_compiler/src/controllers/files.dart';
import 'package:flutter_remote_compiler/src/controllers/project.dart';

import 'flutter_remote_compiler.dart';

class FlutterRemoteCompilerChannel extends ApplicationChannel {
  @override
  Future prepare() async {
    logger.onRecord.listen(
      (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"),
    );
  }

  @override
  Controller get entryPoint {
    final router = Router();
    router.route('/projects/[:id]').link(() => ProjectController());
    router.route('/projects/:id/build').link(() => CompilerController());
    router.route('/projects/:id/files').link(() => ProjectFilesController());
    router.route('/projects/:id/run/*').linkFunction((request) async {
      final id = request.path.variables["id"];
      return FileController("generated/$id/build/web/").handle(request);
    });
    return router;
  }
}

class HeroConfig extends Configuration {
  HeroConfig(String path) : super.fromFile(File(path));

  DatabaseConfiguration database;
}
