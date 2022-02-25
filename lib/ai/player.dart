import 'dart:math';

import 'package:flutter_snake/model/utils/euler_circuit.dart';
import 'package:flutter_snake/model/utils/store_helper.dart';
import 'package:flutter_snake/model/actions/game_actions.dart';
import 'package:flutter_snake/model/game_state.dart';
import 'package:flutter_snake/model/store.redux_store.dart';
import 'package:flutter_snake/utils/random.dart';

abstract class SnakePlayer {
  late SnakeStoreGenerated store;
  void play();
}

class Player implements SnakePlayer {
  static const List<int> MUTATION_RATIO = [3, 997];
  static const List<int> FROM_PARENT_RATIO = [995, 5];
  static const int POP_SIZE = 100;
  static const int GENE_MAX = 200;

  late List<int> dna;
  SnakeStoreGenerated store;
  final Random _random = Random();
  DateTime? time;
  StoreHelper _storeHelper;

  Player(this.dna, this.store) : _storeHelper = StoreHelper(store);
  Player.random(this.store) : _storeHelper = StoreHelper(store)
  {
    dna = _randomDna();
  }

  @override
  String toString() {
    return '$runtimeType{${dna.join('|')}}';
  }

  void start() {
    time = DateTime.now();
  }

  int dnaLength() {
    return 26;
  }

  int _randomGene() {
    return _random.nextInt(GENE_MAX) - GENE_MAX ~/ 2;
  }

  List<int> _randomDna() {
    return List.generate(dnaLength(), (index) => _randomGene());
  }

  Player crossover(Player p2, SnakeStoreGenerated store) {
    List<int> newDNA = [];
    int patch = 2;
    for (int i = 0; i < dnaLength() ~/ patch; i++) {
      int fromParent = randomWeighted(FROM_PARENT_RATIO, _random);
      Iterable<int> g;
      if (fromParent == 0) {
        bool useF = _random.nextBool();
        if (useF) {
          g = dna.getRange(i * patch, (i + 1) * patch);
        } else {
          g = p2.dna.getRange(i * patch, (i + 1) * patch);
        }
      } else {
        g = List.generate(patch, (index) => _randomGene());
      }
      newDNA.addAll(g);
    }
    for (int i = 0; i < newDNA.length; i++) {
      int mutation = randomWeighted(MUTATION_RATIO, _random);
      if (mutation == 0) {
        int g;
        g = _randomGene();
        newDNA[i] = g;
      }
    }
    return Player(newDNA, store);
  }

  SnakeDirection _translateDNA() {
    var headToFoodX = _storeHelper.headToFoodX();
    var headToFoodY = _storeHelper.headToFoodY();
    var headToTailX = _storeHelper.headToTailX();
    var headToTailY = _storeHelper.headToTailY();
    var headToLeftEdge = _storeHelper.headToEdge(SnakeDirection.left);
    var headToTopEdge = _storeHelper.headToEdge(SnakeDirection.up);
    var headToRightEdge = _storeHelper.headToEdge(SnakeDirection.right);
    var headToBottomEdge = _storeHelper.headToEdge(SnakeDirection.down);
    var headToLeftBody = _storeHelper.headToBody(SnakeDirection.left);
    var headToTopBody = _storeHelper.headToBody(SnakeDirection.up);
    var headToRightBody = _storeHelper.headToBody(SnakeDirection.right);
    var headToBottomBody = _storeHelper.headToBody(SnakeDirection.down);

//    print(
//        'hfx: $headToFoodX, hfy: $headToFoodY, d: $direction, hte: $headToEdge, htb: $headToBody');

    var toFoodX = sigmoid(headToFoodX); //正数向左，负数向右
    var toFoodY = sigmoid(headToFoodY); //正数向上，负数向下
//    正数向左，负数向右
    var awayObstacleX = sigmoid(headToTailX * dna[0] +
        headToLeftEdge * dna[1] +
        headToRightEdge * dna[2] +
        headToLeftBody * dna[3] +
        headToRightBody * dna[4]);
//    正数向上，负数向下
    var awayObstacleY = sigmoid(headToTailY * dna[5] +
        headToTopEdge * dna[6] +
        headToBottomEdge * dna[7] +
        headToTopBody * dna[8] +
        headToBottomBody * dna[9]);

//    print(
//        'tfx: $toFoodX, tfy: $toFoodY, aox: $awayObstacleX, aoy: $awayObstacleY');

//    向左的倾向程度，dna[10]应该为正数，dna[11]应该为负数，形成不同意见，dna[12]应该为正数，dna[13]应该为负数，形成不同意见
    var left = relu(toFoodX * dna[10] +
        toFoodY * dna[11] +
        awayObstacleX * dna[12] +
        awayObstacleY * dna[13]);
//    向右的倾向程度，dna[14]+,dna[15]-,dna[16]+,dna[17]-
    var right = relu(toFoodX * dna[14] +
        toFoodY * dna[15] +
        awayObstacleX * dna[16] +
        awayObstacleY * dna[17]);
//    向上的倾向程度，dna[18]-,dna[19]+,dna[20]-,dna[21]+
    var up = relu(toFoodX * dna[18] +
        toFoodY * dna[19] +
        awayObstacleX * dna[20] +
        awayObstacleY * dna[21]);
//    向下的倾向程度，dna[22]-,dna[23]+,dna[24]-,dna[25]+
    var down = relu(toFoodX * dna[22] +
        toFoodY * dna[23] +
        awayObstacleX * dna[24] +
        awayObstacleY * dna[25]);

//    print('hl: $left, hu: $up, hr: $right, hd: $down');

    var choice =
        randomWeighted([left + 1, up + 1, right + 1, down + 1], _random);
    return SnakeDirection.values[choice];
  }

