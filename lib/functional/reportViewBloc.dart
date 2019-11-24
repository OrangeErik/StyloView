import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

abstract class ReportViewEvent{}
class LoadReport extends ReportViewEvent{
	LoadReport({this.View});
	Widget View;
}
class CleanReport extends ReportViewEvent{}

class ReportViewState{
	final Widget ViewReport;
	ReportViewState({this.ViewReport});
	factory ReportViewState.initial() => ReportViewState(ViewReport: Center(child: Image.asset("images/PPY_IMAGE1.png")));
}

class ReportViewBloc extends Bloc<ReportViewEvent, ReportViewState>{
	@override
	ReportViewState get initialState => ReportViewState.initial();

	@override
	Stream<ReportViewState> mapEventToState(ReportViewEvent event) async*{
		if(event is LoadReport){
			yield ReportViewState(ViewReport: event.View);

		}
		else if(event is CleanReport){
			yield ReportViewState.initial();
		}
	}

}