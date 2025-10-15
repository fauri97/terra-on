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

  late final _$userIdAtom = Atom(name: '_TokenStore.userId', context: context);

  @override
  int? get userId {
    _$userIdAtom.reportRead();
    return super.userId;
  }

  @override
  set userId(int? value) {
    _$userIdAtom.reportWrite(value, super.userId, () {
      super.userId = value;
    });
  }

  late final _$userNameAtom = Atom(
    name: '_TokenStore.userName',
    context: context,
  );

  @override
  String? get userName {
    _$userNameAtom.reportRead();
    return super.userName;
  }

  @override
  set userName(String? value) {
    _$userNameAtom.reportWrite(value, super.userName, () {
      super.userName = value;
    });
  }

  late final _$userEmailAtom = Atom(
    name: '_TokenStore.userEmail',
    context: context,
  );

  @override
  String? get userEmail {
    _$userEmailAtom.reportRead();
    return super.userEmail;
  }

  @override
  set userEmail(String? value) {
    _$userEmailAtom.reportWrite(value, super.userEmail, () {
      super.userEmail = value;
    });
  }

  late final _$initAsyncAction = AsyncAction(
    '_TokenStore.init',
    context: context,
  );

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
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

  late final _$setSessionAsyncAction = AsyncAction(
    '_TokenStore.setSession',
    context: context,
  );

  @override
  Future<void> setSession({
    required String accessToken,
    String refreshToken = '',
    required int id,
    required String name,
    required String email,
  }) {
    return _$setSessionAsyncAction.run(
      () => super.setSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        id: id,
        name: name,
        email: email,
      ),
    );
  }

  late final _$setProfileAsyncAction = AsyncAction(
    '_TokenStore.setProfile',
    context: context,
  );

  @override
  Future<void> setProfile({
    required int id,
    required String name,
    required String email,
  }) {
    return _$setProfileAsyncAction.run(
      () => super.setProfile(id: id, name: name, email: email),
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
userId: ${userId},
userName: ${userName},
userEmail: ${userEmail},
isLoggedIn: ${isLoggedIn}
    ''';
  }
}
