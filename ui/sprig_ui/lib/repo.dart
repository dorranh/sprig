import 'dart:io';
import 'dart:convert';
import 'package:sprig_ui/model.dart';

class Sprig {
  // The name of the sprig
  String? name;
  // FIXME: Add additional fields from sprig schema

  Sprig(this.name);
}

class Sprigs {
  List<Sprig>? sprigs;

  Sprigs(this.sprigs);
}

/// A basket hosted on the local filesystem.
class LocalBasket {
  /// The path to the basket's directory.
  String path;

  LocalBasket({this.path = "."});

  Future<Sprigs>? list(String sprigBinary) {
    var result = Process.run(sprigBinary, ["list"],
        runInShell: false, workingDirectory: path);

    return result.then((r) {
      if (r.exitCode != 0) {
        throw Exception(["EXPLODE. The exit code was nonzero., ${r.stderr}"]);
      }
      final output = jsonDecode(r.stdout);
      List<String> sprigNames = output['sprigs'].cast<String>();
      return Sprigs(sprigNames.map((name) => Sprig(name)).toList());
    });
  }

  Future<SprigDetails>? getDetails(Sprig sprig, String sprigBinary) {
    var result = Process.run(sprigBinary, ["get", "--name", sprig.name!],
        runInShell: false, workingDirectory: path);

    return result.then((r) {
      if (r.exitCode != 0) {
        throw Exception(["EXPLODE. The exit code was nonzero. ${r.stderr}"]);
      }
      return SprigDetails.fromJson(jsonDecode(r.stdout));
    });
  }
}
