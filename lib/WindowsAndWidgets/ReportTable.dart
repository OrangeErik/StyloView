import 'package:flutter/material.dart';
import 'package:StyloView/functional/elements.dart';

class ReportTable extends StatefulWidget {
	ReportTable(ReportTableSource pSource, List<DataColumn> pColumns, Widget pTableHeader) : _source     = pSource,
																						   _columns    = pColumns,
																						   _tableHeader= pTableHeader;

  @override
  _ReportTableState createState() => _ReportTableState();

	final Widget   _tableHeader;
	final List<DataColumn> _columns;
	final ReportTableSource  _source;
}

class _ReportTableState extends State<ReportTable> {
	@override Widget build(BuildContext context)
	{
		return Padding(
		  padding: const EdgeInsets.symmetric(vertical: 3.0),
		  child: SingleChildScrollView(
		  	child: PaginatedDataTable(
		  		header: widget._tableHeader,
		  		columnSpacing: 15.0,
		  		rowsPerPage: _rowsPerPage,
		  		availableRowsPerPage: <int>[10, 25, 50, widget._source.rowCount],
		  		onRowsPerPageChanged: (int value) {
		  			changeRowsPerPage(value);
		  		},
		  		columns: widget._columns,
		  		source: widget._source,
		  	),
		  ),
		);
	}

	void changeRowsPerPage(int newrperP){
		setState((){
			_rowsPerPage = newrperP;
		});
	}

	int _rowsPerPage = 25;
}