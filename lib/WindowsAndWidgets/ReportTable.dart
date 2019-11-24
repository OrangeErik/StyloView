import 'package:flutter/material.dart';
import 'package:StyloView/functional/elements.dart';
import 'package:provider/provider.dart' as p;

class ReportTable extends StatelessWidget {
	final Widget   TableHeader;
	final List<DataColumn> Columns;
	final DataTableSource  Source;
	ReportTable({@required this.Source, @required this.Columns, this.TableHeader});

	@override
	Widget build(BuildContext context) {
		return Padding(
		  padding: const EdgeInsets.symmetric(vertical: 3.0),
		  child: SingleChildScrollView(

		  	child: PaginatedDataTable(
		  		header: TableHeader,
		  		columnSpacing: 15.0,
		  		rowsPerPage: p.Provider.of<AppState>(context).RowsPerPage ?? 25,
		  		availableRowsPerPage: <int>[10, 25, 50],
		  		onRowsPerPageChanged: (int value) {
		  			p.Provider.of<AppState>(context).changeRowsPerPage(value);
		  		},
		  		columns: Columns,
		  		source: Source,
		  	),
		  ),
		);
	}
}