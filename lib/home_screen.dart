import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_calculator/data.dart';
import 'package:smart_calculator/logic.dart';
import 'package:smart_calculator/theme/theme.dart';

class CalculatorApp extends StatefulWidget {
  final CalculatorTheme theme;
  final VoidCallback onToggleTheme;
  final bool isDark;

  const CalculatorApp(
      {super.key,
      required this.theme,
      required this.onToggleTheme,
      required this.isDark});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  CalculatorState _state = CalculatorState();
  bool _showHistory = false;
  bool _isDarkMode = true;

  late final CalculatorTheme _theme;

  void initState() {
    super.initState();
    //To load from history
    _loadInitialHistory();
    //theme
    _theme = widget.theme;
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getBool('isDarkMode') ?? true;
    setState(() {
      _isDarkMode = savedTheme;
    });
  }

  void _loadInitialHistory() async {
    final loadedHistory = await _loadHistoryFromPrefs();
    setState(() {
      _state = _state.copyWith(history: loadedHistory);
    });
  }

  //Calculator button layout
  final List<List<CalculatorButton>> _buttonLayout = [
    [
      CalculatorButton(text: "MC", value: "MC", type: ButtonType.memory),
      CalculatorButton(text: "MR", value: "MR", type: ButtonType.memory),
      CalculatorButton(text: "M+", value: "M+", type: ButtonType.memory),
      CalculatorButton(text: "M-", value: "M-", type: ButtonType.memory),
    ],
    [
      CalculatorButton(
          text: "C",
          value: "C",
          type: ButtonType.utility,
          color: Colors.red[500]),
      CalculatorButton(text: "CE", value: "CE", type: ButtonType.utility),
      CalculatorButton(text: "√", value: "√", type: ButtonType.function),
      CalculatorButton(
          text: "÷",
          value: "÷",
          type: ButtonType.operation,
          color: Colors.green),
    ],
    [
      CalculatorButton(text: "7", value: "7", type: ButtonType.number),
      CalculatorButton(text: "8", value: "8", type: ButtonType.number),
      CalculatorButton(text: "9", value: "9", type: ButtonType.number),
      CalculatorButton(
          text: "*",
          value: "*",
          type: ButtonType.operation,
          color: Colors.green),
    ],
    [
      CalculatorButton(text: "4", value: "4", type: ButtonType.number),
      CalculatorButton(text: "5", value: "5", type: ButtonType.number),
      CalculatorButton(text: "6", value: "6", type: ButtonType.number),
      CalculatorButton(
          text: "-",
          value: "-",
          type: ButtonType.operation,
          color: Colors.green),
    ],
    [
      CalculatorButton(text: "1", value: "1", type: ButtonType.number),
      CalculatorButton(text: "2", value: "2", type: ButtonType.number),
      CalculatorButton(text: "3", value: "3", type: ButtonType.number),
      CalculatorButton(
          text: "+",
          value: "+",
          type: ButtonType.operation,
          color: Colors.green),
    ],
    [
      CalculatorButton(text: "±", value: "±", type: ButtonType.function),
      CalculatorButton(text: "0", value: "0", type: ButtonType.number),
      CalculatorButton(text: ".", value: ".", type: ButtonType.number),
      CalculatorButton(
          text: "=",
          value: "=",
          type: ButtonType.operation,
          color: Colors.blue),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _theme.backgroundColor,
        body: SafeArea(
            child: Column(
          children: [
            // Display area
            _buildDisplay(),
            Divider(),
            // History toggle
            _buildHistoryToggle(),

            // Calculator buttons or history
            Expanded(
              child: _showHistory ? _buildHistory() : _buildButtonGrid(),
            ),
          ],
        )));
  }

  Widget _buildThemeToggle() {
    return IconButton(
      icon: Icon(
        widget.isDark ? Icons.dark_mode : Icons.light_mode,
        color: Colors.grey,
      ),
      onPressed: widget.onToggleTheme,
    );
  }

