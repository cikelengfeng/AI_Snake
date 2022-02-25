import 'package:flutter/widgets.dart';
import 'package:flutter_snake/model/store.redux_store.dart';
import 'package:xg_redux_ui/xg_redux_ui.dart';

mixin StoreProvider<T extends StatefulWidget> on State<T> {
  SnakeStoreGenerated get store => SnakeStoreGenerated.of(context);

  List<ListenerDisposable> disposables = [];

  @override
  void dispose() {
    disposables.forEach((element) => element.dispose());
    super.dispose();
  }
}
