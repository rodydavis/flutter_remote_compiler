// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compiler.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$CompilerServiceRouter(CompilerService service) {
  final router = Router();
  router.add('GET', r'/', service.welcome);
  router.add('GET', r'/create/<name>', service.createProject);
  router.add('GET', r'/run/<id>', service.runProject);
  return router;
}
