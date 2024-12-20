import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solana_web3_wrapper/solana_web3_wrapper_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSolanaWeb3Wrapper platform = MethodChannelSolanaWeb3Wrapper();
  const MethodChannel channel = MethodChannel('solana_web3_wrapper');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
