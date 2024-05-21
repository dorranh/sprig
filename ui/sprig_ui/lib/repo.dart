import 'dart:io';
import 'dart:convert';

class Sprigs {
  List<String>? sprigs;

  Sprigs(this.sprigs);
}

abstract class Repo {
  Sprigs? list();
}

class ExternalRepo implements Repo {
  String path;

  ExternalRepo(this.path);

  @override
  Sprigs? list() {
    // FIXME: Implement this
    try {
      var result = Process.runSync(
        path,
        ["list"],
        runInShell: false,
      );
      if (result.exitCode != 0) {
        throw Exception(["EXPLODE. The exit code was nonzero."]);
      }
      final output = jsonDecode(result.stdout);
      List<String> sprigNames = output['sprigs'].cast<String>();
      return Sprigs(sprigNames);
    } on ProcessException catch (e) {
      print("HEY THAT DID NOT WORK");
      print(e.toString());
      return null;
    }
  }
}


//  Process.run('sprig', ["list"]).then((ProcessResult result) {
//     if (result.exitCode == 0) {
//       print('Command executed successfully');
//       print('Output: ${result.stdout}');
//     } else {
//       print('Failed to execute command');
//       print('Error: ${result.stderr}');
//     }
//   });
// ProcessException needs to be caught
