// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TokenStore on _TokenStore, Store {
  Computed<bool>? _$isLoggedInComputed;

  @override
  bool get isLoggedIn => (_$isLoggedInComputed ??= Computed<bool>(
    () => super.isLoggedIn,
    name: '_TokenStore.isLoggedIn',
  )).value;

  late final _$tokenAtom = Atom(name: '_TokenStore.token', context: context);

  @override
  String? get token {
    _$tokenAtom.reportRead();
    return super.token;
  }

  @override
  set token(String? value) {
    _$tokenAtom.reportWrite(value, super.token, () {
      super.token = value;
    });
  }

  late final _$setTokenAsyncAction = AsyncAction(
    '_TokenStore.setToken',
    context: context,
  );

  @override
  Future<void> setToken(String? value, {String? refresh}) {
    return _$setTokenAsyncAction.run(
      () => super.setToken(value, refresh: refresh),
    );
  }

  late final _$clearAsyncAction = AsyncAction(
    '_TokenStore.clear',
    context: context,
  );

  @override
  Future<void> clear() {
    return _$clearAsyncAction.run(() => super.clear());
  }

  @override
  String toString() {
    return '''
token: ${token},
isLoggedIn: ${isLoggedIn}
    ''';
  }
}
