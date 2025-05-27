import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Show a number pad dialog.
Future<num?> showShadNumPad(
  BuildContext context, {
  FocusNode? focusNode,
  num? initialValue,
  String? hintText,
  BoxConstraints? constraints,
  bool withDot = true,
  bool withNegative = true,
  bool isNegative = false,
  int? maxLength,
}) {
  return showShadDialog(
      context: context,
      builder: (context) {
        return ShadDialog(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: ShadNumPad(
                focusNode: focusNode,
                initialValue: initialValue,
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

const _constraints = BoxConstraints(maxWidth: 500, maxHeight: 500);

/// A number pad dialog.
class ShadNumPad extends StatefulWidget {
  const ShadNumPad({
    super.key,
    this.focusNode,
    this.initialValue,
    this.hintText,
    this.constraints = _constraints,
    this.withDot = true,
    this.withNegative = true,
    this.isNegative = false,
    this.maxLength,
  });

  final FocusNode? focusNode;
  final num? initialValue;
  final String? hintText;
  final BoxConstraints? constraints;
  final bool withDot;
  final bool withNegative;
  final bool isNegative;
  final int? maxLength;

  @override
  State<ShadNumPad> createState() => _NumberPadState();
}

class _NumberPadState extends State<ShadNumPad> {
  late final controller =
      TextEditingController(text: widget.initialValue?.abs().toString());
  late final keyboardFocusNode = widget.focusNode ?? FocusNode();
  final inputFocusNode = FocusNode();
  late num? _initialValue = widget.initialValue;
  late bool isNegative = widget.initialValue == null
      ? widget.isNegative
      : widget.initialValue! < 0;

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
      child: ShadButton.ghost(
        onPressed: () => addNumber(value),
        child: Text(value.toString()),
      ),
    );
  }

  /// The dot button adds a dot to the text field.
  Widget dotButton() {
    return FittedBox(
      child: ShadButton.ghost(
        onPressed: addDot,
        child: Text('.'),
      ),
    );
  }

  /// The delete button removes the last character from the text field.
  Widget deleteButton() {
    return FittedBox(
      child: ShadButton.ghost(
        onPressed: delete,
        child: Icon(LucideIcons.delete),
      ),
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
      constraints: _constraints,
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
              Expanded(
                child: Row(children: [
                  if (widget.withNegative)
                    ShadButton.ghost(
                      onPressed: updateNegative,
                      child: isNegative
                          ? const Icon(LucideIcons.minus)
                          : const Icon(LucideIcons.plus),
                    ),
                  Expanded(
                      child: ShadInput(
                    focusNode: inputFocusNode,
                    controller: controller,
                    inputFormatters: [
                      /// Only allow numbers and one dot.
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                    placeholder: SizedBox.expand(
                      child: FittedBox(
                        child: Text(widget.hintText ?? 'Input Number'),
                      ),
                    ),
                    decoration: ShadDecoration(
                        border: ShadBorder.none,
                        focusedBorder: ShadBorder.none),
                  )),
                  ShadButton.ghost(
                      onPressed: pop, child: const Icon(LucideIcons.check))
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
                  Expanded(child: deleteButton()),
                ],
              ))
            ],
          )),
    );
  }
}
