import 'package:flutter/services.dart';
import 'package:consulta_alunos/core/utils/formatters.dart';

class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = Formatters.digitsOnly(newValue.text);
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    final formatted = Formatters.maskPhone(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
