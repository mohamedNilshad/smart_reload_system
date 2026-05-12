part of 'history.bloc.dart';

abstract class HistoryState {}

class InitialHistoryState extends HistoryState {}

class LoadingHistoryState extends HistoryState {
  final bool isDelete;
  final bool isUpdate;
  final bool isSave;
  final bool isRename;
  final bool isHistory;
  LoadingHistoryState({this.isDelete = false, this.isHistory = false, this.isUpdate = false, this.isSave = false, this.isRename = false});
}

class LoadedHistoryState extends HistoryState {
  final List<CodeHistory> history;
  LoadedHistoryState(this.history);
}

class LoadedCodeHistoryState extends HistoryState {
  final List<CodeHistory> history;
  LoadedCodeHistoryState(this.history);
}

class LoadedSingleHistoryState extends HistoryState {
  final CodeHistory? history;
  final bool isDeleteLoading;
  LoadedSingleHistoryState({this.history, this.isDeleteLoading = false});
}

class SaveHistoryStatusState extends HistoryState {
  final bool status;
  SaveHistoryStatusState(this.status);
}

class UpdateHistoryStatusState extends HistoryState {
  final bool status;
  UpdateHistoryStatusState(this.status);
}

class RenameStatusState extends HistoryState {
  final bool status;
  RenameStatusState(this.status);
}

class DeletedHistoryStatusSate extends HistoryState {
  final bool status;
  DeletedHistoryStatusSate(this.status);
}

class ErrorHistoryState extends HistoryState {
  final String error;
  ErrorHistoryState({required this.error});
}

class ErrorRenameState extends HistoryState {
  final String error;
  ErrorRenameState({required this.error});
}
