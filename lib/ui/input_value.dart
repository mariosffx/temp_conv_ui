import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputValue extends StatelessWidget {
  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  final FormFieldValidator<String> validator;
  final String labelText;
  final String hintText;

  const InputValue({
    super.key,
    required this.controller,
    required this.inputFormatters,
    required this.validator,
    required this.labelText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(),
        errorStyle: const TextStyle(
          height: 1.2, // controls line height
        ),
        helperText: ' ',
      ),
      validator: validator,
    );
  }
}
