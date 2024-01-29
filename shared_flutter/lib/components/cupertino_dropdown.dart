import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropDownCupertino<T extends Enum> extends StatefulWidget {
  final String initialText;
  final TextStyle? style;
  final ButtonStyle? buttonStyle;
  final double? height;
  final Function onSelectedItemChanged;
  final Map<T?, String> pickList;
  const DropDownCupertino(
      {Key? key,
      required this.initialText,
      this.style,
      required this.onSelectedItemChanged,
      this.height,
      required this.pickList,
      this.buttonStyle})
      : super(key: key);

  @override
  State<DropDownCupertino> createState() => _DropDownCupertinoState();
}

class _DropDownCupertinoState extends State<DropDownCupertino> {
  String categoryText = "";

  @override
  void initState() {
    categoryText = widget.initialText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: widget.buttonStyle ??
            TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(
                    width: 0.0, color: CupertinoColors.inactiveGray),
              ),
            ),
        onPressed: (() {
          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => Container(
                    height: 400,
                    padding: const EdgeInsets.only(top: 6.0),
                    // The Bottom margin is provided to align the popup above the system navigation bar.
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    // Provide a background color for the popup.
                    color:
                        CupertinoColors.systemBackground.resolveFrom(context),
                    // Use a SafeArea widget to avoid system overlaps.
                    child: SafeArea(
                      top: false,
                      child: CupertinoPicker(
                        magnification: 1.22,
                        squeeze: 1.2,
                        useMagnifier: true,
                        itemExtent: 32,
                        onSelectedItemChanged: (int selectedItem) {
                          setState(() {
                            categoryText =
                                widget.pickList.values.elementAt(selectedItem);
                          });

                          widget.onSelectedItemChanged(
                              widget.pickList.keys.toList()[selectedItem]);
                        },
                        children: List<Widget>.generate(widget.pickList.length,
                            (int index) {
                          return Center(
                            child: Text(
                              widget.pickList.values.elementAt(index),
                              style: widget.style,
                            ),
                          );
                        }),
                      ),
                    ),
                  ));
        }),
        child: Text(
          categoryText,
          style: widget.style,
        ),
      ),
    );
  }
}
