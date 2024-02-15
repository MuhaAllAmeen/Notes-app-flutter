import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
@immutable
class CloudNote{
  final String documentId;
  final String ownerUserId;
  final String text;
  final DateTime dateTime;

   const CloudNote({required this.dateTime, required this.documentId, required this.ownerUserId, required this.text});
   CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String,dynamic>> snapshot) :
    documentId = snapshot.id,
    ownerUserId = snapshot.data()['user_id'],
    text = snapshot.data()['text'] as String,
    dateTime = snapshot.data()['date_time'].toDate() as DateTime ;
 }