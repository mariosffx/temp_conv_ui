import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../ui/input_value.dart';
import '../ui/dropdown.dart';
import '../ui/form_message.dart';
import '../ui/submit_button.dart';

enum TempUnit { celsius, fahrenheit, kelvin }

extension TempUnitX on TempUnit {
  String get apiValue => switch (this) {
    TempUnit.celsius => "celsius",
    TempUnit.fahrenheit => "fahrenheit",
    TempUnit.kelvin => "kelvin",
  };

  String get label => switch (this) {
    TempUnit.celsius => "°C Celsius",
    TempUnit.fahrenheit => "°F Fahrenheit",
    TempUnit.kelvin => "K Kelvin",
  };

  // Kelvin cannot be negative.
  bool allowsNegativeInput() => this != TempUnit.kelvin;
}

class TemperatureConverterScreen extends StatefulWidget {
  const TemperatureConverterScreen({super.key});

  @override
  State<TemperatureConverterScreen> createState() =>
      _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState
    extends State<TemperatureConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();

  TempUnit _from = TempUnit.celsius;
  TempUnit _to = TempUnit.fahrenheit;

  bool _loading = false;

  MessageType? _messageType;
  String? _messageText;

  final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? "https://temp-conv-api.web-coders.xyz";

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  String? _validateValue(String? raw) {
    final text = (raw ?? "").trim();

    if (text.isEmpty) return "Enter a temperature value.";

    // Accept only numbers
    final regex = RegExp(r'^-?\d+(\.\d+)?$');
    if (!regex.hasMatch(text)) return "Only numbers are allowed (e.g. -12.5).";

    final value = double.tryParse(text);
    if (value == null) return "Invalid number.";

    if (value < 0 && !_from.allowsNegativeInput()) {
      return "Negative values are not allowed for ${_from.label}.";
    }

    // Kelvin cannot go below 0
    if (_from == TempUnit.kelvin && value < 0) {
      return "Kelvin cannot be negative.";
    }

    return null;
  }

  String? _validateUnits() {
    if (_from == _to) {
      return "From and To units must be different.";
    }
    return null;
  }

  void _changeTo<ItemType>(TempUnit? v) {
    if (v == null) return;
    setState(() {
      _to = v;
      _formKey.currentState?.validate();
    });

    final error = _validateUnits();
    if (error != null) {
      setState(() {
        _messageType = MessageType.error;
        _messageText = error;
      });
    } else {
      setState(() {
        _messageType = null;
        _messageText = null;
      });
    }
  }

  void _changeFrom<ItemType>(TempUnit? v) {
    if (v == null) return;
    setState(() {
      _from = v;
      _formKey.currentState?.validate();
    });

    final error = _validateUnits();
    if (error != null) {
      setState(() {
        _messageType = MessageType.error;
        _messageText = error;
      });
    } else {
      setState(() {
        _messageType = null;
        _messageText = null;
      });
    }
  }

  String _formatLabel(TempUnit unit) => unit.label;

  Future<void> _submit() async {
    final unitsError = _validateUnits();

    if (unitsError != null) {
      setState(() {
        _messageType = MessageType.error;
        _messageText = unitsError;
      });
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;
    final value = double.parse(_valueController.text.trim());

    setState(() => _loading = true);
    try {
      final uri = Uri.parse("$_baseUrl/api/convert");
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "value": value,
          "from": _from.apiValue,
          "to": _to.apiValue,
        }),
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        // Try to parse backend error:
        String msg = "Request failed (${res.statusCode}).";
        try {
          final decoded = jsonDecode(res.body);

          if (decoded is Map && decoded["error"] is String) {
            msg = decoded["error"];
          }
        } catch (_) {}
        setState(() {
          _messageType = MessageType.error;
          _messageText = msg;
        });
        return;
      }

      final decoded = jsonDecode(res.body);
      final result = (decoded is Map) ? decoded["result"] : null;

      debugPrint("Decoded  $decoded");

      if (result == null) {
        setState(() {
          _messageType = MessageType.error;
          _messageText = "Unexpected response: ${res.body}";
        });
        return;
      }

      setState(() {
        _messageText = "$value ${_from.label} → $result ${_to.label}";
        _messageType = MessageType.result;
      });
    } catch (e) {
      setState(() {
        _messageType = MessageType.error;
        _messageText = "Network error: $e";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Temperature Converter")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputValue(
                labelText: "Degrees",
                hintText: "e.g. -12.5",
                controller: _valueController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                ],
                validator: _validateValue,
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Dropdown<TempUnit>(
                    labelText: "From",
                    items: TempUnit.values,
                    value: _from,
                    onChanged: _changeFrom,
                    formatLabel: _formatLabel,
                  ),

                  const SizedBox(width: 12),

                  Dropdown<TempUnit>(
                    labelText: "To",
                    items: TempUnit.values,
                    value: _to,
                    onChanged: _changeTo,
                    formatLabel: _formatLabel,
                  ),
                ],
              ),

              FormMessage(messageText: _messageText, messageType: _messageType),

              const SizedBox(height: 16),
              SubmitButton(
                onPressed: _submit,
                loading: _loading,
                text: "Submit",
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
