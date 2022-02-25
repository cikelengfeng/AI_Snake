// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// StateGenerator
// **************************************************************************

class GameStateGenerated extends StaticReduxState {
  GameStateGenerated({
    required ReduxList<SnakeOffset> snake,
    SnakeOffset? food,
    required ReduxMap<SnakeOffset, OccupiedType> indices,
    SnakeDirection? direction,
    required BoardSize size,
    required int score,
    required GamePhase phase,
  }) {
    _snake = snake;
    setChild(_snake, 'snake');
    protectNonnullState('snake');
    _food = WrapperState<SnakeOffset?>(food);
    setChild(_food, 'food');
    protectNonnullState('food');
    _indices = indices;
    setChild(_indices, 'indices');
    protectNonnullState('indices');
    _direction = WrapperState<SnakeDirection?>(direction);
    setChild(_direction, 'direction');
    protectNonnullState('direction');
    _size = WrapperState<BoardSize>(size);
    setChild(_size, 'size');
    protectNonnullState('size');
    _score = WrapperState<int>(score);
    setChild(_score, 'score');
    protectNonnullState('score');
    _phase = WrapperState<GamePhase>(phase);
    setChild(_phase, 'phase');
    protectNonnullState('phase');
  }
  late ReduxList<SnakeOffset> _snake;
  ReduxList<SnakeOffset> get snake => _snake;
  late WrapperState<SnakeOffset?> _food;
  set food(SnakeOffset? newValue) => _food.value = newValue;
  SnakeOffset? get food => _food.value;
  WrapperState<SnakeOffset?> get foodListenable => _food;
  late ReduxMap<SnakeOffset, OccupiedType> _indices;
  ReduxMap<SnakeOffset, OccupiedType> get indices => _indices;
  late WrapperState<SnakeDirection?> _direction;
  set direction(SnakeDirection? newValue) => _direction.value = newValue;
  SnakeDirection? get direction => _direction.value;
  WrapperState<SnakeDirection?> get directionListenable => _direction;
  late WrapperState<BoardSize> _size;
  set size(BoardSize newValue) => _size.value = newValue;
  BoardSize get size => _size.value;
  WrapperState<BoardSize> get sizeListenable => _size;
  late WrapperState<int> _score;
  set score(int newValue) => _score.value = newValue;
  int get score => _score.value;
  WrapperState<int> get scoreListenable => _score;
  late WrapperState<GamePhase> _phase;
  set phase(GamePhase newValue) => _phase.value = newValue;
  GamePhase get phase => _phase.value;
  WrapperState<GamePhase> get phaseListenable => _phase;
}
