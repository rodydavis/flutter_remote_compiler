import 'dart:convert';

import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'default.dart';

const kBaseUrl = 'http://localhost:8888';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CodeEditor(),
    );
  }
}

class CodeEditor extends StatefulWidget {
  const CodeEditor({Key key}) : super(key: key);

  @override
  _CodeEditorState createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  final _controller = TextEditingController();
  final _packageController = TextEditingController();
  final _versionController = TextEditingController();
  String _url;
  String id;
  final List<Package> _packages = <Package>[];

  @override
  void initState() {
    _controller.text = kDefaultCode;
    _loading = false;
    _create();
    super.initState();
  }

  void _create() async {
    final _body = json.encode({
      "name": "example",
      "organization": "com.example",
      "description": "A Awesome Flutter Project",
      "files": [
        {
          "path": "lib/main.dart",
          "source": _controller.text,
        }
      ]
    });
    print(_body);
    final _response = await http.post(
      '$kBaseUrl/projects',
      body: _body,
      headers: {
        "Content-Type": 'application/json; charset=utf-8',
      },
    );
    final _json = json.decode(_response.body);
    if (mounted)
      setState(() {
        id = _json['id'].toString();
      });
    await _compile();
  }

  bool _loading = false;
  Future _compile() async {
    if (mounted)
      setState(() {
        _loading = true;
      });
    final _depMap = <String, dynamic>{};
    for (final p in _packages) {
      _depMap[p.name] = p?.version;
    }
    final _body = json.encode({
      "files": [
        {
          "path": "lib/main.dart",
          "source": _controller.text,
        }
      ],
      'dependencies': _depMap,
    });
    final _files = await http.put(
      '$kBaseUrl/projects/$id',
      body: _body,
      headers: {
        "Content-Type": 'application/json; charset=utf-8',
      },
    );
    print('Files Response: ${_files.body}');
    final _build = await http.get(
      '$kBaseUrl/projects/$id/build',
    );
    print('Build Response: ${_build.body}');
    if (mounted)
      setState(() {
        _loading = false;
      });
    _run();
  }

  void _run() {
    if (mounted)
      setState(() {
        _url = '$kBaseUrl/projects/$id/run/';
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Code Editor ${id ?? ''}'.trim()),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: id == null || _loading
                ? null
                : () => _compile().timeout(const Duration(seconds: 30),
                        onTimeout: () {
                      if (mounted)
                        setState(() {
                          _url = null;
                          _loading = false;
                        });
                    }),
          ),
        ],
      ),
      body: Column(
        children: [
          if (id == null || _loading) const LinearProgressIndicator(),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: _controller,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ),
                const VerticalDivider(width: 0),
                Flexible(
                  flex: 3,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: TextField(
                                      controller: _packageController,
                                      decoration: const InputDecoration(
                                        labelText: 'Package',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: TextField(
                                      controller: _versionController,
                                      decoration: const InputDecoration(
                                        labelText: 'Version',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    if (mounted)
                                      setState(() {
                                        String _name = _packageController.text;
                                        String _version =
                                            _versionController.text;
                                        if (_name != null && _name.isNotEmpty) {
                                          _packages.add(Package(
                                            name: _name,
                                            version: _version.isEmpty
                                                ? 'any'
                                                : _version,
                                          ));
                                        }
                                        _packageController.clear();
                                        _versionController.clear();
                                      });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: ListView.builder(
                        itemCount: _packages.length,
                        itemBuilder: (context, index) {
                          final item = _packages[index];
                          return ListTile(
                            title: Text(item.name),
                            subtitle: item.version == null
                                ? null
                                : Text(item.version),
                            trailing: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                if (mounted)
                                  setState(() {
                                    _packages.removeAt(index);
                                  });
                              },
                            ),
                          );
                        },
                      )),
                      const Divider(),
                      if (_url != null)
                        Container(
                          height: 150,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _url,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                RaisedButton(
                                  child: const Text('Open URL'),
                                  onPressed: () => launch(_url),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Package {
  Package({
    this.name,
    this.version,
  });

  String name;
  String version;

  Package copyWith({
    String name,
    String version,
  }) {
    return Package(
      name: name ?? this.name,
      version: version ?? this.version,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'version': version,
    };
  }
}
