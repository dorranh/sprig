import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprig_ui/repo.dart';

part 'settings.g.dart';

@riverpod
class BasketConfig extends _$BasketConfig {
  @override
  Future<List<LocalBasket>> build() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final basketPaths = prefs.getStringList('baskets') ?? [];
    return basketPaths.map((path) => LocalBasket(path: path)).toList();
  }

  Future<void> setBaskets(List<LocalBasket> baskets) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('baskets', baskets.map((b) => b.path).toList());
    state = AsyncData(baskets);
  }
}

const defaultSprigBinary = "sprig";

@riverpod
class BackendConfig extends _$BackendConfig {
  @override
  Future<String> build() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('sprigBinary') ?? defaultSprigBinary;
  }

  Future<void> setBinaryPath(String binaryPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sprigBinary', binaryPath);
    state = AsyncData(binaryPath);
  }
}
