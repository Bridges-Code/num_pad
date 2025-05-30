import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Show a number pad dialog.
Future<num?> showNumPad(
  BuildContext context, {
  FocusNode? focusNode,
  num? initialValue,
  Widget? hint,
  String? hintText,
  BoxConstraints? constraints,
  bool withDot = true,
  bool withNegative = true,
  bool isNegative = false,
  int? maxLength,
}) {
  return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: NumPad(
                focusNode: focusNode,
                initialValue: initialValue,
                hint: hint,
                hintText: hintText,
                constraints: constraints,
                withDot: withDot,
                withNegative: withNegative,
                isNegative: isNegative,
                maxLength: maxLength,
              )),
        );
      });
}

/// A number pad dialog.
class NumPad extends StatefulWidget {
  const NumPad({
    super.key,
    this.focusNode,
    this.initialValue,
    this.hint,
    this.hintText,
    this.constraints,
    this.withDot = true,
    this.withNegative = true,
    this.isNegative = false,
    this.maxLength,
  });

  final FocusNode? focusNode;
  final num? initialValue;
  final Widget? hint;
  final String? hintText;
  final BoxConstraints? constraints;
  final bool withDot;
  final bool withNegative;
  final bool isNegative;
  final int? maxLength;

  @override
  State<NumPad> createState() => _NumberPadState();
}

class _NumberPadState extends State<NumPad> {
  late final controller =
      TextEditingController(text: widget.initialValue?.abs().toString());
  late final keyboardFocusNode = widget.focusNode ?? FocusNode();
  final inputFocusNode = FocusNode();
  late num? _initialValue = widget.initialValue;
  late bool isNegative = widget.initialValue == null
      ? widget.isNegative
      : widget.initialValue! < 0;
  late final constraints =
      widget.constraints ?? BoxConstraints(maxWidth: 450, maxHeight: 600);

  @override
  void initState() {
    super.initState();

    /// When the dialog is opened, request focus on the keyboard listener.
    keyboardFocusNode.requestFocus();

    /// When inputFocusNode loses focus, focus keyboardFocusNode.
    inputFocusNode.addListener(() {
      if (!inputFocusNode.hasFocus) {
        keyboardFocusNode.requestFocus();
      }
    });
  }

  clearInitialValue() {
    if (_initialValue != null) {
      controller.text = '';
      _initialValue = null;
    }
  }

  /// Add a number to the text field.
  addNumber(num value) {
    clearInitialValue();
    controller.text += value.toString();
    if (widget.maxLength != null &&
        controller.text.length == widget.maxLength!) {
      pop();
    }
  }

  /// Add a dot to the text field.
  addDot() {
    clearInitialValue();

    /// If the text field is empty, add a zero before the dot.
    if (controller.text.isEmpty) {
      controller.text += '0';
    }

    /// If the text field does not contain a dot, add a dot.
    if (!controller.text.contains('.')) {
      controller.text += '.';
    }
  }

  /// Remove the last character from the text field.
  delete() {
    if (controller.text.isNotEmpty) {
      controller.text =
          controller.text.substring(0, controller.text.length - 1);
    }
  }

  /// Close the dialog and return the value.
  pop() {
    Navigator.of(context)
        .maybePop(num.tryParse('${isNegative ? '-' : ''}${controller.text}'));
  }

  updateNegative() {
    setState(() {
      isNegative = !isNegative;
    });
  }

  /// The number button adds a number to the text field.
  Widget numberButton(num value) {
    return FittedBox(
      child: TextButton(
        onPressed: () => addNumber(value),
        child: Text(value.toString()),
      ),
    );
  }

  /// The dot button adds a dot to the text field.
  Widget dotButton() {
    return FittedBox(
      child: TextButton(
        onPressed: addDot,
        child: Text('.'),
      ),
    );
  }

  /// The delete button removes the last character from the text field.
  Widget deleteButton() {
    return FittedBox(
      child: TextButton(
        onPressed: delete,
        child: Icon(Icons.backspace),
      ),
    );
  }

  Widget sendButton() {
    return FittedBox(
      child: TextButton(onPressed: pop, child: const Icon(Icons.check)),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    keyboardFocusNode.dispose();
    inputFocusNode.dispose();
    inputFocusNode.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Constrain the size of the dialog.
    return ConstrainedBox(
      constraints: constraints,
      child: Focus(
          autofocus: true,
          focusNode: keyboardFocusNode,
          onKeyEvent: (node, event) {
            if (inputFocusNode.hasFocus || event is KeyUpEvent) {
              return KeyEventResult.ignored;
            }

            /// If the user presses number keys, add the number to the text field.
            if (event.character?.contains(RegExp(r'\d+')) ?? false) {
              addNumber(num.parse(event.character!));
            }

            /// If the user presses the dot key, add the dot to the text field.
            if (event.character == '.') addDot();

            /// If the user presses the backspace key, remove the last character
            if (event.logicalKey == LogicalKeyboardKey.backspace) delete();

            /// If the user presses the enter key, close the dialog
            /// and return the value.
            if ((event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
              pop();
            }
            return KeyEventResult.handled;
          },
          child: Column(
            children: [
              if (widget.hint != null) widget.hint!,
              if (widget.hintText != null && widget.hint == null)
                Text(
                  widget.hintText!,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              Expanded(
                child: Row(children: [
                  widget.withNegative
                      ? Expanded(
                          child: TextButton(
                          onPressed: updateNegative,
                          child: isNegative
                              ? const Icon(Icons.remove)
                              : const Icon(Icons.add),
                        ))
                      : Spacer(),
                  Expanded(
                      flex: 5,
                      child: AutoSizeTextField(
                        focusNode: inputFocusNode,
                        controller: controller,
                        inputFormatters: [
                          /// Only allow numbers and one dot.
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                        style: Theme.of(context).textTheme.displayLarge,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,

                          // hint: SizedBox.expand(
                          //   child: FittedBox(
                          //     child: Text(widget.hintText ?? 'Input Number'),
                          //   ),
                          // ),
                        ),
                      )),
                  Expanded(child: deleteButton()),
                ]),
              ),

              /// Generate the number buttons.
              ...List.generate(3, (y) {
                return Expanded(
                    child: Row(
                  children: [
                    ...List.generate(3, (x) {
                      final value = x + y * 3 + 1;
                      return Expanded(child: numberButton(value));
                    }),
                  ],
                ));
              }),

              /// Generate the dot, zero and delete buttons.
              Expanded(
                  child: Row(
                children: [
                  Expanded(child: dotButton()),
                  Expanded(child: numberButton(0)),
                  Expanded(child: sendButton()),
                ],
              ))
            ],
          )),
    );
  }
}
