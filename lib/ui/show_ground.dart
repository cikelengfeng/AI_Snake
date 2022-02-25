import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_snake/ai/player.dart';
import 'package:flutter_snake/model/actions/game_actions.dart';
import 'package:flutter_snake/model/game_state.dart';
import 'package:flutter_snake/model/store.redux_store.dart';
import 'package:flutter_snake/model/utils/store_helper.dart';
import 'package:flutter_snake/model/utils/store_provider.dart';
import 'package:flutter_snake/ui/game_scene.dart';

class ShowGround extends StatefulWidget {
  @override
  _ShowGroundState createState() => _ShowGroundState();
}

class _ShowGroundState extends State<ShowGround> {
  @override
  Widget build(BuildContext context) {
    return SnakeStoreGeneratedWidget(
      child: AspectRatio(
        aspectRatio: 1,
        child: _Show(),
      ),
      loadStore: () => StoreHelper.genStore(BoardSize(12, 12)),
    );
  }
}

class _Show extends StatefulWidget {
  @override
  __ShowState createState() => __ShowState();
}

class __ShowState extends State<_Show> with StoreProvider {
  Timer? looper;
  SnakePlayer? player;
  FocusNode focusNode = FocusNode();
  bool paused = false;

  @override
  void initState() {
    player = ExpertAlien(store);
    var d1 = store.gameState.phaseListenable.addListener(() {
      switch (store.gameState.phase) {
        case GamePhase.ready:
          break;
        case GamePhase.playing:
          break;
        case GamePhase.over:
          looper?.cancel();
          break;
        case GamePhase.win:
          store.sendAction(InitGame());

          break;
      }
    });
    disposables.addAll([d1]);
    looper = Timer.periodic(Duration(milliseconds: 100), (t) {
      if (isPaused()) {
        return;
      }
      player?.play();
      store.sendAction(Loop());
    });
    store.sendAction(InitGame());
    super.initState();
  }

  bool isPaused() {
    return paused;
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: focusNode,
      child: GameScene(
        internalControl: false,
      ),
      onKey: (k) {
        if (k is RawKeyDownEvent && k.logicalKey == LogicalKeyboardKey.space) {
          paused = !paused;
        }
      },
    );
  }
}
