import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController TextController = TextEditingController();

  void openNoteBox({String? docID}){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: TextField(
            controller: TextController,
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  if(docID == null){
                    firestoreService.addNote(TextController.text);
                  } else{
                    firestoreService.updateNote(docID, TextController.text);
                  }

                  TextController.clear();

                  Navigator.pop(context);
    },
                child: const Text("Add")
            )
          ],
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        backgroundColor: Colors.lightBlue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
        backgroundColor: Colors.lightBlue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            List notesList = snapshot.data!.docs;

            return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index){
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;

                  Map<String, dynamic> data =
                      document.data() as Map<String,  dynamic>;
                  String noteText = data['note'];

                  return ListTile(
                    title: Text(noteText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //update
                        IconButton(
                          onPressed: () => openNoteBox(docID: docID),
                          icon: const Icon(Icons.settings),
                        ),

                        //delete
                        IconButton(
                          onPressed: () => firestoreService.deleteNote(docID),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    )
                  );
                }
            );
          }

          else{
            return const Text("no notes..");
          }
        },
      ),
    );
  }

  text(String s) {}
}