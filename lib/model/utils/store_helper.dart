import 'package:flutter_snake/model/game_state.dart';
import 'package:flutter_snake/model/reducers/snake_control.dart';
import 'package:flutter_snake/model/store.redux_store.dart';
import 'package:flutter_snake/model/prepare_state.dart';
import 'package:xg_redux_ui/xg_redux_ui.dart';

class StoreHelper {
  final SnakeStoreGenerated store;

  StoreHelper(this.store);

  int headToFoodX() {
    var head = store.gameState.snake.first;
    var food = store.gameState.food!;
    return head.x - food.x;
  }

  int headToFoodY() {
    var head = store.gameState.snake.first;
    var food = store.gameState.food!;
    return head.y - food.y;
  }

  int headToTailX() {
    var head = store.gameState.snake.first;
    var tail = store.gameState.snake.last;
    return head.x - tail.x;
  }

  int headToTailY() {
    var head = store.gameState.snake.first;
    var tail = store.gameState.snake.last;
    return head.y - tail.y;
  }

  int headToBody(SnakeDirection direction) {
    var head = store.gameState.snake.first;
    var size = store.gameState.size;

    switch (direction) {
      case SnakeDirection.left:
        for (int i = head.x - 1; i >= 0; i--) {
          var offset = SnakeOffset(i, head.y);
          if (store.gameState.indices[offset] == OccupiedType.snake) {
            return head.x - i;
          }
        }
        break;
      case SnakeDirection.up:
        for (int i = head.y - 1; i >= 0; i--) {
          var offset = SnakeOffset(head.x, i);
          if (store.gameState.indices[offset] == OccupiedType.snake) {
            return head.y - i;
          }
        }
        break;
      case SnakeDirection.right:
        for (int i = head.x + 1; i < size.width; i++) {
          var offset = SnakeOffset(i, head.y);
          if (store.gameState.indices[offset] == OccupiedType.snake) {
            return i - head.x;
          }
        }
        break;
      case SnakeDirection.down:
        for (int i = head.y + 1; i < size.height; i++) {
          var offset = SnakeOffset(head.x, i);
          if (store.gameState.indices[offset] == OccupiedType.snake) {
            return i - head.y;
          }
        }
        break;
    }
    return -1;
  }

  int headToEdge(SnakeDirection direction) {
    var head = store.gameState.snake.first;
    switch (direction) {
      case SnakeDirection.left:
        return head.x + 1;
      case SnakeDirection.up:
        return head.y + 1;
      case SnakeDirection.right:
        return store.gameState.size.width - head.x;
      case SnakeDirection.down:
        return store.gameState.size.height - head.y;
    }
    return -1;
  }

  SnakeDirection? invalidDirection() {
    List<SnakeOffset> snake = store.gameState.snake;
    if (snake.length <= 1) {
      return null;
    }
    var second = snake[1];
    var first = snake.first;
    if (first.x > second.x) {
      return SnakeDirection.left;
    } else if (first.x < second.x) {
      return SnakeDirection.right;
    } else if (first.y > second.y) {
      return SnakeDirection.up;
    } else {
      return SnakeDirection.down;
    }
  }

  bool isOutOfBounds(SnakeOffset offset) {
    var size = store.gameState.size;
    return offset.x < 0 ||
        offset.x >= size.width ||
        offset.y < 0 ||
        offset.y >= size.height;
  }

  // 返回长度大于等于 baseline 的路径
  List<SnakeOffset> shortestPath(SnakeOffset from, SnakeOffset to,
      {List<SnakeOffset>? customSnake, bool verbose = false}) {
    Map<SnakeOffset, OccupiedType> indices = customSnake == null
        ? store.gameState.indices
        : indicesFromSnake(customSnake);
    Map<SnakeOffset, _PathNode> open = {from: _PathNode(from, null, 0)};
    Map<SnakeOffset, _PathNode> close = {};
    Set<SnakeOffset> untouchable = Set();
    indices.forEach((key, value) {
      //目的地不要算在不可达集合里，否则就直接跳过了
      if (value == OccupiedType.snake && key != to) {
        untouchable.add(key);
      }
    });
    while (open.isNotEmpty) {
      bool findTarget = false;
      var key = open.keys.first;
      var value = open[key]!;

      List<SnakeOffset> candidate = [
        key.left(),
        key.up(),
        key.right(),
        key.down()
      ];
      for (var value1 in candidate) {
        if (untouchable.contains(value1)) {
          continue;
        }
        if (close.containsKey(value1)) {
          continue;
        }
        if (isOutOfBounds(value1)) {
          continue;
        }
        var newNode = open[value1];
        int newCost = value.cost + value.costTo(value1);
        if (newNode == null) {
          if (key == from) {
            newNode = _PathNode(value1, null, newCost);
          } else {
            newNode = _PathNode(value1, value, newCost);
          }
          open[value1] = newNode;
          if (value1 == to) {
            findTarget = true;
            break;
          }
        } else {
          if (newNode.cost > newCost) {
            newNode.parent = value;
            newNode.cost = newCost;
          }
        }
      }
      close[key] = value;
      open.remove(key);
      if (findTarget) {
        break;
      }
    }
    if (verbose) {
      printPathFindingBoard(
          open, close, customSnake ?? store.gameState.snake, indices);
    }
    var targetNode = open[to];
    if (targetNode == null) {
      return [];
    }
    var it = targetNode;
    return it.path();
  }

