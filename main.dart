import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF59E0B),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const CalculatorPage(),
      );
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double? _storedValue;
  String? _operator;
  bool _startNewNumber = false;

  void _press(String key) {
    setState(() {
      if (key == 'AC') {
        _display = '0';
        _storedValue = null;
        _operator = null;
        _startNewNumber = false;
        return;
      }
      // An error is cleared as soon as the user starts their next calculation.
      if (_display == 'Error') {
        _display = '0';
        _storedValue = null;
        _operator = null;
        _startNewNumber = false;
      }
      if (key == 'DEL') {
        if (!_startNewNumber && _display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
        return;
      }
      if (key == '.') {
        if (_startNewNumber) {
          _display = '0.';
          _startNewNumber = false;
        } else if (!_display.contains('.')) {
          _display += '.';
        }
        return;
      }
      if ('0123456789'.contains(key)) {
        _display = (_display == '0' || _startNewNumber) ? key : _display + key;
        _startNewNumber = false;
        return;
      }
      if (key == '%') {
        _display = _format(double.parse(_display) / 100);
        return;
      }
      if (key == '=') {
        if (_storedValue != null && _operator != null) {
          _display = _format(_calculate(_storedValue!, double.parse(_display), _operator!));
          _storedValue = null;
          _operator = null;
          _startNewNumber = true;
        }
        return;
      }
      // Tapping an operator evaluates the previous operation, then stores this one.
      final value = double.parse(_display);
      if (_storedValue != null && _operator != null && !_startNewNumber) {
        _storedValue = _calculate(_storedValue!, value, _operator!);
        _display = _format(_storedValue!);
      } else {
        _storedValue = value;
      }
      _operator = key;
      _startNewNumber = true;
    });
  }

  double _calculate(double left, double right, String operation) {
    switch (operation) {
      case '+': return left + right;
      case '−': return left - right;
      case '×': return left * right;
      case '÷': return right == 0 ? double.nan : left / right;
      default: return left;
    }
  }

  String _format(double value) {
    if (!value.isFinite) return 'Error';
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsPrecision(12).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    const keys = [
      'AC', 'DEL', '%', '÷',
      '7', '8', '9', '×',
      '4', '5', '6', '−',
      '1', '2', '3', '+',
      '0', '.', '=',
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _display,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 58, fontWeight: FontWeight.w300),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    flex: 3,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: keys.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) => _CalculatorButton(
                        label: keys[index],
                        onTap: () => _press(keys[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOperator = const ['÷', '×', '−', '+', '='].contains(label);
    final isClear = label == 'AC';
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: isClear
            ? const Color(0xFFEF4444)
            : isOperator ? const Color(0xFFF59E0B) : const Color(0xFF334155),
        foregroundColor: isOperator ? const Color(0xFF172033) : Colors.white,
        shape: const CircleBorder(),
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
