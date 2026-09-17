import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientific Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double? _operand;
  String? _pendingOperator;
  bool _shouldResetDisplay = false;

  static const _maxDigits = 12;

  void _inputDigit(String digit) {
    setState(() {
      if (_shouldResetDisplay || _display == 'Error') {
        _display = digit;
        _shouldResetDisplay = false;
      } else if (_display == '0') {
        _display = digit;
      } else {
        final digitsOnly = _display.replaceAll(RegExp(r'[-.]'), '');
        if (digitsOnly.length >= _maxDigits) return;
        _display += digit;
      }
    });
  }

  void _inputDecimal() {
    setState(() {
      if (_shouldResetDisplay || _display == 'Error') {
        _display = '0.';
        _shouldResetDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _operand = null;
      _pendingOperator = null;
      _shouldResetDisplay = false;
    });
  }

  void _backspace() {
    setState(() {
      if (_shouldResetDisplay || _display == 'Error') {
        _display = '0';
        _shouldResetDisplay = false;
        return;
      }
      if (_display.length <= 1 || (_display.startsWith('-') && _display.length == 2)) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display == '0' || _display == 'Error') return;
      _display = _display.startsWith('-') ? _display.substring(1) : '-$_display';
    });
  }

  void _percent() {
    setState(() {
      final value = double.tryParse(_display);
      if (value == null) return;
      _display = _formatNumber(value / 100);
    });
  }

  double _applyOperator(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        return b == 0 ? double.nan : a / b;
      case '^':
        return math.pow(a, b).toDouble();
      default:
        return b;
    }
  }

  void _onOperator(String op) {
    setState(() {
      if (_display == 'Error') return;
      final current = double.tryParse(_display);
      if (current == null) return;

      if (_pendingOperator != null && !_shouldResetDisplay) {
        final result = _applyOperator(_operand!, current, _pendingOperator!);
        if (result.isNaN || result.isInfinite) {
          _display = 'Error';
          _operand = null;
          _pendingOperator = null;
          _shouldResetDisplay = true;
          return;
        }
        _display = _formatNumber(result);
        _operand = result;
      } else {
        _operand = current;
      }
      _pendingOperator = op;
      _shouldResetDisplay = true;
    });
  }

  void _onEquals() {
    setState(() {
      if (_display == 'Error' || _pendingOperator == null || _operand == null) return;
      final current = double.tryParse(_display);
      if (current == null) return;
      final result = _applyOperator(_operand!, current, _pendingOperator!);
      _display = (result.isNaN || result.isInfinite) ? 'Error' : _formatNumber(result);
      _operand = null;
      _pendingOperator = null;
      _shouldResetDisplay = true;
    });
  }

  void _applyFunction(String fn) {
    setState(() {
      final v = double.tryParse(_display);
      if (v == null) return;
      double result;
      switch (fn) {
        case 'sin':
          result = math.sin(v * math.pi / 180);
          break;
        case 'cos':
          result = math.cos(v * math.pi / 180);
          break;
        case 'tan':
          final c = math.cos(v * math.pi / 180);
          result = c == 0 ? double.nan : math.tan(v * math.pi / 180);
          break;
        case '√':
          result = v < 0 ? double.nan : math.sqrt(v);
          break;
        case 'log':
          result = v <= 0 ? double.nan : math.log(v) / math.ln10;
          break;
        case 'ln':
          result = v <= 0 ? double.nan : math.log(v);
          break;
        case '1/x':
          result = v == 0 ? double.nan : 1 / v;
          break;
        default:
          result = v;
      }
      _display = (result.isNaN || result.isInfinite) ? 'Error' : _formatNumber(result);
      _shouldResetDisplay = true;
    });
  }

  void _insertConstant(double value) {
    setState(() {
      _display = _formatNumber(value);
      _shouldResetDisplay = false;
    });
  }

  String _formatNumber(double v) {
    if (v.isNaN || v.isInfinite) return 'Error';
    if (v == v.roundToDouble() && v.abs() < 1e12) {
      return v.toStringAsFixed(0);
    }
    var s = v.toStringAsPrecision(10);
    if (s.contains('.') && !s.contains('e')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      s = s.replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _display,
                    key: const Key('display'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _buildRow([
                      _ButtonSpec('sin', const Key('fn_sin'), _funcColor, Colors.white,
                          () => _applyFunction('sin')),
                      _ButtonSpec('cos', const Key('fn_cos'), _funcColor, Colors.white,
                          () => _applyFunction('cos')),
                      _ButtonSpec('tan', const Key('fn_tan'), _funcColor, Colors.white,
                          () => _applyFunction('tan')),
                      _ButtonSpec('√', const Key('fn_sqrt'), _funcColor, Colors.white,
                          () => _applyFunction('√')),
                      _ButtonSpec('xʸ', const Key('op_pow'), _funcColor, Colors.white,
                          () => _onOperator('^')),
                    ]),
                    _buildRow([
                      _ButtonSpec('log', const Key('fn_log'), _funcColor, Colors.white,
                          () => _applyFunction('log')),
                      _ButtonSpec('ln', const Key('fn_ln'), _funcColor, Colors.white,
                          () => _applyFunction('ln')),
                      _ButtonSpec('π', const Key('const_pi'), _funcColor, Colors.white,
                          () => _insertConstant(math.pi)),
                      _ButtonSpec('e', const Key('const_e'), _funcColor, Colors.white,
                          () => _insertConstant(math.e)),
                      _ButtonSpec('1/x', const Key('fn_inv'), _funcColor, Colors.white,
                          () => _applyFunction('1/x')),
                    ]),
                    _buildRow([
                      _ButtonSpec('C', const Key('clear'), _lightGray, Colors.black, _clear),
                      _ButtonSpec('⌫', const Key('backspace'), _lightGray, Colors.black, _backspace),
                      _ButtonSpec('%', const Key('percent'), _lightGray, Colors.black, _percent),
                      _ButtonSpec('±', const Key('plusMinus'), _lightGray, Colors.black, _toggleSign),
                      _ButtonSpec('÷', const Key('op_div'), _opColor, Colors.white,
                          () => _onOperator('/')),
                    ]),
                    _buildRow([
                      _ButtonSpec('7', const Key('digit_7'), _numColor, Colors.white,
                          () => _inputDigit('7')),
                      _ButtonSpec('8', const Key('digit_8'), _numColor, Colors.white,
                          () => _inputDigit('8')),
                      _ButtonSpec('9', const Key('digit_9'), _numColor, Colors.white,
                          () => _inputDigit('9')),
                      _ButtonSpec('×', const Key('op_mul'), _opColor, Colors.white,
                          () => _onOperator('*')),
                    ]),
                    _buildRow([
                      _ButtonSpec('4', const Key('digit_4'), _numColor, Colors.white,
                          () => _inputDigit('4')),
                      _ButtonSpec('5', const Key('digit_5'), _numColor, Colors.white,
                          () => _inputDigit('5')),
                      _ButtonSpec('6', const Key('digit_6'), _numColor, Colors.white,
                          () => _inputDigit('6')),
                      _ButtonSpec('−', const Key('op_sub'), _opColor, Colors.white,
                          () => _onOperator('-')),
                    ]),
                    _buildRow([
                      _ButtonSpec('1', const Key('digit_1'), _numColor, Colors.white,
                          () => _inputDigit('1')),
                      _ButtonSpec('2', const Key('digit_2'), _numColor, Colors.white,
                          () => _inputDigit('2')),
                      _ButtonSpec('3', const Key('digit_3'), _numColor, Colors.white,
                          () => _inputDigit('3')),
                      _ButtonSpec('+', const Key('op_add'), _opColor, Colors.white,
                          () => _onOperator('+')),
                    ]),
                    _buildRow([
                      _ButtonSpec('0', const Key('digit_0'), _numColor, Colors.white,
                          () => _inputDigit('0'), flex: 2),
                      _ButtonSpec('.', const Key('decimal'), _numColor, Colors.white, _inputDecimal),
                      _ButtonSpec('=', const Key('equals'), _opColor, Colors.white, _onEquals),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _numColor = Color(0xFF333333);
  static const _opColor = Colors.orange;
  static const _funcColor = Color(0xFF4A4A4A);
  static const _lightGray = Color(0xFFA5A5A5);

  Widget _buildRow(List<_ButtonSpec> specs) {
    return Expanded(
      child: Row(
        children: specs.map((spec) {
          return Expanded(
            flex: spec.flex,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Material(
                color: spec.bgColor,
                shape: const StadiumBorder(),
                child: InkWell(
                  key: spec.key,
                  customBorder: const StadiumBorder(),
                  onTap: spec.onTap,
                  child: Center(
                    child: Text(
                      spec.label,
                      style: TextStyle(
                        color: spec.textColor,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ButtonSpec {
  final String label;
  final Key key;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;
  final int flex;

  _ButtonSpec(this.label, this.key, this.bgColor, this.textColor, this.onTap, {this.flex = 1});
}
