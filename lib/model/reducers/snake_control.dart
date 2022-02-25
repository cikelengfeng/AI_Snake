import 'dart:math';

import 'package:flutter_snake/model/actions/game_actions.dart';
import 'package:flutter_snake/model/game_state.dart';
import 'package:flutter_snake/model/store.redux_store.dart';
import 'package:flutter_snake/model/utils/store_helper.dart';
import 'package:xg_redux_ui/xg_redux_ui.dart';

class SnakeController extends Reducer<SnakeStoreGenerated> {
  Random _random = Random();

  @override
  void reduce(SnakeStoreGenerated store, Action action) {
    var helper = StoreHelper(store);
    if (action is ControlDirection) {
      var invalidDirection = helper.invalidDirection();
      if (invalidDirection != null && action.direction == invalidDirection) {
        return;
      }
      if (store.gameState.phase == GamePhase.ready) {
        store.gameState.phase = GamePhase.playing;
        store.gameState.score = 0;
        _reset(store);
      }
      store.gameState.direction = action.direction;
    }
    if (action is Loop) {
      if (store.gameState.phase != GamePhase.playing) {
        return;
      }
      _updateSnake(store);
    }
    if (action is InitGame) {
      _reset(store);
      store.gameState.phase = GamePhase.ready;
    }
  }

  @override
  List<ActionToken> tokens(SnakeStoreGenerated store) {
    return [
      TypedActionToken(ControlDirection),
      TypedActionToken(Loop),
      TypedActionToken(InitGame),
    ];
  }

  void _updateSnake(SnakeStoreGenerated store) {
    var helper = StoreHelper(store);
    SnakeOffset? next = helper.nextHeadOffset();
    OccupiedType? occupiedType = store.gameState.indices[next];
    if (occupiedType == OccupiedType.snake &&
        next != store.gameState.snake.last) {
      //    身体
      store.gameState.phase = GamePhase.over;
    } else if (occupiedType == OccupiedType.food) {
      // 食物
      store.gameState.snake.insert(0, next!);
      store.gameState.indices[next] = OccupiedType.snake;
      store.gameState.score += 1;
      var food = _randomFood(store);
      if (food == null) {
        store.gameState.phase = GamePhase.win;
      }
    } else if (helper.isOutOfBounds(next!)) {
      // 边界
      store.gameState.phase = GamePhase.over;
    } else {
      // 空白
      var last = store.gameState.snake.removeLast();
      store.gameState.indices.remove(last);
      store.gameState.snake.insert(0, next);
      store.gameState.indices[next] = OccupiedType.snake;
    }
  }

  void _reset(SnakeStoreGenerated store) {
    var size = store.gameState.size;
    var initOffset = SnakeOffset(size.width ~/ 2, size.height ~/ 2);
    store.gameState.snake.clear();
    store.gameState.snake.add(initOffset);
    store.gameState.indices.clear();
    store.gameState.indices[initOffset] = OccupiedType.snake;
    _randomFood(store);
    store.gameState.direction = null;
  }

  SnakeOffset? _randomFood(SnakeStoreGenerated store) {
    var size = store.gameState.size;
    var exclude =
        store.gameState.indices.keys.map((e) => e.toIndex(size.width));
    Set<int> set =
        Set.from(List.generate(size.width * size.height, (index) => index));
    set.removeAll(exclude);
    List<int> blanks = set.toList();
    if (blanks.isEmpty) {
      //游戏结束
      return null;
    }
    int index = blanks[_random.nextInt(blanks.length)];
    var target = SnakeOffset.fromIndex(index, size.width);
    if (store.gameState.indices.containsKey(target)) {
      throw StateError('generate food at wrong position $target');
    }
    store.gameState.food = target;
    store.gameState.indices[target] = OccupiedType.food;
    return target;
  }
}
