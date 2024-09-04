import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../listuser/list.dart';
import '../services/database.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key, this.noteId});
  final int? noteId;

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final formKey = GlobalKey<FormState>();

  DatabaseHelper noteDatabase = DatabaseHelper.instance;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  late Userlist note;
  bool isLoading = false;
  bool isNewNote = false;

  @override
  void initState() {
    refreshNotes();
    super.initState();
  }

  refreshNotes() {
    if (widget.noteId == null) {
      setState(() {
        isNewNote = true;
      });
      return;
    }
    noteDatabase.read(widget.noteId!).then((value) {
      setState(() {
        note = value;
        titleController.text = note.title!;
        descriptionController.text = note.description!;
      });
    });
  }

  insert(Userlist model) {
    noteDatabase.insert(model).then((respond) async {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Note successfully added.", style: GoogleFonts.lato(
            fontStyle: FontStyle.normal, fontSize: 14, color: Colors.black),
        ),
        backgroundColor: Color.fromARGB(255, 4, 160, 74),
      ));
      Navigator.pop(context, {
        'reload': true,
      });
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Note failed to save."),
        backgroundColor: Color.fromARGB(255, 235, 108, 108),
      ));
    });
  }

  update(Userlist model) {
    noteDatabase.update(model).then((respond) async {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Note successfully updated.",
          style: GoogleFonts.lato(
              fontStyle: FontStyle.normal, fontSize: 14, color: Colors.black),
        ),
        backgroundColor: Color.fromARGB(255, 4, 160, 74),
      ));
      Navigator.pop(context, {
        'reload': true,
      });
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Note failed to update.",
          style: GoogleFonts.lato(
              fontStyle: FontStyle.normal, fontSize: 14, color: Colors.black),
        ),
        backgroundColor: Color.fromARGB(255, 235, 108, 108),
      ));
    });
  }

  createNote() async {
    setState(() {
      isLoading = true;
    });

    if (formKey.currentState != null && formKey.currentState!.validate()) {
      formKey.currentState?.save();

      Userlist model =
          Userlist(titleController.text, descriptionController.text);

      if (isNewNote) {
        insert(model);
      } else {
        model.id = note.id;
        update(model);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  deleteNote() {
    noteDatabase.delete(note.id!);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Note successfully deleted."),
      backgroundColor: Color.fromARGB(255, 235, 108, 108),
    ));
    Navigator.pop(context);
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a name.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          isNewNote ? 'Add a User Details' : 'Edit User Details',
          style: GoogleFonts.lato(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors
                  .black),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "Enter the Name",
                        hintStyle: GoogleFonts.lato(
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Colors.black),
                        labelText: 'User Name',
                        labelStyle: GoogleFonts.lato(
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                      ),
                      validator: validateTitle,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        hintText: "Enter the description",
                        hintStyle: GoogleFonts.lato(
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Colors.black),
                        labelText: 'Description',
                        labelStyle: GoogleFonts.lato(
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Colors.black),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 0.75,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            )),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 2,
                    ),
                  ],
                ),

                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: createNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(94, 114, 228, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                    child: Text(
                      "Save",
                      style: GoogleFonts.lato(
                          fontStyle: FontStyle.normal,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(20),
                    child: Visibility(
                      visible: !isNewNote,
                      child: ElevatedButton(
                        onPressed: deleteNote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.all(8),
                        ),
                        child: Text(
                          "Delete",
                          style: GoogleFonts.lato(
                              fontStyle: FontStyle.normal,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
