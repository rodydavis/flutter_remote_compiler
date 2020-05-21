import 'package:process_run/process_run.dart';

Future<String> runCommand(
  String exc,
  List<String> args, {
  bool verbose = false,
  String workingDirectory,
}) async {
  final result = await run(
    exc,
    args,
    verbose: true,
    workingDirectory: workingDirectory,
  );
  String _output = '';
  final stdout = result?.stdout;
  if (stdout != null && stdout.toString().isNotEmpty) {
    _output = stdout.toString();
  }
  final stderr = result?.stderr;
  if (stderr != null && stderr.toString().isNotEmpty) {
    _output = stderr.toString();
  }
  print(_output);
  return _output;
}
