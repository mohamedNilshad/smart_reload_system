
part of 'history.bloc.dart';

abstract class HistoryEvent{}

class FetchAllHistoryEvent extends HistoryEvent{}

class SaveHistoryEvent extends HistoryEvent{
  final CodeHistory history;
  SaveHistoryEvent({required this.history});
}

class RenameHistoryEvent extends HistoryEvent{
  final int id;
  final String newName;
  RenameHistoryEvent({required this.id, required this.newName});
}

class DeleteHistoryEvent extends HistoryEvent{
  final int id;
  DeleteHistoryEvent({required this.id});
}

class UpdateHistoryEvent extends HistoryEvent{
  final CodeHistory history;
  UpdateHistoryEvent({required this.history});
}