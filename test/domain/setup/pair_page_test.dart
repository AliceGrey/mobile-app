import 'package:cobble/domain/entities/pebble_scan_device.dart';
import 'package:cobble/infrastructure/pigeons/scan_provider.dart'
    as scan_provider;
import 'package:cobble/ui/common/icons/watch_icon.dart';
import 'package:cobble/ui/setup/pair_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/all.dart';

final device = PebbleScanDevice(
  'Test',
  1,
  'v1',
  'asdasdsd',
  0,
  true,
  true,
);

class ScanCallbacks extends scan_provider.ScanCallbacks {
  void startScanning() {
    this.state = scan_provider.ScanState(true, state.devices);
  }

  void stopScanning() {
    this.state = scan_provider.ScanState(false, state.devices);
  }

  void updateDevices(int length) {
    this.state = scan_provider.ScanState(
      state.scanning,
      List.generate(length, (index) => device),
    );
  }
}

Widget wrapper({ScanCallbacks mock}) => ProviderScope(
      overrides: [
        scan_provider.scanProvider.overrideWithValue(
          mock ?? ScanCallbacks(),
        ),
      ],
      child: MaterialApp(
        home: PairPage(
          fromLanding: true,
        ),
      ),
    );

void main() {
  group('PairPage', () {
    testWidgets('should work', (tester) async {
      await tester.pumpWidget(
        wrapper(),
      );
    });
    testWidgets('shouldn\'t display loader by default', (tester) async {
      await tester.pumpWidget(
        wrapper(),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    testWidgets('should display loader when scan starts', (tester) async {
      final mock = ScanCallbacks();

      await tester.pumpWidget(wrapper(mock: mock));
      mock.startScanning();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    testWidgets('should hide loader when scan stops', (tester) async {
      final mock = ScanCallbacks();

      mock.startScanning();
      await tester.pumpWidget(wrapper(mock: mock));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      mock.stopScanning();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    testWidgets('should display devices if there are any', (tester) async {
      final mock = ScanCallbacks();
      mock.updateDevices(3);

      await tester.pumpWidget(wrapper(mock: mock));
      expect(find.byType(PebbleWatchIcon), findsNWidgets(3));
    });
    testWidgets('should update devices', (tester) async {
      final mock = ScanCallbacks();
      mock.updateDevices(3);

      await tester.pumpWidget(wrapper(mock: mock));
      mock.updateDevices(5);
      await tester.pump();
      expect(find.byType(PebbleWatchIcon), findsNWidgets(5));
    });
  });
}
