import 'package:xg_redux_ui/xg_redux_ui.dart';

part 'prepare_state.g.dart';

enum PreparePhase { idle, ready }

@autoState
class PrepareState {
  late PreparePhase phase;
}
