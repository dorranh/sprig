import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> getBaskets() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('baskets') ?? [];
}

saveBaskets(List<String> baskets) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('baskets', baskets);
}
