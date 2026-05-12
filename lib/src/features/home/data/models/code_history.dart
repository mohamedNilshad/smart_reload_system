
class CodeHistory{
  final int? id;
  final String content;
  final String codeType;
  final String contentType;
  final int bgColor;
  final int fgColor;
  final double size;
  final String saveName;
  final String modifiedDate;
  final String createdDate;
  final double padding;
  final double edge;
  final double? boarderWidth;
  final bool enableBoarder;
  final int? boarderColor;

  CodeHistory({
    this.id,
    required this.content,
    required this.codeType,
    required this.contentType,
    required this.bgColor,
    required this.fgColor,
    required this.size,
    required this.saveName,
    required this.modifiedDate,
    required this.createdDate,
    required this.padding,
    required this.edge,
    required this.enableBoarder,
    this.boarderWidth,
    this.boarderColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'codeType': codeType,
      'contentType': contentType,
      'bgColor': bgColor,
      'fgColor': fgColor,
      'size': size,
      'padding': padding,
      'edge': edge,
      'enableBoarder': enableBoarder,
      'boarderWidth': boarderWidth,
      'boarderColor': boarderColor,
      'saveName': saveName,
      'modifiedDate': modifiedDate,
      'createdDate': createdDate,
    };
  }

  factory CodeHistory.fromMap(Map<String, dynamic> map) {
    return CodeHistory(
      id: map['id'],
      content: map['content'],
      codeType: map['codeType'],
      contentType: map['contentType'],
      bgColor: map['bgColor'],
      fgColor: map['fgColor'],
      saveName: map['saveName'],
      size: map['size'],
      padding: map['padding'],
      edge: map['edge'],
      enableBoarder: map['enableBoarder'] == 1,
      boarderWidth: map['boarderWidth'],
      boarderColor: map['boarderColor'],
      modifiedDate: map['modifiedDate'],
      createdDate: map['createdDate'],
    );
  }
}