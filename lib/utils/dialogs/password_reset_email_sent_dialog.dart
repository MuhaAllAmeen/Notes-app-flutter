import 'package:flutter/material.dart';
import 'package:mynotes/utils/dialogs/generic_dialog.dart';

Future<void> showPasswordResetDialog(BuildContext context){
  return showGenericDialog<void>(context: context, title: "Reset Password", content: "An Email has been sent to reset your password", optionBuilder:() => {'OK':null});
}