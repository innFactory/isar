import 'dart:typed_data';

import 'package:isar/isar.dart';
import 'package:test/test.dart';

import '../type_models.dart';
import '../util/common.dart';
import '../util/sync_async_helper.dart';

void main() {
  group('Query property', () {
    late Isar isar;

    setUp(() async {
      isar = await openTempIsar([
        BoolModelSchema,
        ByteModelSchema,
        ShortModelSchema,
        IntModelSchema,
        FloatModelSchema,
        DoubleModelSchema,
        DateTimeModelSchema,
        StringModelSchema,
        EnumModelSchema,
        ObjectModelSchema,
      ]);
    });

    isarTest('id property', () async {
      await isar.tWriteTxn(
        () => isar.boolModels.tPutAll([
          BoolModel(),
          BoolModel(),
          BoolModel(),
        ]),
      );

      await qEqual(
        isar.boolModels.where().idProperty().tFindAll(),
        [1, 2, 3],
      );
    });

    isarTest('bool property', () async {
      await isar.tWriteTxn(
        () => isar.boolModels.tPutAll([
          BoolModel()
            ..value = true
            ..nValue = false,
          BoolModel()
            ..value = false
            ..nValue = true,
          BoolModel()..value = true,
        ]),
      );

      await qEqual(
        isar.boolModels.where().valueProperty().tFindAll(),
        [true, false, true],
      );

      await qEqual(
        isar.boolModels.where().nValueProperty().tFindAll(),
        [false, true, null],
      );
    });

    isarTest('byte property', () async {
      await isar.tWriteTxn(
        () => isar.byteModels.tPutAll([
          ByteModel()..value = 5,
          ByteModel()..value = 123,
          ByteModel()..value = 0,
        ]),
      );

      await qEqual(
        isar.byteModels.where().valueProperty().tFindAll(),
        [5, 123, 0],
      );
    });

    isarTest('short property', () async {
      await isar.tWriteTxn(
        () => isar.shortModels.tPutAll([
          ShortModel()
            ..value = 1234
            ..nValue = 55,
          ShortModel()..value = 444,
          ShortModel()
            ..value = 321321
            ..nValue = 1,
        ]),
      );

      await qEqual(
        isar.shortModels.where().valueProperty().tFindAll(),
        [1234, 444, 321321],
      );

      await qEqual(
        isar.shortModels.where().nValueProperty().tFindAll(),
        [55, null, 1],
      );
    });

    isarTest('int property', () async {
      await isar.tWriteTxn(
        () => isar.intModels.tPutAll([
          IntModel()
            ..value = -5
            ..nValue = -99999,
          IntModel()
            ..value = Isar.autoIncrement
            ..nValue = 0,
          IntModel()..value = 9999,
        ]),
      );

      await qEqual(
        isar.intModels.where().valueProperty().tFindAll(),
        [-5, Isar.autoIncrement, 9999],
      );

      await qEqual(
        isar.intModels.where().nValueProperty().tFindAll(),
        [-99999, 0, null],
      );
    });

    isarTest('float property', () async {
      await isar.tWriteTxn(
        () => isar.floatModels.tPutAll([
          FloatModel()
            ..value = -5.5
            ..nValue = double.infinity,
          FloatModel()..value = 70.7,
          FloatModel()
            ..value = double.nan
            ..nValue = double.negativeInfinity,
        ]),
      );

      await qEqual(
        isar.floatModels.where().valueProperty().tFindAll(),
        [-5.5, 70.7, double.nan],
      );

      await qEqual(
        isar.floatModels.where().nValueProperty().tFindAll(),
        [double.infinity, null, double.negativeInfinity],
      );
    });

    isarTest('double property', () async {
      await isar.tWriteTxn(
        () => isar.doubleModels.tPutAll([
          DoubleModel()
            ..value = -5.5
            ..nValue = double.infinity,
          DoubleModel()..value = 70.7,
          DoubleModel()
            ..value = double.nan
            ..nValue = double.negativeInfinity,
        ]),
      );

      await qEqual(
        isar.doubleModels.where().valueProperty().tFindAll(),
        [-5.5, 70.7, double.nan],
      );

      await qEqual(
        isar.doubleModels.where().nValueProperty().tFindAll(),
        [double.infinity, null, double.negativeInfinity],
      );
    });

    isarTest('DateTime property', () async {
      await isar.tWriteTxn(
        () => isar.dateTimeModels.tPutAll([
          DateTimeModel()..value = DateTime(2022),
          DateTimeModel()
            ..value = DateTime(2020)
            ..nValue = DateTime(2010),
          DateTimeModel()..value = DateTime(1999),
        ]),
      );

      await qEqual(
        isar.dateTimeModels.where().valueProperty().tFindAll(),
        [DateTime(2022), DateTime(2020), DateTime(1999)],
      );

      await qEqual(
        isar.dateTimeModels.where().nValueProperty().tFindAll(),
        [null, DateTime(2010), null],
      );
    });

    isarTest('String property', () async {
      await isar.tWriteTxn(
        () => isar.stringModels.tPutAll([
          StringModel()
            ..value = 'Just'
            ..nValue = 'A',
          StringModel()..value = 'a',
          StringModel()
            ..value = 'test'
            ..nValue = 'Z',
        ]),
      );

      await qEqual(
        isar.stringModels.where().valueProperty().tFindAll(),
        ['Just', 'a', 'test'],
      );

      await qEqual(
        isar.stringModels.where().nValueProperty().tFindAll(),
        ['A', null, 'Z'],
      );
    });

    isarTest('Object property', () async {
      await isar.tWriteTxn(
        () => isar.objectModels.tPutAll([
          ObjectModel()
            ..value = EmbeddedModel('E1')
            ..nValue = EmbeddedModel('XXX'),
          ObjectModel()
            ..value = EmbeddedModel('E2')
            ..nValue = EmbeddedModel('YYY'),
          ObjectModel()..value = EmbeddedModel('E3'),
        ]),
      );

      await qEqual(
        isar.objectModels.where().valueProperty().tFindAll(),
        [EmbeddedModel('E1'), EmbeddedModel('E2'), EmbeddedModel('E3')],
      );

      await qEqual(
        isar.objectModels.where().nValueProperty().tFindAll(),
        [EmbeddedModel('XXX'), EmbeddedModel('YYY'), null],
      );
    });

    isarTest('Enum property', () async {
      await isar.tWriteTxn(
        () => isar.enumModels.tPutAll([
          EnumModel()..value = TestEnum.option2,
          EnumModel()
            ..value = TestEnum.option3
            ..nValue = TestEnum.option3,
          EnumModel()..value = TestEnum.option2,
        ]),
      );

      await qEqual(
        isar.enumModels.where().valueProperty().tFindAll(),
        [TestEnum.option2, TestEnum.option3, TestEnum.option2],
      );

      await qEqual(
        isar.enumModels.where().nValueProperty().tFindAll(),
        [null, TestEnum.option3, null],
      );
    });

    isarTest('bool list property', () async {
      await isar.tWriteTxn(
        () => isar.boolModels.tPutAll([
          BoolModel()
            ..list = [true, false, true]
            ..nList = [false],
          BoolModel()..list = [],
          BoolModel()
            ..list = [true]
            ..nList = [],
        ]),
      );

      await qEqual(isar.boolModels.where().listProperty().tFindAll(), [
        [true, false, true],
        <bool>[],
        [true]
      ]);

      await qEqual(isar.boolModels.where().nListProperty().tFindAll(), [
        [false],
        null,
        <bool>[],
      ]);
    });

    isarTest('byte list property', () async {
      await isar.tWriteTxn(
        () => isar.byteModels.tPutAll([
          ByteModel()..list = Uint8List.fromList([0, 10, 255]),
          ByteModel()
            ..list = []
            ..nList = [1, 2, 3, 4, 5],
          ByteModel()..list = [3],
        ]),
      );

      await qEqual(
        isar.byteModels.where().listProperty().tFindAll(),
        [
          Uint8List.fromList([0, 10, 255]),
          Uint8List.fromList([]),
          Uint8List.fromList([3])
        ],
      );

      await qEqual(
        isar.byteModels.where().nListProperty().tFindAll(),
        [
          null,
          Uint8List.fromList([1, 2, 3, 4, 5]),
          null
        ],
      );
    });

    isarTest('short list property', () async {
      await isar.tWriteTxn(
        () => isar.shortModels.tPutAll([
          ShortModel()
            ..list = [-5, 70, 999]
            ..nList = [],
          ShortModel()
            ..list = []
            ..nList = [1, 2, 3],
          ShortModel()..list = [0],
        ]),
      );

      await qEqual(isar.shortModels.where().listProperty().tFindAll(), [
        [-5, 70, 999],
        <int>[],
        [0],
      ]);

      await qEqual(isar.shortModels.where().nListProperty().tFindAll(), [
        <int>[],
        [1, 2, 3],
        null,
      ]);
    });

    isarTest('int list property', () async {
      await isar.tWriteTxn(
        () => isar.intModels.tPutAll([
          IntModel()
            ..list = [-5, 70, 999]
            ..nList = [],
          IntModel()
            ..list = []
            ..nList = [1, 2, 3],
          IntModel()..list = [0],
        ]),
      );

      await qEqual(isar.intModels.where().listProperty().tFindAll(), [
        [-5, 70, 999],
        <int>[],
        [0],
      ]);

      await qEqual(isar.intModels.where().nListProperty().tFindAll(), [
        <int>[],
        [1, 2, 3],
        null,
      ]);
    });

    isarTest('float list property', () async {
      await isar.tWriteTxn(
        () => isar.floatModels.tPutAll([
          FloatModel()
            ..list = [-5.5, 70.7, 999.999]
            ..nList = [double.infinity],
          FloatModel()..list = [],
          FloatModel()
            ..list = [0.0]
            ..nList = [double.maxFinite],
        ]),
      );

      await qEqual(isar.floatModels.where().listProperty().tFindAll(), [
        [-5.5, 70.7, 999.999],
        <double>[],
        [0.0]
      ]);

      await qEqual(isar.floatModels.where().nListProperty().tFindAll(), [
        [double.infinity],
        null,
        [double.maxFinite]
      ]);
    });

    isarTest('double list property', () async {
      await isar.tWriteTxn(
        () => isar.doubleModels.tPutAll([
          DoubleModel()
            ..list = [-5.5, 70.7, 999.999]
            ..nList = [double.infinity],
          DoubleModel()..list = [],
          DoubleModel()
            ..list = [0.0]
            ..nList = [double.maxFinite],
        ]),
      );

      await qEqual(isar.doubleModels.where().listProperty().tFindAll(), [
        [-5.5, 70.7, 999.999],
        <double>[],
        [0.0]
      ]);

      await qEqual(isar.doubleModels.where().nListProperty().tFindAll(), [
        [double.infinity],
        null,
        [double.maxFinite]
      ]);
    });

    isarTest('DateTime list property', () async {
      await isar.tWriteTxn(
        () => isar.dateTimeModels.tPutAll([
          DateTimeModel()
            ..list = [DateTime(2019), DateTime(2020)]
            ..nList = [DateTime(2000), DateTime(2001)],
          DateTimeModel()
            ..list = [DateTime(2020)]
            ..nList = [DateTime(2000)],
          DateTimeModel()..list = [],
        ]),
      );

      await qEqual(isar.dateTimeModels.where().listProperty().tFindAll(), [
        [DateTime(2019), DateTime(2020)],
        [DateTime(2020)],
        <DateTime>[]
      ]);

      await qEqual(isar.dateTimeModels.where().nListProperty().tFindAll(), [
        [DateTime(2000), DateTime(2001)],
        [DateTime(2000)],
        null,
      ]);
    });

    isarTest('String list property', () async {
      await isar.tWriteTxn(
        () => isar.stringModels.tPutAll([
          StringModel()..list = ['Just', 'a', 'test'],
          StringModel()..list = [],
          StringModel()
            ..list = ['']
            ..nList = ['HELLO'],
        ]),
      );

      await qEqual(
        isar.stringModels.where().listProperty().tFindAll(),
        [
          ['Just', 'a', 'test'],
          <String>[],
          ['']
        ],
      );

      await qEqual(
        isar.stringModels.where().nListProperty().tFindAll(),
        [
          null,
          null,
          ['HELLO']
        ],
      );
    });

    isarTest('Object list property', () async {
      await isar.tWriteTxn(
        () => isar.objectModels.tPutAll([
          ObjectModel()
            ..list = []
            ..nList = [EmbeddedModel('abc'), EmbeddedModel('def')],
          ObjectModel()..list = [EmbeddedModel('abc'), EmbeddedModel('def')],
          ObjectModel()
            ..list = [EmbeddedModel()]
            ..nList = [EmbeddedModel()],
        ]),
      );

      await qEqual(
        isar.objectModels.where().listProperty().tFindAll(),
        [
          <EmbeddedModel>[],
          [EmbeddedModel('abc'), EmbeddedModel('def')],
          [EmbeddedModel()]
        ],
      );

      await qEqual(
        isar.objectModels.where().nListProperty().tFindAll(),
        [
          [EmbeddedModel('abc'), EmbeddedModel('def')],
          null,
          [EmbeddedModel()]
        ],
      );
    });

    isarTest('Enum list property', () async {
      await isar.tWriteTxn(
        () => isar.enumModels.tPutAll([
          EnumModel()
            ..list = [TestEnum.option2]
            ..nList = [TestEnum.option2, TestEnum.option3],
          EnumModel()..list = [TestEnum.option1],
          EnumModel()..list = [],
        ]),
      );

      await qEqual(
        isar.enumModels.where().listProperty().tFindAll(),
        [
          [TestEnum.option2],
          [TestEnum.option1],
          <TestEnum>[]
        ],
      );

      await qEqual(
        isar.enumModels.where().nListProperty().tFindAll(),
        [
          [TestEnum.option2, TestEnum.option3],
          null,
          null
        ],
      );
    });
  });
}
