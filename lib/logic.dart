import 'dart:math';

import 'package:smart_calculator/data.dart';

class CalculatorLogic {
  static const int maxDigit = 12;
  static const String errorMessage = "Error";

  //Main
  static CalculatorState processInput(CalculatorState state, String input) {
    switch (input) {
      case "0":
      case "1":
      case "2":
      case "3":
      case "4":
      case "5":
      case "6":
      case "7":
      case "8":
      case "9":
        return _handleNumber(state, input);
      case ".":
        return _handleDecimal(state);
      case "+":
      case "-":
      case "*":
      case "÷":
        return _handleOperation(state, input);
      case "=":
        return _handleEqual(state);
      case "C":
        return _handleClear(state);
      case "CE":
        return _handleClearEntry(state);
      case "±":
        return _handlePlusMins(state);
      case "%":
        return _handlePercentage(state);
      case "√":
        return _handleSquareRoot(state);
      case "MC":
        return _handleMemoryClear(state);
      case "MR":
        return _handleMemoryRecall(state);
      case "M+":
        return _handleMemoryAdd(state);
      case "M-":
        return _handleMemorySubtract(state);
      default:
        return state;
    }
  }

  static CalculatorState _handleNumber(CalculatorState state, String number) {
    if (state.showRestDisplay || state.display == "0") {
      return state.copyWith(
          display: number,
          currentValue: double.parse(number),
          showRestDisplay: false);
    }
    if (state.display.length >= maxDigit) {
      return state;
    }

    final newDisplay = state.display + number;
    return state.copyWith(
        display: newDisplay, currentValue: double.parse(newDisplay));
  }

  static CalculatorState _handleDecimal(CalculatorState state) {
    if (state.showRestDisplay) {
      return state.copyWith(
        display: "0.",
        currentValue: 0.0,
        showRestDisplay: false,
      );
    }
    if (state.display.contains(".")) {
      return state;
    }

    final newDisplay = state.display + ".";
    return state.copyWith(
        display: newDisplay, currentValue: double.parse(newDisplay));
  }

  static CalculatorState _handleOperation(
      CalculatorState state, String operation) {
    if (state.operation != null &&
        state.previousValue != null &&
        !state.showRestDisplay) {
      //Preform pending Calculation first
      final result = _calculate(
          state.previousValue!, state.currentValue ?? 0, state.operation!);
      if (result == null) {
        return state.copyWith(display: errorMessage);
      }
      return state.copyWith(
        display: formatDisplay(result),
        currentValue: result,
        previousValue: result,
        showRestDisplay: true,
        operation: operation,
      );
    }
    return state.copyWith(
        previousValue: state.currentValue ?? 0,
        showRestDisplay: true,
        operation: operation);
  }

  static CalculatorState _handleEqual(CalculatorState state) {
    if (state.operation == null ||
        state.previousValue == null ||
        state.currentValue == null) {
      return state;
    }
    final result =
        _calculate(state.previousValue!, state.currentValue!, state.operation!);
    if (result == null) {
      return state.copyWith(display: errorMessage);
    }

    //Add to history
    final expression =
        "${formatDisplay(state.previousValue!)} ${state.operation} ${formatDisplay(state.currentValue!)}";
    final historyItem = CalculatorHistory(
        expression: expression,
        result: formatDisplay(result),
        timeStamp: DateTime.now());

    final newHistory = [...state.history, historyItem];

    return state.copyWith(
        display: formatDisplay(result),
        previousValue: null,
        currentValue: result,
        operation: null,
        showRestDisplay: true,
        history: newHistory);
  }

  static CalculatorState _handleClear(CalculatorState state) {
    return CalculatorState(
      display: "0",
      memory: 0, // Preserve for MC vs C distinction
    );
  }

  static CalculatorState _handleClearEntry(CalculatorState state) {
    return state.copyWith(
      display: "0",
      currentValue: 0,
      showRestDisplay: false,
    );
  }

  static CalculatorState _handlePlusMins(CalculatorState state) {
    final current = state.currentValue ?? 0;
    final newValue = -current;

    return state.copyWith(
      display: formatDisplay(newValue),
      currentValue: newValue,
    );
  }

  static CalculatorState _handlePercentage(CalculatorState state) {
    final current = state.currentValue ?? 0;
    final result = current / 100;

    return state.copyWith(
      display: formatDisplay(result),
      currentValue: result,
    );
  }

  static CalculatorState _handleSquareRoot(CalculatorState state) {
    final current = state.currentValue ?? 0;
    if (current < 0) {
      return state.copyWith(display: errorMessage);
    }

    final double result = sqrt(current);
    return state.copyWith(display: formatDisplay(result), currentValue: result);
  }

  static CalculatorState _handleMemoryClear(CalculatorState state) {
    return state.copyWith(memory: 0);
  }

  static CalculatorState _handleMemoryRecall(CalculatorState state) {
    return state.copyWith(
        display: formatDisplay(state.memory),
        currentValue: state.memory,
        showRestDisplay: true);
  }

  static CalculatorState _handleMemoryAdd(CalculatorState state) {
    final current = state.currentValue ?? 0;
    return state.copyWith(memory: state.memory + current);
  }

  static CalculatorState _handleMemorySubtract(CalculatorState state) {
    final current = state.currentValue ?? 0;
    return state.copyWith(memory: state.memory - current);
  }

  //Operation method
  static double? _calculate(double a, double b, String operation) {
    try {
      switch (operation) {
        case "+":
          return a + b;
        case "-":
          return a - b;
        case "*":
          return a * b;
        case "÷":
          if (b == 0) return null; // division by zero(0)
          return a / b;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  //Formating of values
  static String formatDisplay(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }

    String formatted = value.toStringAsFixed(8);
    formatted = formatted.replaceAll(RegExp(r"0*$"), "replace");
    formatted = formatted.replaceAll(RegExp(r"\.$"), "replace");

    if (formatted.length > maxDigit) {
      return value.toStringAsExponential(6);
    }
    return formatted;
  }
}
