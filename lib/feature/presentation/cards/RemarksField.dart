import 'package:flutter/material.dart';
import '../../../components/styles/appColors.dart';


class RemarksField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const RemarksField({
    super.key,
    required this.controller,
    this.hint = "Enter Remarks...",
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      minLines: 3,
      maxLines: null,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: AppColors.editTextField,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