  int sigmoid(int x) {
    return (1 / (1 + pow(e, -x)) * 100).toInt();
  }

  int relu(int x) {
    return max(0, x);
  }

  @override
  void play() {
    var action = _translateDNA();
    if (action == null) {
      return;
    }
    store.sendAction(ControlDirection(action));
  }
}

class NaiveAlien implements SnakePlayer {
  SnakeStoreGenerated store;
  StoreHelper _helper;

  NaiveAlien(this.store) : _helper = StoreHelper(store);

  @override
  String toString() {
    return '$runtimeType';
  }

  void play() {
    int htfx = _helper.headToFoodX();
    int htfy = _helper.headToFoodY();
    SnakeDirection foodDirection;
    if (htfx.abs() > htfy.abs()) {
      foodDirection = htfx > 0 ? SnakeDirection.left : SnakeDirection.right;
    } else {
      foodDirection = htfy > 0 ? SnakeDirection.up : SnakeDirection.down;
    }
    SnakeDirection action = foodDirection;
    var htb = _helper.headToBody(action);
    var hte = _helper.headToEdge(action);
    int dangerDistance = min(htb == -1 ? 2 << 20 : htb, hte);
    var invalidAction = _helper.invalidDirection();
    if (dangerDistance <= 1 || action == invalidAction) {
      // 此路不通

      for (var value in SnakeDirection.values) {
        if (value == action) {
          continue;
        }
        if (value == invalidAction) {
          continue;
        }
        var newhtb = _helper.headToBody(value);
        var newhte = _helper.headToEdge(value);
        int newDangerDistance = min(newhtb == -1 ? 2 << 20 : newhtb, newhte);
        if (newDangerDistance > 1) {
          action = value;
          break;
//        } else {
//          print('new htb : $newhtb, newhte : $newhte');
        }
      }
//    } else {
//      print('htb : $htb, hte : $hte');
    }
//    print('invalid action $invalidAction');
//    print(
//        'head ${store.gameState.snake.first}, food ${store.gameState.food}, firstaction: $foodDirection, action $action');
    store.sendAction(ControlDirection(action));
  }
}

class ExpertAlien extends NaiveAlien {
  ExpertAlien(SnakeStoreGenerated store) : super(store);

