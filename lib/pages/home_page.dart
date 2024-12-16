import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tuto_firebase/services/firestore.dart';

class HomePage extends StatelessWidget {
  //Firestore service
  final FirestoreServices firestoreServices = FirestoreServices();

  //Text controller
  final TextEditingController textController = TextEditingController();

  void openNoteBox(BuildContext context, {String? docId}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // adding a new note
                    if (docId == null) {
                      firestoreServices.CreateNotes(textController.text);
                    }
                    // Updating a note
                    else {
                      firestoreServices.updateNote(docId, textController.text);
                    }

                    // clear the textcontroller
                    textController.clear();

                    //close the dialog box
                    Navigator.of(context).pop();
                  },
                  child: const Text("Ajouter"),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder(
          stream: firestoreServices.getNotesStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;

              return ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    //get every individual doc
                    DocumentSnapshot document = notesList[index];
                    String docId = document.id;

                    //get note from each doc
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String noteText = data['note'];

                    //display as a list tile
                    return ListTile(
                      title: Text(noteText),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // update button
                          IconButton(
                            onPressed: () => openNoteBox(context, docId: docId),
                            icon: const Icon(Icons.edit),
                          ),

                          // Delete button
                          IconButton(
                            onPressed: () =>
                                firestoreServices.deleteNote(docId),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    );
                  });
            } else {
              return const Text("no data");
            }
          }),
    );
  }
}
