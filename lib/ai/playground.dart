import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_snake/ai/player.dart';
import 'package:flutter_snake/model/actions/game_actions.dart';
import 'package:flutter_snake/model/game_state.dart';
import 'package:flutter_snake/model/store.redux_store.dart';
import 'package:flutter_snake/model/utils/store_helper.dart';
import 'package:flutter_snake/utils/random.dart';

class PlayGround {
  List<SnakePlayer> get snakePlayers {
    List<SnakePlayer> ret = [];
    ret.addAll(_aliens);
    ret.addAll(_players);
    return ret;
  }

  List<Player> _players = [];
  List<NaiveAlien> _aliens = [];
  Map<int, List<Player>> _scoreMap = {};
  Map<int, int> _selectionInfo = {};
  Timer? _timer;
  Random _random = Random();
  static const int POP_SIZE = 200;
  static const BoardSize GAME_SIZE = BoardSize(10, 10);
  static const Duration LIFE_TIME = Duration(seconds: 10);
  static const Duration ACTION_CYCLE = Duration(milliseconds: 10);

  int _highScore = 0;
  int _gen = 0;

  SnakeStoreGenerated _genStore() {
    return StoreHelper.genStore(GAME_SIZE);
  }

  void startTraining(void Function(int gen) newPopulation) {
    _prepareAliens();
    _preparePopulation();
    newPopulation(_gen);
    _startPopulation(() {
      if (_highScore > 100) {
        print('high score is $_highScore, training complete!');
        return;
      }
      startTraining(newPopulation);
    });
  }

  void _prepareAliens() {
    _aliens = [
      NaiveAlien(_genStore()),
      ExpertAlien(_genStore()),
      BoringAlien(_genStore())
    ];
    _aliens.forEach((element) {
      element.store.sendAction(InitGame());
    });
  }

  void _preparePopulation() {
    _selectionInfo.clear();
    if (_scoreMap.isNotEmpty) {
      List<Player> bestPlayers =
          _highScore == 0 ? [] : (_scoreMap[_highScore] ?? []);
      int newPopSize =
          POP_SIZE - bestPlayers.length;
      _players = List.generate(newPopSize, (index) {
        var f = _select();
        var m = _select();
        var c = f.crossover(m, _genStore());
        return c;
      });
      _players.addAll(bestPlayers.map((e) => e..store = _genStore()));
    } else {
      var savedPlayer = _constructPlayerPairsFromLastGeneration().toList();
      int existCount = savedPlayer.length;
      var newPlayers = List.generate(
          POP_SIZE - existCount, (index) => Player.random(_genStore()));
      _players = savedPlayer + newPlayers;
    }
    _players.forEach((element) {
      element.store.sendAction(InitGame());
      element.start();
    });
    _gen += 1;
  }

  void _startPopulation(void Function() completion) {
    _timer?.cancel();
    _timer = Timer.periodic(ACTION_CYCLE, (t) {
      if (!_isPopulationDone()) {
        _timer?.cancel();
        print('turn is over');
        _players.sort((a, b) => a.store.gameState.score - b.store.gameState.score);
        _players.forEach((element) {
          _highScore = _highScore < element.store.gameState.score
              ? element.store.gameState.score
              : _highScore;
          print('$element score: ${element.store.gameState.score}');
        });
        _scoreMap = _players.fold({}, (previousValue, element) {
          int key = element.store.gameState.score;
          List<Player>? group = previousValue[key];
          if (group == null) {
            group = [];
            previousValue[key] = group;
          }
          group.add(element);
          return previousValue;
        });
        print('selection info $_selectionInfo');
        print(
            'gen $_gen score map ${_scoreMap.map((key, value) => MapEntry(key, value.length))}');
        print('highest score in the history: $_highScore');
        _saveLastPlayers(_players, _gen);
        completion();
        return;
      }
      _players.where((element) => _shouldPlay(element)).forEach((element) {
//        print('${element.player} is still playing');
        element.play();
        element.store.sendAction(Loop());
      });
      _aliens
          .where((element) => element.store.gameState.phase != GamePhase.over)
          .forEach((element) {
        element.play();
        element.store.sendAction(Loop());
      });
    });
  }

  bool _shouldPlay(Player player) {
    DateTime now = DateTime.now();
    return player.store.gameState.phase != GamePhase.over &&
        now.difference(player.time!) < LIFE_TIME;
  }

  bool _isPopulationDone() {
    bool ret = false;
    for (var value in _players) {
      ret = ret || _shouldPlay(value);
    }
    return ret;
  }

  Player _select() {
    var weightedScoreMap =
        _scoreMap.map((key, value) => MapEntry(pow(key, 4).toInt() + 1, value));
    var weightList = weightedScoreMap.keys.toList();

    int groupIndex = randomWeighted(weightList, _random);
    var group = weightedScoreMap[weightList[groupIndex]]!;
    var selectedPlayer = group[_random.nextInt(group.length)];
    var count = _selectionInfo[selectedPlayer.store.gameState.score];
    if (count == null) {
      count = 0;
    }
    count += 1;
    _selectionInfo[selectedPlayer.store.gameState.score] = count;
    return selectedPlayer;
  }

  File _dnaFile() {
    var ret = File('/Users/xudong/Downloads/flutter_snake/dna/last.json');
    if (!ret.existsSync()) {
      ret.createSync(recursive: true);
    }
    return ret;
  }

  Map<String, dynamic>? _readDnaFile() {
    var file = _dnaFile();
    var content = file.readAsStringSync();
    if (content.isEmpty) {
      return null;
    }
    return json.decode(content);
  }

  void _saveLastPlayers(Iterable<Player> players, int gen) {
    var playerInfo = players.map((e) => {'dna':e.dna, 'score': e.store.gameState.score}).toList();
    var selection = _selectionInfo.map((key, value) => MapEntry(key.toString(), value));
    var scoreMap = _scoreMap.map((key, value) => MapEntry(key.toString(), value.length));
    var file = _dnaFile();
    Map data = {'players': playerInfo, 'gen': _gen, "selection": selection, 'scoreMap': scoreMap, 'highestScore': _highScore};
    String fileContent = json.encode(data);
    file.writeAsStringSync(fileContent);
  }

  Iterable<Player> _constructPlayerPairsFromLastGeneration() {
    var saved = _readDnaFile();
    if (saved == null) {
      return [];
    }
    var playerInfo = saved['players'];
    var gen = saved['gen'] as int;
    _gen = gen;
    var highest = saved['highestScore'] as int;
    _highScore = highest;
    List<Player> players = List.castFrom(playerInfo.map((e) => Player(List.castFrom(e['dna']), _genStore())).toList());
    return players;
  }
}
