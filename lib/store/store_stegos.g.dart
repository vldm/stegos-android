// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_stegos.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$StegosStore on _StegosStore, Store {
  Computed<bool> _$needWelcomeComputed;

  @override
  bool get needWelcome =>
      (_$needWelcomeComputed ??= Computed<bool>(() => super.needWelcome)).value;

  final _$activateAsyncAction = AsyncAction('activate');

  @override
  Future<void> activate() {
    return _$activateAsyncAction.run(() => super.activate());
  }

  final _$_StegosStoreActionController = ActionController(name: '_StegosStore');

  @override
  void _updateLastRoute(RouteSettings settings) {
    final _$actionInfo = _$_StegosStoreActionController.startAction();
    try {
      return super._updateLastRoute(settings);
    } finally {
      _$_StegosStoreActionController.endAction(_$actionInfo);
    }
  }
}
