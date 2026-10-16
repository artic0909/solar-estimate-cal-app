import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Excel creation and append row works', () {
    var excel = Excel.createExcel();
    var sheet = excel['Data'];
    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Mobile No.'),
      IntCellValue(10),
      DoubleCellValue(78.1),
    ]);

    expect(sheet.rows.length, equals(1));
    final encoded = excel.encode()!;
    expect(encoded, isNotNull);

    var decoded = Excel.decodeBytes(encoded);
    var sheet2 = decoded['Data'];
    expect(sheet2.rows.length, equals(1));
    sheet2.appendRow([
      TextCellValue('Customer 2'),
      TextCellValue('9876543210'),
      IntCellValue(20),
      DoubleCellValue(99.5),
    ]);
    expect(sheet2.rows.length, equals(2));
  });
}
