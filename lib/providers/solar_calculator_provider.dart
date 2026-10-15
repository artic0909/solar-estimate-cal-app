import 'package:flutter/foundation.dart';
import '../core/solar_calculator.dart';
import '../models/solar_input.dart';
import '../models/solar_result.dart';
import '../services/lead_excel_service.dart';

class SolarCalculatorProvider extends ChangeNotifier {
  SolarInput _input = const SolarInput();
  SolarResult? _result;
  bool _isSavingLead = false;
  int _savedLeadsCount = 0;
  String? _errorMessage;

  SolarInput get input => _input;
  SolarResult? get result => _result;
  bool get isSavingLead => _isSavingLead;
  int get savedLeadsCount => _savedLeadsCount;
  String? get errorMessage => _errorMessage;

  SolarCalculatorProvider() {
    calculate();
    loadLeadsCount();
  }

  Future<void> loadLeadsCount() async {
    _savedLeadsCount = await LeadExcelService.getSavedLeadsCount();
    notifyListeners();
  }

  void setInput(SolarInput newInput, {bool recalculate = true}) {
    _input = newInput;
    _errorMessage = null;
    if (recalculate) {
      calculate();
    } else {
      notifyListeners();
    }
  }

  void calculate() {
    if (_input.monthlyBill <= 0) {
      _errorMessage = 'Monthly electricity bill must be greater than 0.';
      notifyListeners();
      return;
    }

    if (_input.totalLoadWatts <= 0) {
      _errorMessage = 'Please specify at least one appliance or load.';
      notifyListeners();
      return;
    }

    try {
      _result = SolarCalculator.calculateFromInput(_input);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> saveCurrentLead() async {
    if (_result == null) {
      calculate();
    }
    if (_result == null) return false;

    _isSavingLead = true;
    notifyListeners();

    try {
      await LeadExcelService.saveLead(input: _input, result: _result!);
      _savedLeadsCount = await LeadExcelService.getSavedLeadsCount();
      _isSavingLead = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save lead: $e';
      _isSavingLead = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> shareLeadsFile() async {
    return await LeadExcelService.shareLeadsFile();
  }

  Future<String> getSavedPathDescription() async {
    return await LeadExcelService.getPublicSavedPathDescription();
  }

  void resetLeadForm() {
    _input = _input.copyWith(
      name: '',
      mobile: '',
      email: '',
    );
    notifyListeners();
  }

  void clearAll() {
    _input = const SolarInput(
      state: 'West Bengal',
      monthlyBill: 0,
      solarApplication: 'Residential',
      installationType: 'Rooftop',
      moduleWatt: 550,
      counts: {},
      otherWatts: 0,
    );
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }
}
