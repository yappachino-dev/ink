// This is a generated file - do not edit.
//
// Generated from vault/v1/vault.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'vault.pb.dart' as $0;

export 'vault.pb.dart';

@$pb.GrpcServiceName('vault.v1.VaultService')
class VaultServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  VaultServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GetKeySlotsResponse> getKeySlots(
    $0.GetKeySlotsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getKeySlots, request, options: options);
  }

  $grpc.ResponseFuture<$0.SaveKeySlotsResponse> saveKeySlots(
    $0.SaveKeySlotsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$saveKeySlots, request, options: options);
  }

  // method descriptors

  static final _$getKeySlots =
      $grpc.ClientMethod<$0.GetKeySlotsRequest, $0.GetKeySlotsResponse>(
          '/vault.v1.VaultService/GetKeySlots',
          ($0.GetKeySlotsRequest value) => value.writeToBuffer(),
          $0.GetKeySlotsResponse.fromBuffer);
  static final _$saveKeySlots =
      $grpc.ClientMethod<$0.SaveKeySlotsRequest, $0.SaveKeySlotsResponse>(
          '/vault.v1.VaultService/SaveKeySlots',
          ($0.SaveKeySlotsRequest value) => value.writeToBuffer(),
          $0.SaveKeySlotsResponse.fromBuffer);
}

@$pb.GrpcServiceName('vault.v1.VaultService')
abstract class VaultServiceBase extends $grpc.Service {
  $core.String get $name => 'vault.v1.VaultService';

  VaultServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.GetKeySlotsRequest, $0.GetKeySlotsResponse>(
            'GetKeySlots',
            getKeySlots_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetKeySlotsRequest.fromBuffer(value),
            ($0.GetKeySlotsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SaveKeySlotsRequest, $0.SaveKeySlotsResponse>(
            'SaveKeySlots',
            saveKeySlots_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SaveKeySlotsRequest.fromBuffer(value),
            ($0.SaveKeySlotsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetKeySlotsResponse> getKeySlots_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetKeySlotsRequest> $request) async {
    return getKeySlots($call, await $request);
  }

  $async.Future<$0.GetKeySlotsResponse> getKeySlots(
      $grpc.ServiceCall call, $0.GetKeySlotsRequest request);

  $async.Future<$0.SaveKeySlotsResponse> saveKeySlots_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SaveKeySlotsRequest> $request) async {
    return saveKeySlots($call, await $request);
  }

  $async.Future<$0.SaveKeySlotsResponse> saveKeySlots(
      $grpc.ServiceCall call, $0.SaveKeySlotsRequest request);
}
