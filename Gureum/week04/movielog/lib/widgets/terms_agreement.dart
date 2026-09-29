import 'package:flutter/material.dart';

class TermsAgreement extends StatelessWidget {
  const TermsAgreement({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: value,
      onChanged: (next) => onChanged(next ?? false),
      title: const Text('필수 이용약관에 동의합니다.'),
      subtitle: const Text('MovieLog 서비스 이용을 위해 동의가 필요해요.'),
    );
  }
}
