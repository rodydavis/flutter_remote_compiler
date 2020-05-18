import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shortid/shortid.dart';

import 'commands.dart';

part 'compiler.g.dart'; // generated with 'pub run build_runner build'

const kAppVersion = '1.0.0';

class CompilerService {
  CompilerService();
  static Map<String, String> _projects = <String, String>{};

  @Route.get('/version')
  Future<Response> welcome(Request request) async {
    final dartResult = await runCommand(
      'dart',
      ['--version'],
      verbose: true,
    );
    final flutterResult = await runCommand(
      'flutter',
      ['--version'],
      verbose: true,
    );
    final _output = <String, dynamic>{
      "version": kAppVersion,
      "dart": dartResult,
      "flutter": flutterResult,
    };
    return Response.ok(
      json.encode(_output),
      headers: {'Content-Type': 'application/json'},
    );
  }

  @Route.get('/create/<name>')
  Future<Response> createProject(Request request, String name) async {
    final id = shortid.generate();
    _projects[id] = name;
    try {
      final result = await createNewProject(id, name);
      final _output = <String, dynamic>{
        'id': id,
        'name': _projects[id],
        'output': result,
      };
      if (result != null) {
        return Response.ok(
          json.encode(_output),
          headers: {'Content-Type': 'application/json'},
        );
      }
      return Response.notFound('Error creating project for $name!');
    } catch (e) {
      final error = 'Error: $e';
      print(error);
      return Response.ok(error);
    }
  }

  Future<Response> runProject(
    Request request,
    String id, {
    bool rebuild = false,
    bool canvasKit = false,
  }) async {
    if (rebuild) {
      final result = await runProjectById(id, canvasKit);
    }
    final _handler = createStaticHandler(
      'generated',
      defaultDocument: 'index.html',
      serveFilesOutsidePath: false,
    );
    return _handler(request);
  }

  @Route.get('/compile/<id>')
  @Route.get('/build/<id>')
  Future<Response> compileProject(Request request, String id) async {
    if (_projects[id] == null) {
      return Response.notFound('Project not built for $id!');
    }
    try {
      final name = _projects[id];
      final result = await buildProjectById(id);
      final archive = await archiveDirectory(result);
      if (archive != null) {
        return Response.ok(
          archive,
          headers: {'Content-Type': 'application/zip'},
        );
      }
      return Response.notFound('Error running project for $name!');
    } catch (e) {
      final error = 'Error: $e';
      print(error);
      return Response.ok(error);
    }
  }

  // Create router using the generate function defined in 'compiler.g.dart'.
  Router get router => _$CompilerServiceRouter(this);
}
