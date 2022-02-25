// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StoreGenerator
// **************************************************************************

import 'package:flutter/widgets.dart'
    show BuildContext, StatelessWidget, Widget, Key;
import 'package:flutter_snake/model/game_state.dart';
import 'package:flutter_snake/model/prepare_state.dart';
import 'package:xg_redux_ui/xg_redux_ui.dart';
import 'dart:core';

class SnakeStoreGenerated<E extends AbstractReduxState> extends StateStore<E> {
  SnakeStoreGenerated({
    required GameStateGenerated gameState,
    required PrepareStateGenerated prepareState,
    E? extensionState,
  }) : super(extensionState: extensionState) {
    setState(gameState, 'gameState');
    protectNonnullState('gameState');
    setState(prepareState, 'prepareState');
    protectNonnullState('prepareState');
  }
  GameStateGenerated get gameState =>
      stateForKey('gameState') as GameStateGenerated;
  PrepareStateGenerated get prepareState =>
      stateForKey('prepareState') as PrepareStateGenerated;

  /// We generated this method just to be compatible with the old version, you can now directly use the 'StateCapsuleProvider.stateCapsuleOf'.
  static SnakeStoreGenerated of(BuildContext context) {
    return StateCapsuleProvider.stateCapsuleOf(context).store
        as SnakeStoreGenerated;
  }
}

/// We generated this class just to be compatible with the old version, you can now directly use the 'StateCapsuleProvider.store'.
class SnakeStoreGeneratedWidget extends StatelessWidget {
  const SnakeStoreGeneratedWidget({
    Key? key,
    required this.child,
    required this.loadStore,
  }) : super(key: key);
  final SnakeStoreGenerated Function() loadStore;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return StateCapsuleProvider.store(child: child, store: loadStore());
  }
}
