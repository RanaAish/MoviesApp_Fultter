class Film
{
  int id;
  int title;
  String path;
  Film(this.title,this.path);
  Film.withId(this.id,this.title,this.path);

  Film.ConvertFromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    path=map['path'];
  }

  Map<String, dynamic> ConvertToMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['title'] =title;
    map['path']=path;
    return map;
  }

  @override
  String toString() {
    return 'film{id: $id, id_film: $title}';
  }


}