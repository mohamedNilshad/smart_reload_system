
class Settings{
  final int? id;
  final int? bgColor;
  final int? fgColor;
  final double? padding;
  final double? edge;
  final double? boarderWidth;
  final bool? enableBoarder;
  final bool? continuesScan;
  final bool? autoRedirect;
  final int? boarderColor;

  Settings({
    this.id,
    required this.bgColor,
    required this.fgColor,
    required this.padding,
    required this.edge,
    required this.enableBoarder,
    required this.boarderWidth,
    required this.boarderColor,
    required this.continuesScan,
    required this.autoRedirect,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bgColor': bgColor,
      'fgColor': fgColor,
      'padding': padding,
      'edge': edge,
      'enableBoarder': enableBoarder != null && enableBoarder! ? 1 : 0,
      'boarderWidth': boarderWidth,
      'boarderColor': boarderColor,
      'continuesScan': continuesScan != null && continuesScan! ? 1 : 0,
      'autoRedirect': autoRedirect != null && autoRedirect! ? 1 : 0,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      id: map['id'],
      bgColor: map['bgColor'],
      fgColor: map['fgColor'],
      padding: map['padding'],
      edge: map['edge'],
      enableBoarder: map['enableBoarder'] == 1,
      boarderWidth: map['boarderWidth'],
      boarderColor: map['boarderColor'],
      continuesScan: map['continuesScan'] == 1,
      autoRedirect: map['autoRedirect'] == 1,
    );
  }
}