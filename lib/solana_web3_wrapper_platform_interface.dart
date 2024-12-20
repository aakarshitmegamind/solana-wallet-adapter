import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'solana_web3_wrapper_method_channel.dart';

abstract class SolanaWeb3WrapperPlatform extends PlatformInterface {
  /// Constructs a SolanaWeb3WrapperPlatform.
  SolanaWeb3WrapperPlatform() : super(token: _token);

  static final Object _token = Object();

  static SolanaWeb3WrapperPlatform _instance = MethodChannelSolanaWeb3Wrapper();

  /// The default instance of [SolanaWeb3WrapperPlatform] to use.
  ///
  /// Defaults to [MethodChannelSolanaWeb3Wrapper].
  static SolanaWeb3WrapperPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SolanaWeb3WrapperPlatform] when
  /// they register themselves.
  static set instance(SolanaWeb3WrapperPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
