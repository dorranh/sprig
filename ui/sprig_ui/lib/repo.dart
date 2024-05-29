import 'dart:io';
import 'dart:convert';

class SprigDetails {
  String id;
  String structure; // TODO: Make this an enum
  String format; // TODO: Make this an enum
  String? name;

  SprigDetails(
      {required this.id,
      required this.structure,
      required this.format,
      this.name});
}

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

/// Base class for Sprig baskets. A Basket is a repository containing sprigs and related methods.
abstract class Basket {
  /// List all the sprigs in the basket.
  Future<Sprigs>? list();

  /// Get the details of a specific sprig.
  Future<SprigDetails>? getDetails(Sprig sprig);
}

/// A basket hosted on the local filesystem.
class LocalBasket implements Basket {
  /// The path to the sprig binary.
  String sprigBinary;

  /// The path to the basket's directory.
  String path;

  LocalBasket({this.sprigBinary = "sprig", this.path = "."});

  @override
  Future<Sprigs>? list() {
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

  @override
  Future<SprigDetails>? getDetails(Sprig sprig) {
    var result = Process.run(sprigBinary, ["get", "--name", sprig.name!],
        runInShell: false, workingDirectory: path);

    return result.then((r) {
      if (r.exitCode != 0) {
        throw Exception(["EXPLODE. The exit code was nonzero. ${r.stderr}"]);
      }
      final output = jsonDecode(r.stdout);

      return SprigDetails(
          id: output['id'],
          structure: output['structure'],
          format: output['format'],
          name: output['name']);
    });
  }
}
