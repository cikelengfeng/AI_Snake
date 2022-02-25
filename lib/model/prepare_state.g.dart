// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prepare_state.dart';

// **************************************************************************
// StateGenerator
// **************************************************************************

class PrepareStateGenerated extends StaticReduxState {
  PrepareStateGenerated({
    required PreparePhase phase,
  }) {
    _phase = WrapperState<PreparePhase>(phase);
    setChild(_phase, 'phase');
    protectNonnullState('phase');
  }
  late WrapperState<PreparePhase> _phase;
  set phase(PreparePhase newValue) => _phase.value = newValue;
  PreparePhase get phase => _phase.value;
  WrapperState<PreparePhase> get phaseListenable => _phase;
}
