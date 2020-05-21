import 'package:flutter_remote_compiler/src/controllers/project.dart';

import 'flutter_remote_compiler.dart';
import 'src/controllers/heroes.dart';

class FlutterRemoteCompilerChannel extends ApplicationChannel {
  ManagedContext context;

  @override
  Future prepare() async {
    logger.onRecord.listen(
      (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"),
    );

    final config = HeroConfig(options.configurationFilePath);
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        config.database.username,
        config.database.password,
        config.database.host,
        config.database.port,
        config.database.databaseName);

    context = ManagedContext(dataModel, persistentStore);
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router
        .route("/projects/:id/build/web/*")
        .link(() => FileController("generated/"));

    router.route('/heroes/[:id]').link(() => HeroesController(context));

    router.route('/projects/[:id]').link(() => ProjectController(context));

    router.route("/example").linkFunction((request) async {
      return Response.ok({"key": "value"});
    });

    return router;
  }
}

class HeroConfig extends Configuration {
  HeroConfig(String path) : super.fromFile(File(path));

  DatabaseConfiguration database;
}
