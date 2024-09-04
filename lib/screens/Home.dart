import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:test_app/screens/AddUser.dart';
import '../listuser/list.dart';
import '../services/database.dart';

class Home extends StatefulWidget {
  final String title;

  const Home({super.key, required this.title});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseHelper noteDatabase = DatabaseHelper.instance;
  List<Userlist> users = [];

  TextEditingController searchController = TextEditingController();
  bool isSearchTextNotEmpty = false;
  List<Userlist> filteredNotes = [];

  @override
  void initState() {
    refreshNotes();
    search();
    super.initState();
  }

  @override
  dispose() {
    noteDatabase.close();
    super.dispose();
  }

  search() {
    searchController.addListener(() {
      setState(() {
        isSearchTextNotEmpty = searchController.text.isNotEmpty;
        if (isSearchTextNotEmpty) {
          filteredNotes = users.where((note) {
            return note.title!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()) ||
                note.description!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase());
          }).toList();
        } else {
          filteredNotes.clear();
        }
      });
    });
  }

  refreshNotes() {
    noteDatabase.getAll().then((value) {
      setState(() {
        users = value;
      });
    });
  }

  goToNoteDetailsView({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddUserPage(noteId: id)),
    );
    refreshNotes();
  }

  deleteNote({int? id}) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Delete permanently!',
              style: GoogleFonts.lato(
                  fontStyle: FontStyle.normal,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'Are you sure, you want to delete this user?',
                    style: GoogleFonts.lato(
                        fontStyle: FontStyle.normal,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)),
                onPressed: () async {
                  await noteDatabase.delete(id!);
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      "Note successfully deleted.",
                      style: GoogleFonts.lato(
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Colors.black),
                    ),
                    backgroundColor: Color.fromARGB(255, 235, 108, 108),
                  ));
                  refreshNotes();
                },
                child: Text(
                  'Yes',
                  style: GoogleFonts.lato(
                      fontStyle: FontStyle.normal,
                      fontSize: 18,
                      color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'No',
                  style: GoogleFonts.lato(
                      fontStyle: FontStyle.normal,
                      fontSize: 18,
                      color: Colors.black),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/img.png'),
                    radius: 25,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello!',
                        style: GoogleFonts.lato(
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                      Text(
                        'Livia Vaccaro',
                        style: GoogleFonts.lato(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  Spacer(),
                  Image(
                    image: AssetImage('assets/images/notification.png'),
                    height: 30,
                    width: 30,
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: 10),
                        Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: VerticalDivider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: 'Search Users...',
                              hintStyle: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: Colors
                                      .grey.shade500), // Apply GoogleFonts.lato
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {
                                isSearchTextNotEmpty = value.isNotEmpty;
                              });
                            },
                          ),
                        ),
                        if (isSearchTextNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                isSearchTextNotEmpty = false;
                                filteredNotes.clear();
                                refreshNotes();
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        child: users.isEmpty
                            ? Center(
                                child: Text(
                                  "No records to display",
                                  style: GoogleFonts.lato(
                                      fontStyle: FontStyle.normal,
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                              )
                            : Column(
                                children: [
                                  if (isSearchTextNotEmpty)
                                    ...filteredNotes.map((note) {
                                      return buildNoteCard(note);
                                    }).toList()
                                  else
                                    ...users.map((note) {
                                      return buildNoteCard(note);
                                    }).toList(),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: goToNoteDetailsView,
        tooltip: 'Create Note',
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget buildNoteCard(Userlist note) {
    return Card(
      child: GestureDetector(
        onTap: () => {},
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade400,
            child: Icon(
              Icons.person,
              color: Colors.black,
            ),
          ),
          title: Text(
            note.title ?? "",
            style: GoogleFonts.lato(
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black),
          ),
          subtitle: Text(
            note.description ?? "",
            style: GoogleFonts.lato(
                fontStyle: FontStyle.normal, fontSize: 16, color: Colors.black),
          ),
          trailing: Wrap(
            children: [
              IconButton(
                onPressed: () => goToNoteDetailsView(id: note.id),
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
              ),
              IconButton(
                onPressed: () => deleteNote(id: note.id),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
