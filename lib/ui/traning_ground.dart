import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_snake/ai/player.dart';
import 'package:flutter_snake/model/store.redux_store.dart';
import 'package:flutter_snake/ui/game_scene.dart';
import 'package:xg_redux_ui/xg_redux_ui.dart';

class TrainingGround extends StatefulWidget {
  final List<SnakePlayer> players;

  const TrainingGround({Key? key, this.players = const []}) : super(key: key);

  @override
  _TrainingGroundState createState() => _TrainingGroundState();
}

class _TrainingGroundState extends State<TrainingGround> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Wrap(
      spacing: 1,
      runSpacing: 1,
      children: _allBoard(),
    ));
  }

  List<Widget> _allBoard() {
    return widget.players.map((e) {
      return SizedBox(
        width: 100,
        height: 150,
        child: _trainingBoard(e),
      );
    }).toList();
  }

  Widget _trainingBoard(SnakePlayer player) {
    return _TrainingBoard(
      player: player,
    );
  }
}

class _TrainingBoard extends StatefulWidget {
  final SnakePlayer player;

  const _TrainingBoard({Key? key, required this.player}) : super(key: key);

  @override
  _TrainingBoardState createState() => _TrainingBoardState();
}

class _TrainingBoardState extends State<_TrainingBoard> {
  List<ListenerDisposable> disposables = [];

  @override
  void initState() {
    var d = widget.player.store.gameState.scoreListenable.addHotListener(() {
      setState(() {});
    });
    disposables.addAll([d]);
    super.initState();
  }

  @override
  void dispose() {
    disposables.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var score = widget.player.store.gameState.score;
    var size = widget.player.store.gameState.size;
    return SnakeStoreGeneratedWidget(
      loadStore: () => widget.player.store,
      child: Container(
        color: score > 0
            ? Color.lerp(Colors.white, Colors.red,
                (score * 10) / (size.width * size.height))
            : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '${widget.player}',
              maxLines: 1,
            ),
            Text('score: ${widget.player.store.gameState.score}'),
            GameScene(
              internalControl: false,
            ),
          ],
        ),
      ),
    );
  }
}
