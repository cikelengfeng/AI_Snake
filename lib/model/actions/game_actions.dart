import 'package:flutter_snake/model/game_state.dart';
import 'package:xg_redux_ui/xg_redux_ui.dart';

class Loop extends TypedAction {}

class ControlDirection extends TypedAction {
  final SnakeDirection direction;

  const ControlDirection(this.direction);
}

class InitGame extends TypedAction {}
