import 'package:flutter_snake/model/game_state.dart';

class EulerCircuitNode {
  final SnakeOffset offset;
  final SnakeDirection direction;
  final int index;

  EulerCircuitNode(this.offset, this.direction, this.index);
}

List<EulerCircuitNode>? genEulerCircuit(BoardSize size) {
  if (size.height.isOdd && size.width.isOdd) {
    return null;
  }
  List<EulerCircuitNode> circuit =
      List.generate(size.width * size.height, (index) {
    SnakeOffset offset = SnakeOffset.fromIndex(index, size.width);
    int x = offset.x;
    int y = offset.y;
    if (x == 0 && y == 0) {
      return EulerCircuitNode(offset, SnakeDirection.right, 0);
    } else if (y.isEven && x > 0 && x < size.width - 1) {
      return EulerCircuitNode(offset, SnakeDirection.right, y * size.width + x);
    } else if (y.isEven && x == size.width - 1) {
      return EulerCircuitNode(offset, SnakeDirection.down, y * size.width + x);
    } else if (y.isOdd && x > 1 && x < size.width) {
      return EulerCircuitNode(
          offset, SnakeDirection.left, (y + 1) * size.width - x - 1);
    } else if (y.isOdd && y != size.height - 1 && x == 1) {
      return EulerCircuitNode(
          offset, SnakeDirection.down, (y + 1) * size.width - x - 1);
    } else if (y == size.height - 1 && x == 1) {
      return EulerCircuitNode(
          offset, SnakeDirection.left, (y + 1) * size.width - x - 1);
    } else {
      //x == 0
      return EulerCircuitNode(
          offset, SnakeDirection.up, size.width * size.height - y);
    }
  });
  return circuit;
}
