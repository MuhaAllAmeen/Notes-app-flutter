import 'package:flutter/material.dart';
import 'package:mynotes/utils/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context){
  return showGenericDialog<bool>(context: context, title: "LogOut", content: "Are you sure you want to Log out?", optionBuilder:() => {'Cancel':false,'Log Out':true}).then((value) => value??false);
}