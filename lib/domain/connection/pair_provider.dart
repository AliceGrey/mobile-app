import 'package:cobble/infrastructure/pigeons/pigeons.g.dart' as pigeon;
import 'package:hooks_riverpod/all.dart';

class PairCallbacks extends StateNotifier<int> implements pigeon.PairCallbacks {
  PairCallbacks() : super(null);

  @override
  void onWatchPairComplete(pigeon.NumberWrapper arg) {
    state = arg.value;
  }
}

/// Stores the address of device you are paired to. Can be null.
final pairProvider = StateNotifierProvider<PairCallbacks>((ref) {
  final notifier = PairCallbacks();
  pigeon.PairCallbacks.setup(notifier);
  ref.onDispose(() {
    pigeon.PairCallbacks.setup(null);
  });
  return notifier;
});
