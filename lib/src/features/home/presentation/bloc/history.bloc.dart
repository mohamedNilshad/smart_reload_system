import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/features/home/data/models/code_history.dart';
import 'package:smart_reload_system/src/features/home/domain/usecases/delete_history.usecase.dart' as delete_history;
import 'package:smart_reload_system/src/features/home/domain/usecases/fetch_history.usecase.dart' as fetch_history;
import 'package:smart_reload_system/src/features/home/domain/usecases/rename_history.usecase.dart' as rename_history;
import 'package:smart_reload_system/src/features/home/domain/usecases/save_history.usecase.dart' as save_history;
import 'package:smart_reload_system/src/features/home/domain/usecases/update_history.usecase.dart' as update_history;
import 'package:smart_reload_system/src/injection_container.dart';

part 'history.event.dart';
part 'history.state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState>{

  final update_history.UpdateHistory _updateHistory = sl<update_history.UpdateHistory>();
  final fetch_history.FetchHistory _fetchHistory = sl<fetch_history.FetchHistory>();
  final save_history.SaveHistory _saveHistory = sl<save_history.SaveHistory>();
  final delete_history.DeleteHistory _deleteHistory = sl<delete_history.DeleteHistory>();
  final rename_history.RenameHistory _renameHistoryU = sl<rename_history.RenameHistory>();

  List<CodeHistory>? _histories;

  get histories => _histories;

  HistoryBloc() : super(InitialHistoryState()){
    on<DeleteHistoryEvent>((event, emit)async => _deleteSingleHistory(emit, event));
    on<UpdateHistoryEvent>((event, emit)async => _updateSingleHistory(emit, event));
    on<SaveHistoryEvent>((event, emit)async => _saveNewHistory(emit, event));
    on<FetchAllHistoryEvent>((event, emit)async => _fetchAllHistory(emit));
    on<RenameHistoryEvent>((event, emit)async => _renameHistory(emit, event));
  }


  Future _saveNewHistory(Emitter<HistoryState> emit, SaveHistoryEvent event)async{
    emit(LoadingHistoryState(isSave: true));
    Either<Failure, bool> result = await _saveHistory(save_history.Params(history: event.history));
    return result.fold((l) {
      emit(ErrorHistoryState(error: l.toString()));
      return;
    }, (bool r) async{
      emit(SaveHistoryStatusState(r));
    });
  }

  Future _fetchAllHistory(Emitter<HistoryState> emit)async{
    emit(LoadingHistoryState(isHistory: true));
    Either<Failure, List<CodeHistory>> result = await _fetchHistory(NoParams());
    return result.fold((l) {
      emit(ErrorHistoryState(error: l.toString()));
      return;
    }, (List<CodeHistory> h) {
      _histories = h;
      emit(LoadedCodeHistoryState(h));
      // print(_histories);
    });
  }

  Future _deleteSingleHistory(Emitter<HistoryState> emit, DeleteHistoryEvent event)async{
    emit(LoadingHistoryState(isDelete: true));

    Either<Failure, bool> result = await _deleteHistory(delete_history.Params(historyId: event.id));
    return result.fold((l) {
      emit(ErrorHistoryState(error: l.toString()));
      return;
    }, (bool r) async{
      emit(DeletedHistoryStatusSate(r));
      // if(r) {
      //   // emit(LoadedSingleHistoryState(history: _histories![event.index]));
      // }else{
      //   // emit(LoadedSingleHistoryState(history: histories![event.index]));
      // }
    });
  }

  Future _updateSingleHistory(Emitter<HistoryState> emit, UpdateHistoryEvent event)async{
    emit(LoadingHistoryState(isUpdate: true));
    Either<Failure, bool> result = await _updateHistory(update_history.Params(history: event.history));
    return result.fold((l) {
      // emit(LoadedSingleHistoryState(history: histories![event.index]));
      emit(ErrorHistoryState(error: l.toString()));
      return;
    }, (bool r) async{
      emit(UpdateHistoryStatusState(r));
    });
  }

  Future _renameHistory(Emitter<HistoryState> emit, RenameHistoryEvent event)async{
    emit(LoadingHistoryState(isRename: true));

    Either<Failure, bool> result = await _renameHistoryU(rename_history.Params(id: event.id, newName: event.newName));
    return result.fold((l) {
      emit(ErrorRenameState(error: l.toString()));
      return;
    }, (bool r) async{
      emit(RenameStatusState(r));
    });

  }
}