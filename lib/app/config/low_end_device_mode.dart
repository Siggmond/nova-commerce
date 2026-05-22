import 'package:flutter_riverpod/flutter_riverpod.dart';

const bool lowEndDeviceModeFlag = bool.fromEnvironment(
  'LOW_END_DEVICE_MODE',
  defaultValue: false,
);

final lowEndDeviceModeProvider = Provider<bool>((ref) {
  return lowEndDeviceModeFlag;
});
