import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/core/security/secure_store.dart';

void main() {
  test('InMemorySecureStore supports read/write/delete', () async {
    final store = InMemorySecureStore();

    expect(await store.read('k'), isNull);

    await store.write('k', 'v');
    expect(await store.read('k'), 'v');

    await store.delete('k');
    expect(await store.read('k'), isNull);

    await store.write('a', '1');
    await store.write('b', '2');
    await store.deleteAll();
    expect(await store.read('a'), isNull);
    expect(await store.read('b'), isNull);
  });
}
