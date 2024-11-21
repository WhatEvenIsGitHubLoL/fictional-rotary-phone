import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_math_fork/flutter_math.dart';
import 'config.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  final TextEditingController _expressionController = TextEditingController();
  String _lastExpression = '';
  String _error = '';
  bool _isLoading = false;
  List<String> _history = [];
  int _cursorPosition = 0;
  bool _showingResult = false;

  void _insertCommand(String command) {
    if (_showingResult) {
      _clearExpression();
    }

    String template = '';
    switch (command) {
      case 'root':
        template = r'\sqrt[n]{x}';
        break;
      case 'exp':
        template = '^{n}';
        break;
      default:
        template = '\\$command{}';
    }

    final currentText = _expressionController.text;
    final beforeCursor = currentText.substring(0, _cursorPosition);
    final afterCursor = currentText.substring(_cursorPosition);
    final newText = beforeCursor + template + afterCursor;
    
    setState(() {
      _expressionController.text = newText;
      // Position cursor inside first argument
      _cursorPosition += template.indexOf('n');
      _expressionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _cursorPosition),
      );
      _error = '';
    });
  }

  void _insertText(String text) {
    if (_showingResult) {
      _clearExpression();
    }
    
    final currentText = _expressionController.text;
    final beforeCursor = currentText.substring(0, _cursorPosition);
    final afterCursor = currentText.substring(_cursorPosition);
    final newText = beforeCursor + text + afterCursor;
    
    setState(() {
      _expressionController.text = newText;
      _cursorPosition += text.length;
      _expressionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _cursorPosition),
      );
      _error = '';
    });
  }

  void _handleBackspace() {
    if (_showingResult) {
      _restoreExpression();
      return;
    }

    final text = _expressionController.text;
    if (_cursorPosition > 0) {
      final beforeCursor = text.substring(0, _cursorPosition - 1);
      final afterCursor = text.substring(_cursorPosition);
      setState(() {
        _expressionController.text = beforeCursor + afterCursor;
        _cursorPosition--;
        _expressionController.selection = TextSelection.fromPosition(
          TextPosition(offset: _cursorPosition),
        );
      });
    }
  }

  void _clearExpression() {
    setState(() {
      _expressionController.clear();
      _cursorPosition = 0;
      _error = '';
      _showingResult = false;
      _lastExpression = '';
    });
  }

  void _restoreExpression() {
    setState(() {
      _expressionController.text = _lastExpression;
      _cursorPosition = _lastExpression.length;
      _expressionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _cursorPosition),
      );
      _showingResult = false;
      _error = '';
    });
  }

  Future<void> _calculate() async {
    if (_expressionController.text.isEmpty) {
      setState(() {
        _error = 'Please enter an expression';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
      _lastExpression = _expressionController.text;
    });

    try {
      developer.log('Sending calculation request',
          name: 'calculator',
          error: {'expression': _expressionController.text});

      final response = await http.post(
        Uri.parse('${Config.backendUrl}/calculate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'expression': _expressionController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _expressionController.text = data['result'].toString();
          _showingResult = true;
          _history.insert(0, '$_lastExpression = ${data['result']}');
          if (_history.length > Config.maxHistoryItems) {
            _history.removeLast();
          }
        });
      } else {
        final error = json.decode(response.body);
        setState(() {
          _error = error['detail'] ?? 'Unknown error occurred';
        });
      }
    } catch (e, stackTrace) {
      developer.log('Calculation error',
          name: 'calculator', error: e, stackTrace: stackTrace);
      setState(() {
        _error = 'Unable to complete calculation. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildButton(String text, {VoidCallback? onPressed, Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onPressed ?? () => _insertText(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: color ?? Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: Colors.blue.withOpacity(0.5),
                  width: 2,
                ),
              ),
              elevation: 4,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 20,
                color: color != null
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommandButton(String text, String command, {Color? color}) {
    return _buildButton(
      text,
      onPressed: () => _insertCommand(command),
      color: color ?? Colors.blue.shade400,
    );
  }

  Widget _buildMathDisplay(String tex, {double? opacity}) {
    return Math.tex(
      tex,
      textStyle: TextStyle(
        fontSize: 20,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(opacity ?? 1.0),
      ),
    );
  }

  Widget _buildExpressionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _expressionController,
          decoration: InputDecoration(
            labelText: 'Expression',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            hintText: 'Enter mathematical expression',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.blue.withOpacity(0.5),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _cursorPosition = _expressionController.selection.base.offset;
              if (_showingResult) {
                _showingResult = false;
                _lastExpression = '';
              }
            });
          },
          onTap: () {
            setState(() {
              _cursorPosition = _expressionController.selection.base.offset;
            });
          },
        ),
        if (_expressionController.text.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildMathDisplay(_expressionController.text),
          const SizedBox(height: 8),
          Opacity(
            opacity: 0.6,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _expressionController.text,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Calculator'),
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_showingResult) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Center(
                        child: _buildMathDisplay(_lastExpression),
                      ),
                    ),
                  ],
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: Colors.blue.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildExpressionInput(),
                    ),
                  ),
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: Colors.blue.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildCommandButton('ⁿ√x', 'root'),
                              _buildCommandButton('xⁿ', 'exp'),
                              _buildButton('('),
                              _buildButton(')'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildButton('7'),
                              _buildButton('8'),
                              _buildButton('9'),
                              _buildButton('/'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildButton('4'),
                              _buildButton('5'),
                              _buildButton('6'),
                              _buildButton('*'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildButton('1'),
                              _buildButton('2'),
                              _buildButton('3'),
                              _buildButton('-'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildButton('0'),
                              _buildButton('.'),
                              _buildButton(','),
                              _buildButton('+'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildButton('C',
                                  onPressed: _clearExpression,
                                  color: Colors.red.shade400),
                              if (_showingResult)
                                _buildButton('↶',
                                    onPressed: _restoreExpression,
                                    color: Colors.orange.shade400)
                              else
                                _buildButton('⌫',
                                    onPressed: _handleBackspace,
                                    color: Colors.orange.shade400),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _calculate,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade400,
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          side: BorderSide(
                                            color: Colors.blue.withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              '=',
                                              style: TextStyle(
                                                fontSize: 24,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_history.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: Colors.blue.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'History',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Divider(),
                            ...List.generate(
                              _history.length,
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: _buildMathDisplay(_history[index]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _expressionController.dispose();
    super.dispose();
  }
}
