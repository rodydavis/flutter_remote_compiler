import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'src/compiler.dart';

Future main() async {
  // testNewProject();
  // return;
  var port = int.tryParse(Platform.environment['PORT'] ?? '8080');

  var service = CompilerService();
  var router = service.router;
  var server = await io.serve(
    Pipeline()
        .addMiddleware(_corsHeadersMiddleware)
        .addMiddleware(logRequests())
        .addHandler((Request req) {
      if (req.url.path.contains('projects')) {
        final _compiler = CompilerService();
        final id = req.url.pathSegments[1];
        final _params = req.url.queryParameters;
        bool canvasKit = false;
        bool rebuild = false;
        if (_params != null) {
          canvasKit = _params['skia'] == 'true' ? true : false;
          rebuild = _params['rebuild'] == 'false' ? false : true;
        }
        return _compiler.runProject(
          req,
          id,
          canvasKit: canvasKit,
          rebuild: rebuild,
        );
      }
      return router.handler(req);
    }),
    InternetAddress.anyIPv4,
    port,
  );

  print('Serving at http://${server.address.host}:${server.port}');
}

// By default allow access from everywhere.
const _corsHeaders = <String, String>{'Access-Control-Allow-Origin': '*'};

Handler _corsHeadersMiddleware(Handler innerHandler) {
  return (request) async {
    if (request.method == 'OPTIONS') {
      return Response.ok(null, headers: _corsHeaders);
    }

    final response = await innerHandler(request);

    return response.change(headers: _corsHeaders);
  };
}

extension ShelfUtils on Request {
  Request copyWith({
    Uri url,
    String method,
    String handlerPath,
    String protocolVersion,
    Uri requestedUri,
  }) {
    return Request(
      method ?? this.method,
      url ?? this.url,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      handlerPath: handlerPath ?? this.handlerPath,
      url: requestedUri ?? this.requestedUri,
    );
  }
}
