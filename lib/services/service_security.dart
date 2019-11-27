import 'dart:convert';
import 'dart:math' as Math;

import 'package:mobx/mobx.dart';
import 'package:random_string/random_string.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';
import 'package:stegos_wallet/ui/pinprotect/screen_pin_protect.dart';
import 'package:stegos_wallet/utils/crypto.dart';
import 'package:stegos_wallet/utils/crypto_aes.dart';
import 'package:stegos_wallet/utils/dialogs.dart';

part 'service_security.g.dart';

class SecurityService extends _SecurityService with _$SecurityService {
  SecurityService(StegosEnv env) : super(env);
}

/// Varios security related utility methods.
///
abstract class _SecurityService with Store, Loggable<SecurityService> {
  _SecurityService(this.env) : _provider = _RandomStringProvider();

  final StegosEnv env;

  final _RandomStringProvider _provider;

  StegosStore get store => env.store;

  /// User has pin protected password
  @computed
  bool get hasPinProtectedPassword => store.settings['password'] != null;

  @observable
  String _cachedAccountPassword;

  bool get needAppUnlock => !(_cachedAccountPassword != null &&
      DateTime.now().millisecondsSinceEpoch - (store.settings['lastAppUnlockTs'] as int ?? 0) <
          env.configMaxAppUnlockedPeriod);

  Future<void> checkAppPin() => acquirePasswordForAccount(forceUnlock: true);

  Future<String> acquirePasswordForAccount({int accountId, bool forceUnlock = false}) async {
    if (!hasPinProtectedPassword) {
      final password =
          await appShowDialog<String>(builder: (context) => const PinProtectScreen(unlock: false));
      runInAction(() {
        _cachedAccountPassword = password;
      });
      return _cachedAccountPassword;
    } else if (forceUnlock || needAppUnlock) {
      final password =
          await appShowDialog<String>(builder: (context) => const PinProtectScreen(unlock: true));
      runInAction(() {
        _cachedAccountPassword = password;
      });
      return _cachedAccountPassword;
    } else {
      return _cachedAccountPassword;
    }
  }

  /// Create new random generated password
  String createRandomPassword() =>
      randomAlphaNumeric(env.configGeneratedPasswordsLength, provider: _provider);

  Future<String> setupAccountPassword(String pw, String pin) => env.useDb((db) async {
        const utf8Encoder = Utf8Encoder();
        final key = base64Encode(utf8Encoder.convert(pin.padRight(32, '@')));
        final iv = const StegosCryptKey().genDartRaw(16);
        final encyptedPassword =
            StegosAesCrypt(key).encrypt(utf8Encoder.convert('stegos:${pw}'), iv);
        await store.mergeSettings({
          'password': base64Encode(encyptedPassword),
          'iv': base64Encode(iv),
          'lastAppUnlockTs': DateTime.now().millisecondsSinceEpoch
        });
        return pw;
      });

  /// Recover pin protected password.
  Future<String> recoverAccountPassword(String pin) async {
    const utf8Encoder = Utf8Encoder();
    const utf8Decoder = Utf8Decoder();

    final key = base64Encode(utf8Encoder.convert(pin.padRight(32, '@')));
    final iv = store.settings['iv'] as String;
    final password = store.settings['password'] as String;
    if (password == null || iv == null) {
      return Future.error(Exception('Invalid password recover data'));
    }
    var pw = utf8Decoder.convert(StegosAesCrypt(key).decrypt(base64Decode(password), iv));
    if (!pw.startsWith('stegos:')) {
      return Future.error(Exception('Invalid password recovered'));
    }
    pw = pw.substring('stegos:'.length);
    runInAction(() {
      _cachedAccountPassword = pw;
    });
    return _touchAppUnlockedPeriod().then((_) => pw);
  }

  Future<void> _touchAppUnlockedPeriod({int touchTs}) =>
      store.mergeSingle('lastAppUnlockTs', touchTs ?? DateTime.now().millisecondsSinceEpoch);
}

class _RandomStringProvider implements Provider {
  _RandomStringProvider() : _random = Math.Random.secure();

  final Math.Random _random;

  @override
  double nextDouble() => _random.nextDouble();
}
