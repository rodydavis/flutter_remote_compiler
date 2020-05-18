// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compiler.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$CompilerServiceRouter(CompilerService service) {
  final router = Router();
  router.add('GET', r'/version', service.welcome);
  router.add('GET', r'/create/<name>', service.createProject);
  router.add('GET', r'/compile/<id>', service.compileProject);
  router.add('GET', r'/build/<id>', service.compileProject);
  return router;
}