  // (from.x - to.x).abs() + (from.y - to.y).abs()
  int distance(SnakeOffset from, SnakeOffset to) {
    return (from.x - to.x).abs() + (from.y - to.y).abs();
  }

  SnakeDirection? direction(SnakeOffset from, SnakeOffset to) {
    if (from.x > to.x) {
      return SnakeDirection.left;
    } else if (from.x < to.x) {
      return SnakeDirection.right;
    } else if (from.y > to.y) {
      return SnakeDirection.up;
    } else if (from.y < to.y) {
      return SnakeDirection.down;
    }
    return null;
  }

  void printBoard() {
    var size = store.gameState.size;
    print(List.generate(size.width, (index) => '-').join());
    print('game board');
    for (int y = 0; y < size.height; y++) {
      var line = '';
      for (int x = 0; x < size.width; x++) {
        var char = '░';
        var offset = SnakeOffset(x, y);
        OccupiedType? occupied = store.gameState.indices[offset];
        if (occupied != null) {
          switch (occupied) {
            case OccupiedType.snake:
              if (offset == store.gameState.snake.first) {
                char = '+';
              } else if (offset == store.gameState.snake.last) {
                char = '*';
              } else {
                char = 'x';
              }
              break;
            case OccupiedType.food:
              char = '○';
              break;
          }
        }
        line += char;
      }
      print(line);
    }
    print(List.generate(size.width, (index) => '-').join());
  }

  void printPathFindingBoard(
      Map<SnakeOffset, _PathNode> open,
      Map<SnakeOffset, _PathNode> close,
      List<SnakeOffset> snake,
      Map<SnakeOffset, OccupiedType> indices) {
    var size = store.gameState.size;
    print(List.generate(size.width, (index) => '-').join());
    print('path finding board');
    for (int y = 0; y < size.height; y++) {
      var line = '';
      for (int x = 0; x < size.width; x++) {
        var char = '░';
        var offset = SnakeOffset(x, y);
        _PathNode? node = close[offset];
        if (node != null) {
          char = node.cost.toString();
        }
        node = open[offset];
        if (node != null) {
          char = node.cost.toString();
        }
        OccupiedType? occupied = indices[offset];
        if (occupied != null) {
          switch (occupied) {
            case OccupiedType.snake:
              if (offset == snake.first) {
                char = '+';
              } else if (offset == snake.last) {
                char = '*';
              } else {
                char = 'x';
              }
              break;
            case OccupiedType.food:
              char = '○';
              break;
          }
        }

        line += char;
      }
      print(line);
    }
    print(List.generate(size.width, (index) => '-').join());
  }

  SnakeOffset? nextHeadOffset({SnakeDirection? direction}) {
    var head = store.gameState.snake.first;
    var d = direction ?? store.gameState.direction;
    switch (d) {
      case SnakeDirection.left:
        return SnakeOffset(head.x - 1, head.y);
      case SnakeDirection.up:
        return SnakeOffset(head.x, head.y - 1);
      case SnakeDirection.right:
        return SnakeOffset(head.x + 1, head.y);
      case SnakeDirection.down:
        return SnakeOffset(head.x, head.y + 1);
      case null:
        return null;
    }
  }

  List<SnakeOffset> dryRunTo(SnakeOffset to,
      {bool toFood = false, List<SnakeOffset>? path}) {
    var p =
        path ?? shortestPath(store.gameState.snake.first, to).reversed.toList();
    List<SnakeOffset> snake = p + store.gameState.snake;
    int length = store.gameState.snake.length + (toFood ? 1 : 0);
    snake.removeRange(length, snake.length);
    return snake;
  }

  List<SnakeOffset> dryRun({SnakeDirection? direction}) {
    SnakeOffset? next = nextHeadOffset(direction: direction);
    if (next == null) {
      return store.gameState.snake;
    }
    List<SnakeOffset> snake = List.from(store.gameState.snake);
    snake.removeLast();
    snake.insert(0, next);
    return snake;
  }

  Map<SnakeOffset, OccupiedType> indicesFromSnake(List<SnakeOffset> snake) {
    Map<SnakeOffset, OccupiedType> ret = {};
    snake.forEach((element) {
      ret[element] = OccupiedType.snake;
    });
    return ret;
  }

  static SnakeStoreGenerated genStore(BoardSize size) {
    return SnakeStoreGenerated(
        gameState: GameStateGenerated(
          snake: ReduxList([]),
          indices: ReduxMap({}),
          size: size,
          score: 0,
          phase: GamePhase.ready,
        ),
        prepareState: PrepareStateGenerated(
          phase: PreparePhase.idle,
        ))
      ..addReducer(SnakeController())
      ..changeLogEnabled = false;
  }
}

class _PathNode {
  final SnakeOffset offset;
  _PathNode? parent;
  int cost;

  _PathNode(this.offset, this.parent, this.cost);

  int costTo(SnakeOffset target) {
    if (parent == null) {
      return 1;
    }
    if (parent!.offset.x == offset.x && target.x == offset.x) {
      return 1;
    }
    if (parent!.offset.y == offset.y && target.y == offset.y) {
      return 1;
    }
    return 100;
  }

  List<SnakeOffset> path() {
    List<SnakeOffset> path = [];
    _PathNode? p = this;
    while (p != null) {
      path.add(p.offset);
      p = p.parent;
    }
    return path.reversed.toList();
  }
}
