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
    final encoded = excel.encode();
    expect(encoded, isNotNull);
  });
}
