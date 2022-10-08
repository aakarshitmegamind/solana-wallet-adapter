/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:solana_common/models/serializable.dart';
import 'package:solana_common/protocol/json_rpc_request_config.dart';
import 'package:solana_common/web_socket/solana_web_socket_connection.dart';
import '../exceptions/solana_wallet_adapter_protocol_exception.dart';
import '../models/authorize_params.dart';
import '../models/authorize_result.dart';
import '../models/clone_authorization_params.dart';
import '../models/clone_authorization_result.dart';
import '../models/deauthorize_params.dart';
import '../models/deauthorize_result.dart';
import '../models/get_capabilities_params.dart';
import '../models/get_capabilities_result.dart';
import '../models/method.dart';
import '../models/reauthorize_params.dart';
import '../models/reauthorize_result.dart';
import '../models/sign_and_send_transactions_params.dart';
import '../models/sign_and_send_transactions_result.dart';
import '../models/sign_messages_params.dart';
import '../models/sign_messages_result.dart';
import '../models/sign_transactions_params.dart';
import '../models/sign_transactions_result.dart';


/// Wallet Adapter Connection
/// ------------------------------------------------------------------------------------------------

/// The client interface of the mobile wallet adapter protocol.
mixin WalletAdapterConnection on SolanaWebSocketConnection {

  /// Invoke a JSON-RPC web socket [method] call with [params].
  @protected
  Future<T> send<T>(
    final Method method,
    final Serializable? params, {
    final JsonRpcRequestConfig? config,
  });

  /// **********************************************************************************************
  /// {@template solana_wallet_adapter.nonPrivilegedMethods}
  /// Non-privileged methods.
  /// 
  /// These methods do not require the current session to be in an authorized state to invoke them 
  /// (though they may still accept an auth_token to provide their functionality).
  /// {@endtemplate}
  /// **********************************************************************************************
  
  /// Invoke [Method.authorize].
  /// 
  /// This method allows the dApp endpoint to request authorization from the wallet endpoint for 
  /// access to `privileged methods`. On success, it returns an [AuthorizeResult.authToken] 
  /// providing access to privileged methods, along with addresses and optional labels for all 
  /// authorized accounts. It may also return a URI suitable for future use as an 
  /// `endpoint-specific URI`. After a successful call to [authorize], the current session will be 
  /// placed into an authorized state, with privileges associated with the returned 
  /// [AuthorizeResult.authToken]. On failure, the current session with be placed into the 
  /// unauthorized state.
  /// 
  /// This [AuthorizeResult.authToken] may be used to [reauthorize] future sessions between the 
  /// dApp and wallet endpoint.
  /// 
  /// DApp endpoints should make every effort possible to verify the authenticity of the presented 
  /// identity. While the uri parameter is optional, it is strongly recommended - without it, the 
  /// wallet endpoint may not be able to verify the authenticity of the dApp.
  /// 
  /// The cluster parameter allows the dApp endpoint to select a specific Solana cluster with which 
  /// to interact. This is relevant for both `sign_transactions`, where a wallet may refuse to sign 
  /// transactions without a currently valid blockhash, and for `sign_and_send_transactions`, where 
  /// the wallet endpoint must know which cluster to submit the transactions to. This parameter 
  /// would normally be used to select a cluster other than mainnet-beta for dApp development and 
  /// testing purposes. Under normal circumstances, this field should be omitted, in which case the 
  /// wallet endpoint will interact with the mainnet-beta cluster.
  Future<AuthorizeResult> authorize(final AuthorizeParams params) 
    => send(Method.authorize, params);

  /// Invoke [Method.deauthorize].
  ///
  /// This method will make the provided [DeauthorizeParams.authToken] invalid for use (if it ever 
  /// was valid). To avoid disclosure, this method will not indicate whether the auth token was 
  /// previously valid to the caller.
  /// 
  /// If, during the current session, the specified auth token was returned by the most recent call 
  /// to `authorize` or `reauthorize`, the session with be placed into the unauthorized state.
  Future<DeauthorizeResult> deauthorize(final DeauthorizeParams params)
    => send<DeauthorizeResult>(Method.deauthorize, params);

  /// Invoke [Method.reauthorize].
  /// 
  /// This method attempts to put the current session in an authorized state, with privileges 
  /// associated with the specified [ReauthorizeParams.authToken].
  /// 
  /// On success, the current session will be placed into an authorized state. Additionally, updated 
  /// values for auth token, accounts, and/or wallet_uri_base will be returned. These may differ 
  /// from those originally provided in the authorize response for this auth token; if so, they 
  /// override any previous values for these parameters. The prior values should be discarded and 
  /// not reused. This allows a wallet endpoint to update the auth token used by the dApp endpoint, 
  /// or to modify the set of authorized account addresses or their labels without requiring the 
  /// dApp endpoint to restart the authorization process.
  /// 
  /// If the result is [SolanaWalletAdapterProtocolExceptionCode.authorizationFailed], this 
  /// auth token cannot be reused, and should be discarded. The dApp endpoint should request a new 
  /// token with the authorize method. The session with be placed into the unauthorized state.
  Future<ReauthorizeResult> reauthorize(final ReauthorizeParams params) 
    => send<ReauthorizeResult>(Method.reauthorize, params);

  /// Invoke [Method.get_capabilities].
  ///
  /// This method can be used to fetch limits of a wallet endpoint’s implementation of the 
  /// specification. It returns whether optional specification features are supported, as well as 
  /// any implementation-specific limits.
  Future<GetCapabilitiesResult> getCapabilities() 
    => send<GetCapabilitiesResult>(Method.get_capabilities, const GetCapabilitiesParams());

  /// **********************************************************************************************
  /// {@template solana_wallet_adapter.privilegedMethods}
  /// Privileged methods
  /// 
  /// These methods require the current session to be in an `authorized` state to invoke them. For 
  /// details on how a session enters and exits an authorized state, see the non-privileged methods.
  /// {@endtemplate}
  /// **********************************************************************************************
  
  /// Invoke [Method.sign_transactions].
  /// 
  /// The wallet endpoint should attempt to simulate the transactions provided by 
  /// [SignTransactionsParams.payloads] and present them to the user for approval (if applicable). 
  /// If approved (or if it does not require approval), the wallet endpoint should sign the 
  /// transactions with the private keys for the requested authorized account addresses, and return 
  /// the signed transactions to the dApp endpoint.
  Future<SignTransactionsResult> signTransactions(final SignTransactionsParams params) 
    => send<SignTransactionsResult>(Method.sign_transactions, params);

  /// Invoke [Method.sign_and_send_transactions].
  /// 
  /// `Implementation of this method by a wallet endpoint is optional.`
  /// 
  /// The wallet endpoint should attempt to simulate the transactions provided by 
  /// [SignAndSendTransactionsParams.payloads] and present them to the user for approval (if 
  /// applicable). If approved (or if it does not require approval), the wallet endpoint should 
  /// verify the transactions, sign them with the private keys for the authorized addresses, submit 
  /// them to the network, and return the transaction signatures to the dApp endpoint.
  /// 
  /// The [SignAndSendTransactionsParams.options] allows customization of how the wallet endpoint 
  /// processes the transactions it sends to the Solana network. If specified, minContextSlot 
  /// specifies the minimum slot number that the transactions should be evaluated at. This allows 
  /// the wallet endpoint to wait for its network RPC node to reach the same point in time as the 
  /// node used by the dApp endpoint, ensuring that, e.g., the recent blockhash encoded in the 
  /// transactions will be available.
  Future<SignAndSendTransactionsResult> signAndSendTransactions(
    final SignAndSendTransactionsParams params,
  ) => send<SignAndSendTransactionsResult>(Method.sign_and_send_transactions, params);

  /// Invoke [Method.sign_messages].
  /// 
  /// The wallet endpoint should present the provided message [SignMessagesParams.payloads] for 
  /// approval. If approved, the wallet endpoint should sign the messages with the private key for 
  /// the authorized account address, and return the signed messages to the dApp endpoint. The 
  /// signatures should be appended to the message, in the same order as addresses.
  Future<SignMessagesResult> signMessages(final SignMessagesParams params) 
    => send<SignMessagesResult>(Method.sign_messages, params);

  /// Invoke [Method.clone_authorization].
  /// 
  /// `Implementation of this method by a wallet endpoint is optional.`
  /// 
  /// This method attempts to clone the session’s currently active authorization in a form suitable 
  /// for sharing with another instance of the dApp endpoint, possibly running on a different 
  /// system. Whether or not the wallet endpoint supports cloning an auth token is an implementation 
  /// detail. If this method succeeds, it will return an auth token appropriate for sharing with 
  /// another instance of the same dApp endpoint.
  /// 
  /// The clone_authorization method enables sharing of an authorization between related instances 
  /// of a dapp endpoint (for example, running on a mobile device and a desktop OS). This is a 
  /// sensitive operation; dapp endpoints must endeavor to transfer the token securely between dApp 
  /// endpoint instances. The ability of wallet endpoints to validate the identity of the holder of 
  /// the cloned token is an implementation detail, and may be weaker than that of the original 
  /// token. As such, not all wallet endpoints are expected to support this feature.
  Future<CloneAuthorizationResult> cloneAuthorization() 
    => send<CloneAuthorizationResult>(Method.clone_authorization, const CloneAuthorizationParams());
}