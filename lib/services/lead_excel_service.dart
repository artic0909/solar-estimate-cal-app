import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/solar_input.dart';
import '../models/solar_result.dart';

class LeadExcelService {
  static const String fileName = 'Websol_Leads.xlsx';
  static const String csvFileName = 'Websol_Leads.csv';
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

  static Future<File> getCsvFile() async {
    final dir = await _resolveDirectory();
    return File('${dir.path}/$csvFileName');
  }

  static String _escapeCsv(dynamic val) {
    if (val == null) return '';
    final s = val.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _buildCsvRow(List<dynamic> values) {
    return values.map(_escapeCsv).join(',') + '\n';
  }

  static Future<void> _appendCsvToFile(File file, List<dynamic> values) async {
    try {
      if (!await file.exists()) {
        final headerLine = headers.map(_escapeCsv).join(',') + '\n';
        await file.writeAsString(headerLine, flush: true);
      }
      final rowLine = _buildCsvRow(values);
      await file.writeAsString(rowLine, mode: FileMode.append, flush: true);
    } catch (e) {
      debugPrint('Error writing CSV to ${file.path}: $e');
    }
  }

  /// Appends one lead entry to Websol_Leads.xlsx and Websol_Leads.csv.
  static Future<File> saveLead({
    required SolarInput input,
    required SolarResult result,
  }) async {
    final file = await getExcelFile();
    Excel excel;

    if (await file.exists()) {
      try {
        final bytes = await file.readAsBytes();
        excel = Excel.decodeBytes(bytes);
      } catch (e) {
        debugPrint('Error reading existing Excel file: $e');
        excel = Excel.createExcel();
        if (excel.sheets.containsKey('Sheet1') && sheetName != 'Sheet1') {
          excel.delete('Sheet1');
        }
      }
    } else {
      excel = Excel.createExcel();
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

    final nowStr = DateTime.now().toIso8601String();

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
      TextCellValue(nowStr),
    ];

    sheet.appendRow(row);

    final rawValues = [
      input.name.trim().isEmpty ? '0' : input.name.trim(),
      input.mobile.trim().isEmpty ? '0' : input.mobile.trim(),
      input.email.trim(),
      input.state,
      input.monthlyBill,
      input.solarApplication,
      input.installationType,
      input.counts['fan'] ?? 0,
      input.counts['light'] ?? 0,
      input.counts['tv'] ?? 0,
      input.counts['ac'] ?? 0,
      input.counts['washing'] ?? 0,
      input.counts['fridge'] ?? 0,
      input.counts['kettle'] ?? 0,
      input.counts['induction'] ?? 0,
      input.counts['pump'] ?? 0,
      input.counts['geyser'] ?? 0,
      input.otherWatts,
      billReductionStr,
      result.monthlySaving,
      revisedBillStr,
      result.spaceM2,
      result.modules,
      result.cost,
      result.subsidy,
      result.effectiveCost,
      result.coalMT,
      result.co2MT,
      result.trees.round(),
      nowStr,
    ];

    final encodedBytes = excel.encode();
    if (encodedBytes != null) {
      // 1. Write Excel and CSV to internal app docs
      await file.writeAsBytes(encodedBytes, flush: true);
      final csvFile = await getCsvFile();
      await _appendCsvToFile(csvFile, rawValues);

      String? fullCsvContent;
      try {
        if (await csvFile.exists()) {
          fullCsvContent = await csvFile.readAsString();
        }
      } catch (_) {}

      // 2. On Android, save directly to public Downloads folder via MediaStore
      if (!kIsWeb && Platform.isAndroid) {
        try {
          const platform = MethodChannel('com.websol.solar_estimate_calculator/storage');
          await platform.invokeMethod('saveToPublicDownloads', {
            'fileName': fileName,
            'bytes': Uint8List.fromList(encodedBytes),
            'mimeType': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          });

          if (fullCsvContent != null && fullCsvContent.isNotEmpty) {
            await platform.invokeMethod('saveToPublicDownloads', {
              'fileName': csvFileName,
              'bytes': Uint8List.fromList(utf8.encode(fullCsvContent)),
              'mimeType': 'text/csv',
            });
          }
        } catch (e) {
          debugPrint('MethodChannel saveToPublicDownloads failed: $e');
        }

        // Secondary fallback: Direct file writes
        // A. Root Download folder
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            await File('${downloadDir.path}/$fileName').writeAsBytes(encodedBytes, flush: true);
            await _appendCsvToFile(File('${downloadDir.path}/$csvFileName'), rawValues);
          }
        } catch (e) {
          debugPrint('Failed to write to public Download: $e');
        }

        // B. Root Documents folder
        try {
          final docDir = Directory('/storage/emulated/0/Documents');
          if (await docDir.exists()) {
            await File('${docDir.path}/$fileName').writeAsBytes(encodedBytes, flush: true);
            await _appendCsvToFile(File('${docDir.path}/$csvFileName'), rawValues);
          }
        } catch (e) {
          debugPrint('Failed to write to public Documents: $e');
        }

        // C. App-specific external storage (accessible via file manager/USB)
        try {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null && await extDir.exists()) {
            await File('${extDir.path}/$fileName').writeAsBytes(encodedBytes, flush: true);
            await _appendCsvToFile(File('${extDir.path}/$csvFileName'), rawValues);
          }
        } catch (e) {
          debugPrint('Failed to write to external app folder: $e');
        }

        // D. External downloads directories
        try {
          final extDownloads = await getExternalStorageDirectories(type: StorageDirectory.downloads);
          if (extDownloads != null) {
            for (final d in extDownloads) {
              if (await d.exists()) {
                await File('${d.path}/$fileName').writeAsBytes(encodedBytes, flush: true);
                await _appendCsvToFile(File('${d.path}/$csvFileName'), rawValues);
              }
            }
          }
        } catch (e) {
          debugPrint('Failed to write to external downloads: $e');
        }
      }
    }

    return file;
  }

  /// User-friendly path description for UI
  static Future<String> getPublicSavedPathDescription() async {
    return 'Tablet Downloads / Websol_Leads.xlsx (and .csv)';
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
    if (await file.exists()) {
      try {
        final bytes = await file.readAsBytes();
        final excel = Excel.decodeBytes(bytes);
        final sheet = excel[sheetName];
        if (sheet.maxRows > 1) {
          return sheet.maxRows - 1;
        }
      } catch (_) {}
    }

    // Fallback: Check CSV file
    try {
      final csvFile = await getCsvFile();
      if (await csvFile.exists()) {
        final lines = await csvFile.readAsLines();
        if (lines.length > 1) {
          return lines.length - 1;
        }
      }
    } catch (_) {}

    return 0;
  }
}
