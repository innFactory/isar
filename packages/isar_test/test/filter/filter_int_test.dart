import 'package:isar/isar.dart';
import 'package:test/test.dart';

import '../util/common.dart';
import '../util/sync_async_helper.dart';

part 'filter_int_test.g.dart';

@Collection()
class IntModel {
  IntModel(this.field);

  Id? id;

  short? field = 0;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is IntModel && other.field == field;
  }
}

void main() {
  group('Int filter', () {
    late Isar isar;
    late IsarCollection<IntModel> col;

    late IntModel obj0;
    late IntModel obj1;
    late IntModel obj2;
    late IntModel obj3;
    late IntModel objNull;

    setUp(() async {
      isar = await openTempIsar([IntModelSchema]);
      col = isar.intModels;

      objNull = IntModel(null);
      obj0 = IntModel(-1234);
      obj1 = IntModel(1);
      obj2 = IntModel(2);
      obj3 = IntModel(1);

      await isar.writeTxn(() async {
        await isar.intModels.putAll([obj0, obj1, obj2, obj3, objNull]);
      });
    });

    isarTest('.equalTo()', () async {
      await qEqual(col.filter().fieldEqualTo(2).tFindAll(), [obj2]);
      await qEqual(col.filter().fieldEqualTo(null).tFindAll(), [objNull]);
      await qEqual(col.filter().fieldEqualTo(5).tFindAll(), []);
    });

    isarTest('.greaterThan()', () async {
      await qEqual(col.filter().fieldGreaterThan(1).tFindAll(), [obj2]);
      await qEqual(
        col.filter().fieldGreaterThan(1, include: true).tFindAll(),
        [obj1, obj2, obj3],
      );
      await qEqualSet(
        col.filter().fieldGreaterThan(null).tFindAll(),
        [obj0, obj1, obj2, obj3],
      );
      await qEqualSet(
        col.filter().fieldGreaterThan(null, include: true).tFindAll(),
        [obj0, obj1, obj2, obj3, objNull],
      );
      await qEqualSet(col.filter().fieldGreaterThan(4).tFindAll(), []);
    });

    isarTest('.lessThan()', () async {
      await qEqual(col.filter().fieldLessThan(1).tFindAll(), [obj0, objNull]);
      await qEqualSet(col.filter().fieldLessThan(null).tFindAll(), []);
      await qEqualSet(
        col.filter().fieldLessThan(null, include: true).tFindAll(),
        [objNull],
      );
    });

    isarTest('.between()', () async {
      await qEqual(
        col.filter().fieldBetween(1, 2).tFindAll(),
        [obj1, obj2, obj3],
      );
      await qEqual(
        col.filter().fieldBetween(1, 2, includeLower: false).tFindAll(),
        [obj2],
      );
      await qEqual(
        col.filter().fieldBetween(1, 2, includeUpper: false).tFindAll(),
        [obj1, obj3],
      );
      await qEqual(
        col
            .filter()
            .fieldBetween(1, 2, includeLower: false, includeUpper: false)
            .tFindAll(),
        [],
      );
      await qEqual(
        col.filter().fieldBetween(null, 1).tFindAll(),
        [obj0, obj1, obj3, objNull],
      );
      await qEqual(col.filter().fieldBetween(5, 6).tFindAll(), []);
    });

    isarTest('.isNull() / .isNotNull()', () async {
      await qEqual(col.filter().fieldIsNull().tFindAll(), [objNull]);
    });
  });
}
