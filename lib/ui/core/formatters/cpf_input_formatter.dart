import 'package:flutter/services.dart';

class CpfInputFormatter extends TextInputFormatter {
  const CpfInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limitedDigits = digits.substring(0, digits.length.clamp(0, 11));
    final formatted = _format(limitedDigits);
    final selectedDigits = newValue.selection.baseOffset.clamp(
      0,
      newValue.text.length,
    );
    final digitsBeforeSelection = newValue.text
        .substring(0, selectedDigits)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length
        .clamp(0, limitedDigits.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _format(
          limitedDigits.substring(0, digitsBeforeSelection),
        ).length,
      ),
    );
  }

  String _format(String cpf) {
    final buffer = StringBuffer();
    for (var index = 0; index < cpf.length; index++) {
      if (index == 3 || index == 6) buffer.write('.');
      if (index == 9) buffer.write('-');
      buffer.write(cpf[index]);
    }
    return buffer.toString();
  }
}
