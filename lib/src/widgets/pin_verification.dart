import 'dart:async';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PINVerification extends StatefulWidget {
  final String title;
  final String subTitle;
  final String invalidMessage;
  final Future<bool> Function(String) validateOtp;
  final void Function(BuildContext) onValidateSuccess;
  final void Function(BuildContext) onInvalid;
  Color? topColor;
  Color? bottomColor;
  bool secured;
  late bool _isGradientApplied;
  final Color? titleColor;
  final Color? themeColor;
  final Color? keyboardBackgroundColor;
  final Widget? icon;
  final Widget? action;

  /// default [otpLength] is 4
  final int otpLength;

  PINVerification({
    Key? key,
    this.title = "Verification Code",
    this.subTitle = "Please enter the OTP sent to your\n device",
    this.invalidMessage = "Invalid code",
    this.otpLength = 4,
    required this.validateOtp,
    required this.onValidateSuccess,
    required this.onInvalid,
    this.themeColor = Colors.black,
    this.titleColor = Colors.black,
    this.keyboardBackgroundColor,
    this.icon,
    this.secured = false,
    this.action,
  }) : super(key: key) {
    _isGradientApplied = false;
  }

  PINVerification.withGradientBackground({
    Key? key,
    this.title = "Verification Code",
    this.subTitle = "please enter the OTP sent to your\n device",
    this.invalidMessage = "Invalid code",
    this.otpLength = 4,
    required this.validateOtp,
    required this.onValidateSuccess,
    required this.onInvalid,
    this.themeColor = Colors.white,
    this.titleColor = Colors.white,
    required this.topColor,
    required this.bottomColor,
    this.keyboardBackgroundColor,
    this.icon,
    this.secured = false,
    this.action,
  }) : super(key: key) {
    _isGradientApplied = true;
  }

  @override
  PINVerificationState createState() => PINVerificationState();
}