  @override
  void play() {
//    _helper.printBoard();
    SnakeDirection? direction;
    var head = store.gameState.snake.first;
    var pathToFood = _helper.shortestPath(head, store.gameState.food!);
    if (store.gameState.snake.length <= 2) {
      direction = _helper.direction(head, pathToFood.first);
    } else {
      var tail = store.gameState.snake.last;
      var pathToTail = _helper.shortestPath(head, tail);
      if (pathToFood.isEmpty) {
        if (pathToTail.isEmpty) {
//        do nothing
//          print('lost path to tail');
        } else {
          direction = catchTail();
//          print('no way to food, go catch the tail');
        }
      } else {
        var toFoodDirection = _helper.direction(head, pathToFood.first);
        var dryRunSnake = _helper.dryRunTo(store.gameState.food!, toFood: true);
        var dryRunHeadToTail = _helper.shortestPath(
            dryRunSnake.first, dryRunSnake.last,
            customSnake: dryRunSnake);
        if (pathToTail.isNotEmpty && dryRunHeadToTail.isEmpty) {
//        "路走窄了啊"
          direction = catchTail();
//          print(
//              'if we turn $toFoodDirection, tail is going to be not reachable, stop, go catch the tail');
        } else {
          direction = toFoodDirection;
//          print('go to food');
        }
      }
    }
    if (direction == null) {
//      print('fallback to naive');
      var invalidAction = _helper.invalidDirection();
      for (var value in SnakeDirection.values) {
        if (value == direction) {
          continue;
        }
        if (value == invalidAction) {
          continue;
        }
        var newhtb = _helper.headToBody(value);
        var newhte = _helper.headToEdge(value);
        int newDangerDistance = min(newhtb == -1 ? 2 << 20 : newhtb, newhte);
        if (newDangerDistance > 1) {
          direction = value;
          break;
        }
      }
    }

    if (direction != null) {
//      print('direction: $direction');
      var nextHeadOffset = _helper.nextHeadOffset(direction: direction);
      if (store.gameState.indices[nextHeadOffset] == OccupiedType.snake &&
          nextHeadOffset != store.gameState.snake.last) {
        print('holy shit! gonna eat myself!');
      }
      store.sendAction(ControlDirection(direction));
    }
  }

  SnakeDirection? catchTail() {
    SnakeDirection? direction;
    var head = store.gameState.snake.first;
    var food = store.gameState.food!;
    var tail = store.gameState.snake.last;
    var pathToTail = _helper.shortestPath(head, tail);
    // 看一下下一步可选的几个位置距离尾巴和食物的距离，按照以下规则选取：
//          1. 保证头尾联通
//          2. 下一步位置应该距离食物最远，这样避免生成更多的独立空间（洞）
    var leftToTail = _helper.shortestPath(head.left(), tail).length;
    var leftToFood = _helper.distance(head.left(), food);
    var upToTail = _helper.shortestPath(head.up(), tail).length;
    var upToFood = _helper.distance(head.up(), food);
    var rightToTail = _helper.shortestPath(head.right(), tail).length;
    var rightToFood = _helper.distance(head.right(), food);
    var downToTail = _helper.shortestPath(head.down(), tail).length;
    var downToFood = _helper.distance(head.down(), food);
    var tailDistances = [
      MapEntry(SnakeDirection.left, leftToTail),
      MapEntry(SnakeDirection.up, upToTail),
      MapEntry(SnakeDirection.right, rightToTail),
      MapEntry(SnakeDirection.down, downToTail)
    ];
    var foodDistances = [
      MapEntry(SnakeDirection.left, leftToFood),
      MapEntry(SnakeDirection.up, upToFood),
      MapEntry(SnakeDirection.right, rightToFood),
      MapEntry(SnakeDirection.down, downToFood)
    ];
    // 排除回头的方向
    var invalidDirection = _helper.invalidDirection();
    tailDistances.removeWhere((element) => element.key == invalidDirection);
    foodDistances.removeWhere((element) => element.key == invalidDirection);
    // 排除咬自己的方向
    Set<SnakeDirection> removed = Set();
    for (var value in tailDistances) {
      var nextHead = _helper.nextHeadOffset(direction: value.key);
      if (store.gameState.indices[nextHead] == OccupiedType.snake &&
          nextHead != store.gameState.snake.last) {
        removed.add(value.key);
      }
    }
//          排除不能联通尾巴的路径
    for (var value in tailDistances) {
      if (value.value == 0) {
        removed.add(value.key);
      }
    }
    tailDistances.removeWhere((element) => removed.contains(element.key));
    foodDistances.removeWhere((element) => removed.contains(element.key));
//          从剩余的选择里选择一个离食物最远的
    if (tailDistances.isNotEmpty) {
      foodDistances.sort((a, b) => a.value.compareTo(b.value));
      direction = foodDistances.last.key;
    } else {
      direction = _helper.direction(head, pathToTail.first);
    }
    return direction;
  }
}

class BoringAlien extends NaiveAlien {
  BoringAlien(SnakeStoreGenerated store) : super(store) {
    circuit = genEulerCircuit(store.gameState.size);
  }
  List<EulerCircuitNode>? circuit;

  @override
  void play() {
    var head = store.gameState.snake.first;
    var size = store.gameState.size;
    var currentNode = circuit![head.toIndex(size.width)];
    var direction = currentNode.direction;
    store.sendAction(ControlDirection(direction));
  }
}
