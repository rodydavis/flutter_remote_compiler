import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'src/commands.dart';
import 'src/compiler.dart';

Future main() async {
  testNewProject();
  var port = int.tryParse(Platform.environment['PORT'] ?? '8080');

  var service = CompilerService();

  var router = service.router;

  var server = await io.serve(
    Pipeline()
        .addMiddleware(_corsHeadersMiddleware)
        .addMiddleware(logRequests())
        .addHandler(router.handler),
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