class PINVerificationState extends State<PINVerification>
    with SingleTickerProviderStateMixin {
  late Size _screenSize;
  late int _currentDigit;
  late List<int?> otpValues;
  bool showLoadingButton = false;
  bool showError = false;

  @override
  void initState() {
    otpValues = List<int?>.filled(widget.otpLength, null, growable: false);
    super.initState();
  }

  /// Return Title label
  Widget get _getTitleText {
    return Text(
      widget.title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20.0,
        color: widget.titleColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Return subTitle label
  Widget get _getSubtitleText {
    return Text(
      widget.subTitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14.0,
        color: widget.titleColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Return "OTP" input fields
  Widget get _getInputField {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: getOtpTextWidgetList(),
    );
  }

  Widget get _getInvalidMessage {
    return Text(
      widget.invalidMessage,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12.0,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Returns otp fields of length [widget.otpLength]
  List<Widget> getOtpTextWidgetList() {
    List<Widget> optList = List<Widget>.empty(growable: true);
    for (int i = 0; i < widget.otpLength; i++) {
      optList.add(_otpTextField(otpValues[i]));
    }
    return optList;
  }

  /// Returns Otp screen views
  Widget get _getInputPart {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        widget.icon != null
            ? IconButton(
                icon: widget.icon!,
                iconSize: 80,
                onPressed: () {},
              )
            : const SizedBox(
                width: 0,
                height: 0,
              ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _getTitleText,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _getSubtitleText,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _getInputField,
        ),
        showLoadingButton
            ? const Center(child: CircularProgressIndicator())
            : const SizedBox(
                width: 0,
                height: 0,
              ),
        widget.action != null ? widget.action! : const SizedBox(),
        showError
            ? _getInvalidMessage
            : const SizedBox(
                width: 0,
                height: 0,
              ),
        _getOtpKeyboard
      ],
    );
  }

  /// Returns "Otp" keyboard
  Widget get _getOtpKeyboard {
    return Container(
        color: widget.keyboardBackgroundColor,
        height: _screenSize.width - 100,
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _otpKeyboardInputButton(
                    label: "1",
                    onPressed: () {
                      _setCurrentDigit(1);
                    }),
                _otpKeyboardInputButton(
                    label: "2",
                    onPressed: () {
                      _setCurrentDigit(2);
                    }),
                _otpKeyboardInputButton(
                    label: "3",
                    onPressed: () {
                      _setCurrentDigit(3);
                    }),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _otpKeyboardInputButton(
                    label: "4",
                    onPressed: () {
                      _setCurrentDigit(4);
                    }),
                _otpKeyboardInputButton(
                    label: "5",
                    onPressed: () {
                      _setCurrentDigit(5);
                    }),
                _otpKeyboardInputButton(
                    label: "6",
                    onPressed: () {
                      _setCurrentDigit(6);
                    }),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _otpKeyboardInputButton(
                    label: "7",
                    onPressed: () {
                      _setCurrentDigit(7);
                    }),
                _otpKeyboardInputButton(
                    label: "8",
                    onPressed: () {
                      _setCurrentDigit(8);
                    }),
                _otpKeyboardInputButton(
                    label: "9",
                    onPressed: () {
                      _setCurrentDigit(9);
                    }),
              ],
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const SizedBox(
                    width: 80.0,
                  ),
                  _otpKeyboardInputButton(
                      label: "0",
                      onPressed: () {
                        _setCurrentDigit(0);
                      }),
                  _otpKeyboardActionButton(
                      label: Icon(
                        Icons.backspace,
                        color: widget.themeColor,
                      ),
                      onPressed: () {
                        setState(() {
                          for (int i = widget.otpLength - 1; i >= 0; i--) {
                            if (otpValues[i] != null) {
                              otpValues[i] = null;
                              break;
                            }
                          }
                        });
                      }),
                ],
              ),
            ),
          ],
        ));
  }

  /// Returns "Otp text field"
  Widget _otpTextField(int? digit) {
    return Container(
      width: 35.0,
      height: 45.0,
      alignment: Alignment.center,
      child: Text(
        digit != null ? (!widget.secured ? digit.toString() : '\u25CF') : '',
        style: TextStyle(
          fontSize: 20.0,
          color: widget.titleColor,
        ),
      ),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        width: 2.0,
        color: widget.titleColor!,
      ))),
    );
  }

  /// Returns "Otp keyboard input Button"
  Widget _otpKeyboardInputButton(
      {required String label, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40.0),
        child: Container(
          height: 80.0,
          width: 80.0,
          decoration: const BoxDecoration(
            shape: BoxShape.rectangle,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 30.0,
                color: widget.themeColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Returns "Otp keyboard action Button"
  Widget _otpKeyboardActionButton(
      {required Widget label, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40.0),
      child: Container(
        height: 80.0,
        width: 80.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: label,
        ),
      ),
    );
  }

  /// sets number into text fields n performs
  ///  validation after last number is entered
  void _setCurrentDigit(int i) async {
    _currentDigit = i;
    int currentField;
    for (currentField = 0; currentField < widget.otpLength; currentField++) {
      if (otpValues[currentField] == null) {
        otpValues[currentField] = _currentDigit;
        break;
      }
    }

    setState(() {});

    if (currentField == widget.otpLength - 1) {
      showLoadingButton = true;
      String otp = otpValues.join();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      widget.validateOtp(otp).then((value) {
        showLoadingButton = false;
        if (value) {
          widget.onValidateSuccess(context);
        } else {
          showError = true;
          widget.onInvalid(context);
        }
      });
    }
  }

  ///to clear otp when error occurs
  void clearOtp() {
    otpValues = List<int?>.filled(widget.otpLength, null, growable: false);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
        height: _screenSize.height,
        decoration: widget._isGradientApplied
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.topColor!, widget.bottomColor!],
                  begin: FractionalOffset.topLeft,
                  end: FractionalOffset.bottomRight,
                  stops: const [0, 1],
                  tileMode: TileMode.clamp,
                ),
              )
            : const BoxDecoration(color: Colors.white),
        width: _screenSize.width,
        child: _getInputPart,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
