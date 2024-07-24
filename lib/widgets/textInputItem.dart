import 'package:flutter/material.dart';
import 'package:tv_repair/constants/constatns.dart';

class TextInputItem extends StatelessWidget {
  final TextEditingController? controller;
  final title;
  final hint;
  final Function(String?)? onChange;
  final Function(String?)? validator;
  final TextInputType? keyboardType;
  final int minLine;
  final bool obscureText;
  final bool enabled;
  final String? initialValue;


  const TextInputItem(
      {this.title,
      this.hint,
      Key? key,
      this.controller,
      this.onChange,
      this.keyboardType = TextInputType.text,
      this.minLine = 1,
      this.obscureText = false,this.enabled = true, this.initialValue, this.validator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6.0,
      ),
      child: Row(
        children: [
          Text(
            "$title:",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: TextFormField(
            obscureText: obscureText,
            minLines: minLine,
            maxLines: obscureText ? 1 : 10,
            controller: controller,
            onChanged: onChange,
            enabled: enabled,
            keyboardType: keyboardType,
            initialValue: initialValue,
            validator: (value) {
              if(validator != null){
                return validator!(value);
              }
              if (value == null || value.isEmpty) {
                return 'please fill this field';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "$hint",
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryColor(1.0))),
              // border: UnderlineInputBorder(
              //     borderSide: BorderSide(
              //         color: primaryColor(1.0)))f
            ),
          ))
        ],
      ),
    );
  }
}
