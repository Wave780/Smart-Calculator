import 'dart:ui';

class CalculatorState {
  final String display;
  final double? currentValue;
  final double? previousValue;
  final String? operation;
  final bool showRestDisplay;
  final double memory;
  final List<CalculatorHistory> history;

  CalculatorState(
      {this.display = '0',
      this.currentValue,
      this.previousValue,
      this.operation,
      this.showRestDisplay = false,
      this.memory = 0,
      this.history = const []});

  CalculatorState copyWith({
    String? display,
    double? currentValue,
    double? previousValue,
    String? operation,
    bool? showRestDisplay,
    double? memory,
    List<CalculatorHistory>? history,
  }) {
    return CalculatorState(
        display: display ?? this.display,
        currentValue: currentValue ?? this.currentValue,
        previousValue: previousValue ?? this.previousValue,
        operation: operation ?? this.operation,
        showRestDisplay: showRestDisplay ?? this.showRestDisplay,
        memory: memory ?? this.memory,
        history: history ?? this.history);
  }
}

class CalculatorHistory {
  final String expression;
  final String result;
  final DateTime timeStamp;

  CalculatorHistory(
      {required this.expression,
      required this.result,
      required this.timeStamp});

  static CalculatorHistory fromJson(Map<String, dynamic> json) =>
      CalculatorHistory(
          expression: json['expression'],
          result: json['result'],
          timeStamp: DateTime.parse(json['timeStamp']));
  Map<String, dynamic> toJson() => {
        'expression': expression,
        'result': result,
        'timeStamp': timeStamp.toIso8601String()
      };
}

enum ButtonType { number, operation, function, memory, utility }

class CalculatorButton {
  final String text;
  final String value;
  final ButtonType type;
  final Color? color;
  final Color? textColor;

  CalculatorButton(
      {required this.text,
      required this.value,
      required this.type,
      this.color,
      this.textColor});
}
