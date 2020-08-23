class Recognition {
  final String id;
  final String project;
  final String iteration;
  final String created;
  final List predictions;

  Recognition(
      {this.id, this.project, this.iteration, this.created, this.predictions});

  factory Recognition.fromJson(Map<String, dynamic> json) {
    return Recognition(
      id: json['id'],
      project: json['project'],
      iteration: json['iteration'],
      created: json['created'],
      predictions: json['predictions'],
    );
  }

  @override
  String toString() {
    String text = "";
    for (var prediction in predictions) {
      //print(prediction);
      if (prediction['probability'] > 0.3) {
        text = text +
            prediction['tagName'] +
            " " +
            prediction['probability'].toString() +
            "\n";
      }
    }
    return text;
  }
}
