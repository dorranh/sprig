import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> getBaskets() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('baskets') ?? [];
}

Future<void> saveBaskets(List<String> baskets) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('baskets', baskets);
}

const defaultSprigBinary = "sprig";

Future<String> getSprigBinaryPath() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('sprigBinary') ?? defaultSprigBinary;
}

Future<void> saveSprigBinaryPath(String sprigBinary) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('sprigBinary', sprigBinary);
}
