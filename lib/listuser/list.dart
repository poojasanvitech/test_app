class Userlist {
  int? id;
  String? title;
  String? description;
  Userlist(this.title, this.description, {this.id});
  Userlist.fromJson(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    description = map['description'];
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}
