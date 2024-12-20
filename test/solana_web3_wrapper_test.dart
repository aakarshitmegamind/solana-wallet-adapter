import 'package:flutter_test/flutter_test.dart';
import 'package:solana_web3_wrapper/solana_web3_wrapper.dart';
import 'package:solana_web3_wrapper/solana_web3_wrapper_platform_interface.dart';
import 'package:solana_web3_wrapper/solana_web3_wrapper_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSolanaWeb3WrapperPlatform
    with MockPlatformInterfaceMixin
    implements SolanaWeb3WrapperPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SolanaWeb3WrapperPlatform initialPlatform = SolanaWeb3WrapperPlatform.instance;

  test('$MethodChannelSolanaWeb3Wrapper is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSolanaWeb3Wrapper>());
  });

  test('getPlatformVersion', () async {
    SolanaWeb3Wrapper solanaWeb3WrapperPlugin = SolanaWeb3Wrapper();
    MockSolanaWeb3WrapperPlatform fakePlatform = MockSolanaWeb3WrapperPlatform();
    SolanaWeb3WrapperPlatform.instance = fakePlatform;

    expect(await solanaWeb3WrapperPlugin.getPlatformVersion(), '42');
  });
}
