import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'solana_web3_wrapper_platform_interface.dart';

/// An implementation of [SolanaWeb3WrapperPlatform] that uses method channels.
class MethodChannelSolanaWeb3Wrapper extends SolanaWeb3WrapperPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('solana_web3_wrapper');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