  Widget _buildDisplay() {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            //Memory Icon
            if (_state.memory != 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  "M",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),

            const SizedBox(
              height: 8,
            ),

            //Current operation display
            if (_state.operation != null && _state.previousValue != null)
              Text(
                "${CalculatorLogic.formatDisplay(_state.previousValue!)} ${_state.operation}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),

            const SizedBox(
              height: 8,
            ),

            //Main display
            Container(
              width: double.infinity,
              child: Text(
                _state.display,
                style: TextStyle(
                  color: _theme.displayColor,
                  fontSize: _getDisplayFontSize(),
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ));
  }

  _getDisplayFontSize() {
    final length = _state.display.length;
    if (length <= 8.0) return 48.0;
    if (length <= 10.0) return 40.0;
    if (length <= 12.0) return 32.0;
    return 24.0;
  }

  Widget _buildHistoryToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _showHistory ? "Calculator" : "History (${_state.history.length})",
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Row(
            children: [
              _buildThemeToggle(),
              IconButton(
                icon: Icon(
                  _showHistory ? Icons.calculate : Icons.history,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _showHistory = !_showHistory;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonGrid() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: _buttonLayout.map((row) {
          return Expanded(
            child: Row(
              children: row.map((button) {
                return Expanded(
                  child: _buildCalculatorButton(button),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalculatorButton(CalculatorButton button) {
    final isPressed = _state.operation == button.value;

    return Container(
      margin: const EdgeInsets.all(4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleButtonPress(button.value),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            decoration: BoxDecoration(
              color: isPressed
                  ? Colors.grey[400]
                  : button.color ?? _getDefaultButtonColor(button.type),
              borderRadius: BorderRadius.circular(50),
              border:
                  isPressed ? Border.all(color: Colors.orange, width: 2) : null,
            ),
            child: Center(
              child: Text(
                button.text,
                style: TextStyle(
                  color: isPressed
                      ? Colors.orange
                      : button.textColor ?? _getDefaultTextColor(button.type),
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getDefaultButtonColor(ButtonType type) {
    switch (type) {
      case ButtonType.number:
        return _theme.numberButtonColor;
      case ButtonType.operation:
        return _theme.operationButtonColor;
      case ButtonType.function:
        return Colors.grey[600]!;
      case ButtonType.memory:
        return Colors.blue[700]!;
      case ButtonType.utility:
        return Colors.grey[600]!;
    }
  }

  Color _getDefaultTextColor(ButtonType type) {
    return _theme.textColor;
  }

  Widget _buildHistory() {
    if (_state.history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No calculations yet",
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Clear history button
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _clearHistory,
            child: const Text("Clear History"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
            ),
          ),
        ),

        // History list
        Expanded(
          child: ListView.builder(
            itemCount: _state.history.length,
            reverse: true,
            itemBuilder: (context, index) {
              final historyItem =
                  _state.history[_state.history.length - 1 - index];
              return _buildHistoryItem(historyItem);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(CalculatorHistory item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.grey[850],
      child: ListTile(
        title: Text(
          item.expression,
          style: TextStyle(color: Colors.grey[300]),
        ),
        subtitle: Text(
          "= ${item.result}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          "${item.timeStamp.hour.toString().padLeft(2, '0')}:${item.timeStamp.minute.toString().padLeft(2, '0')}",
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () => _useHistoryResult(item.result),
      ),
    );
  }

  //Landscape

//Void methods
  void _handleButtonPress(String value) async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _state = CalculatorLogic.processInput(_state, value);
    });
    // Save history if changed
    if (value == "=") {
      await _saveHistoryToPref(_state.history);
    }
  }

  void _clearHistory() {
    setState(() {
      _state = _state.copyWith(history: []);
    });
  }

  void _useHistoryResult(String result) {
    final value = double.tryParse(result);
    if (value != null) {
      setState(() {
        _state = _state.copyWith(
            display: result, currentValue: value, showRestDisplay: true);
        _showHistory = false;
      });
    }
  }

  Future<void> _saveHistoryToPref(List<CalculatorHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encode =
        history.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList('calculated_history', encode);
  }

  Future<List<CalculatorHistory>> _loadHistoryFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encoded = prefs.getStringList('calculator_history');

    if (encoded == null) return [];
    return encoded
        .map((jsonStr) => CalculatorHistory.fromJson(jsonDecode(jsonStr)))
        .toList();
  }
}
