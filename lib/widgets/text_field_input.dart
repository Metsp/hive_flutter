import "package:flutter/material.dart";
import "package:hive_flutter/utils/colors.dart";

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass; //Check if text accepted is password or not
  final String hintText;
  final TextInputType textInputType;
  const TextFieldInput({
    super.key,
    required this.textEditingController,
    this.isPass =
        false, // Set this as false and not required to make sure that the default text field is
    // not a password text field, and only needed to be written if the text field is a password.
    required this.hintText,
    required this.textInputType,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return TextField(
      controller: textEditingController,
      style: const TextStyle(
        color: hiveBlack,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      keyboardType: textInputType,
      obscureText:
          isPass, //Used to determine if the password needs to be hidden using ****
    );
  }
}
