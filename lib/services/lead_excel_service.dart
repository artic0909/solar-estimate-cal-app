import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/solar_input.dart';
import '../models/solar_result.dart';

class LeadExcelService {
  static const String fileName = 'Websol_Leads.xlsx';
  static const String sheetName = 'Data';

  static const List<String> headers = [
    'Name',
    'Mobile No.',
    'Email',
    'State/UT',
    'Monthly Bill (Rs.)',
    'Solar Application',
    'Installation Type',
    'Fan',
    'Light',
    'TV',
    'AC',
    'Washing machine',
    'Fridge',
    'Electric kettle',
    'Induction cooker',
    'Submersible pump',
    'Geyser',
    'Other Load (Watt)',
    'Bill Reduction %',
    'Monthly Savings (Rs.)',
    'Revised Bill (Rs.)',
    'Space Required (sq. m)',
    'No. of Modules',
    'Approx. Cost (Rs.)',
    'Subsidy (Rs.)',
    'Effective Cost (Rs.)',
    'Coal Saved (MT)',
    'CO2 Reduction (MT)',
    'Trees Equivalent',
    'Timestamp',
  ];

  static Future<Directory> _resolveDirectory() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return dir;
    } catch (e) {
      if (!kIsWeb && Platform.isAndroid) {
        final fallback = Directory('/data/user/0/com.websol.solar_estimate_calculator/app_flutter');
        if (await fallback.exists()) return fallback;
      }
      return Directory.current;
    }
  }

  static Future<File> getExcelFile() async {
    final dir = await _resolveDirectory();
    return File('${dir.path}/$fileName');
  }

  /// Appends one lead entry to the Websol_Leads.xlsx file on tablet local storage.
  /// Creates the workbook and header row if the file does not already exist.
  static Future<File> saveLead({
    required SolarInput input,
    required SolarResult result,
  }) async {
    final file = await getExcelFile();
    Excel excel;

    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      excel = Excel.decodeBytes(bytes);
    } else {
      excel = Excel.createExcel();
      // Remove default sheet if present and not named sheetName
      if (excel.sheets.containsKey('Sheet1') && sheetName != 'Sheet1') {
        excel.delete('Sheet1');
      }
    }

    final Sheet sheet = excel[sheetName];

    // If empty or brand new sheet, write the header row
    if (sheet.maxRows == 0) {
      sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
    }

    final billReductionStr = result.isSurplus
        ? SolarResult.surplusBillReductionMessage
        : '${(result.billReduction! * 100.0).toStringAsFixed(1)}%';

    final revisedBillStr = result.isSurplus
        ? SolarResult.surplusRevisedBillMessage
        : result.revisedBill!.round().toString();

    final row = <CellValue>[
      TextCellValue(input.name.trim().isEmpty ? '0' : input.name.trim()),
      TextCellValue(input.mobile.trim().isEmpty ? '0' : input.mobile.trim()),
      TextCellValue(input.email.trim()),
      TextCellValue(input.state),
      DoubleCellValue(input.monthlyBill),
      TextCellValue(input.solarApplication),
      TextCellValue(input.installationType),
      IntCellValue(input.counts['fan'] ?? 0),
      IntCellValue(input.counts['light'] ?? 0),
      IntCellValue(input.counts['tv'] ?? 0),
      IntCellValue(input.counts['ac'] ?? 0),
      IntCellValue(input.counts['washing'] ?? 0),
      IntCellValue(input.counts['fridge'] ?? 0),
      IntCellValue(input.counts['kettle'] ?? 0),
      IntCellValue(input.counts['induction'] ?? 0),
      IntCellValue(input.counts['pump'] ?? 0),
      IntCellValue(input.counts['geyser'] ?? 0),
      IntCellValue(input.otherWatts),
      TextCellValue(billReductionStr),
      DoubleCellValue(result.monthlySaving),
      TextCellValue(revisedBillStr),
      DoubleCellValue(result.spaceM2),
      IntCellValue(result.modules),
      DoubleCellValue(result.cost),
      DoubleCellValue(result.subsidy),
      DoubleCellValue(result.effectiveCost),
      DoubleCellValue(result.coalMT),
      DoubleCellValue(result.co2MT),
      IntCellValue(result.trees.round()),
      TextCellValue(DateTime.now().toIso8601String()),
    ];

    sheet.appendRow(row);

    final encodedBytes = excel.encode();
    if (encodedBytes != null) {
      // 1. Write to internal app docs
      await file.writeAsBytes(encodedBytes, flush: true);

      // 2. On Android, copy to public Download and external storage folders so user can see it in Files/Downloads
      if (!kIsWeb && Platform.isAndroid) {
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            final downloadFile = File('${downloadDir.path}/$fileName');
            await downloadFile.writeAsBytes(encodedBytes, flush: true);
          }
        } catch (e) {
          debugPrint('Failed to write to public Download folder: $e');
        }

        try {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null && await extDir.exists()) {
            final extFile = File('${extDir.path}/$fileName');
            await extFile.writeAsBytes(encodedBytes, flush: true);
          }
        } catch (e) {
          debugPrint('Failed to write to external app folder: $e');
        }

        try {
          final docDir = Directory('/storage/emulated/0/Documents');
          if (await docDir.exists()) {
            final docFile = File('${docDir.path}/$fileName');
            await docFile.writeAsBytes(encodedBytes, flush: true);
          }
        } catch (e) {
          debugPrint('Failed to write to public Documents folder: $e');
        }
      }
    }

    return file;
  }

  /// User-friendly path description for UI SnackBar
  static Future<String> getPublicSavedPathDescription() async {
    if (!kIsWeb && Platform.isAndroid) {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        return 'Tablet Downloads / Websol_Leads.xlsx';
      }
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        return '${extDir.path}/$fileName';
      }
    }
    final file = await getExcelFile();
    return file.path;
  }

  /// Exports or shares the Websol_Leads.xlsx file using native sharing sheet
  static Future<bool> shareLeadsFile() async {
    File fileToShare = await getExcelFile();
    if (!kIsWeb && Platform.isAndroid) {
      final downloadFile = File('/storage/emulated/0/Download/$fileName');
      if (await downloadFile.exists()) {
        fileToShare = downloadFile;
      }
    }
    if (await fileToShare.exists()) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(fileToShare.path)],
          subject: 'Websol Solar Leads Export',
          text: 'Attached is the Websol Leads spreadsheet from the solar calculator tablet.',
        ),
      );
      return true;
    }
    return false;
  }

  /// Check if leads file exists and how many leads have been saved
  static Future<int> getSavedLeadsCount() async {
    final file = await getExcelFile();
    if (!await file.exists()) return 0;
    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel[sheetName];
      return (sheet.maxRows > 1) ? sheet.maxRows - 1 : 0;
    } catch (_) {
      return 0;
    }
  }
}
