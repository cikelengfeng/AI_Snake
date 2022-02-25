import 'package:flutter_snake/model/game_state.dart';
import 'package:flutter_snake/model/prepare_state.dart';
import 'package:xg_redux_ui/xg_redux_ui.dart';

@autoStore
class SnakeStore {
  late GameState gameState;
  late PrepareState prepareState;
}
