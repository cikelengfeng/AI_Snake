import 'package:flutter_snake/model/utils/hash.dart';
import 'package:xg_redux_ui/xg_redux_ui.dart';

part 'game_state.g.dart';

class SnakeOffset {
  final int x, y;

  SnakeOffset(this.x, this.y);
  SnakeOffset.fromIndex(int index, int boardWidth)
      : x = index % boardWidth,
        y = index ~/ boardWidth;

  @override
  int get hashCode => hash2(x, y);

  @override
  bool operator ==(other) {
    if (other is! SnakeOffset) {
      return false;
    }
    return hashCode == other.hashCode;
  }

  @override
  String toString() {
    return '$runtimeType{$x, $y}';
  }

  int toIndex(int boardWidth) {
    return y * boardWidth + x;
  }

  SnakeOffset left() {
    return SnakeOffset(x - 1, y);
  }

  SnakeOffset up() {
    return SnakeOffset(x, y - 1);
  }

  SnakeOffset right() {
    return SnakeOffset(x + 1, y);
  }

  SnakeOffset down() {
    return SnakeOffset(x, y + 1);
  }
}

enum SnakeDirection { left, up, right, down }
enum OccupiedType { snake, food }
enum GamePhase { ready, playing, over, win }

@autoState
class GameState {
  late ReduxList<SnakeOffset> snake;
  SnakeOffset? food;
  late ReduxMap<SnakeOffset, OccupiedType> indices;
  SnakeDirection? direction;
  late BoardSize size;
  late int score;
  late GamePhase phase;
}

class BoardSize {
  final int width, height;

  const BoardSize(this.width, this.height);
}
