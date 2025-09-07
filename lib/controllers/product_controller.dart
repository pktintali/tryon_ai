import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_item.dart';

/// Global state for saved shared items (text/urls/images) with persistence.
class ProductController extends ChangeNotifier {
  static const _key = 'saved_products_v1';
  final List<ProductItem> _items = [];
  List<ProductItem> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      final list = (jsonDecode(data) as List).cast<Map<String, dynamic>>();
      _items
        ..clear()
        ..addAll(list.map(ProductItem.fromJson));
      notifyListeners();
    }
  }

  Future<void> addTextOrUrl(String textOrUrl, {String? title}) async {
    _items.insert(0, ProductItem(url: textOrUrl, title: title));
    await _persist();
  }

  Future<void> addImage(File file, {String? title}) async {
    // Save a copy in app documents directory
    final dir = await getApplicationDocumentsDirectory();
    final dest = File(
      '${dir.path}/shared_${DateTime.now().millisecondsSinceEpoch}${_ext(file.path)}',
    );
    await dest.writeAsBytes(await file.readAsBytes());
    _items.insert(0, ProductItem(imageFile: dest, title: title));
    await _persist();
  }

  Future<void> clear() async {
    _items.clear();
    await _persist();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _items.length) return;
    final item = _items.removeAt(index);
    // Best-effort delete of stored file
    try {
      final f = item.imageFile;
      if (f != null && await f.exists()) {
        await f.delete();
      }
    } catch (_) {}
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  String _ext(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '';
    return path.substring(dot);
  }
}
