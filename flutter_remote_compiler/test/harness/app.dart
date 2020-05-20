import 'package:flutter_remote_compiler/flutter_remote_compiler.dart';
import 'package:aqueduct_test/aqueduct_test.dart';

export 'package:flutter_remote_compiler/flutter_remote_compiler.dart';
export 'package:aqueduct_test/aqueduct_test.dart';
export 'package:test/test.dart';
export 'package:aqueduct/aqueduct.dart';

void main() {
  final harness = Harness()..install();

  test("GET /heroes returns 200 OK", () async {
    final response = await harness.agent.get("/heroes");
    expectResponse(response, 200,
        body: everyElement({
          "id": greaterThan(0),
          "name": isString,
        }));
  });

  test("POST /heroes returns 200 OK", () async {
    await harness.agent.post("/heroes", body: {"name": "Fred"});

    final badResponse =
        await harness.agent.post("/heroes", body: {"name": "Fred"});
    expectResponse(badResponse, 409);
  });
}

class Harness extends TestHarness<FlutterRemoteCompilerChannel> {
  @override
  ManagedContext get context => channel.context;

  @override
  Future onSetUp() async {
    await resetData();
  }
}
