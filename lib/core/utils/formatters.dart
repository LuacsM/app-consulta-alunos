abstract final class Formatters {
  static String digitsOnly(String value) =>
      value.replaceAll(RegExp(r'\D'), '');

  static String maskCpf(String digits) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String formatCpf(String cpf) {
    final digits = digitsOnly(cpf);
    if (digits.length != 11) return cpf;
    return maskCpf(digits);
  }

  static String maskPhone(String digits) {
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    if (limited.isEmpty) return '';

    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7) buffer.write('-');
      buffer.write(limited[i]);
    }
    return buffer.toString();
  }

  static String formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) return maskPhone(digits);
    if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) '
          '${digits.substring(2, 6)}-${digits.substring(6)}';
    }
    return phone;
  }

  static String formatName(String name) {
    if (name.isEmpty) return name;
    return name
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) => part.length == 1
              ? part.toUpperCase()
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  static String initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String formatIsoDateTime(String? value) {
    if (value == null || value.isEmpty) return '';

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value.replaceFirst('T', ' ').split('.').first;
    }

    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}
