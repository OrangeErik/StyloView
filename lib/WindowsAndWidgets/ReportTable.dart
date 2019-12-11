import 'package:StyloView/WindowsAndWidgets/paginated_data_table_erik.dart';
import 'package:flutter/material.dart';
import 'package:StyloView/functional/elements.dart';
import 'package:provider/provider.dart' as p;

class ReportTable extends StatefulWidget {
	@override
	_ReportTableState createState() => _ReportTableState();
}

class _ReportTableState extends State<ReportTable> {
	@override void initState()
	{
		super.initState();

	}

	@override
	void didChangeDependencies() {
		AppState state = p.Provider.of<AppState>(context);
		TableHeader = state.TableHeader;
		RowPerPageVarinats = RowPerPageQuantityCalculation(state.Source.rowCount);
		ReportRowsPerPage = RowPerPageVarinats.last;
		SortColumnIndex = state.SortColumnIndex;
		SortAscending = state.SortAscending;
		Columns = state.Columns;
		Source = state.Source;
		super.didChangeDependencies();
	}

	@override Widget build(BuildContext context)
	{
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 3.0),
			child: SingleChildScrollView(
				child: PaginatedDataTableErik(
					header: TableHeader,
					columnSpacing: 15.0,
					rowsPerPage: ReportRowsPerPage,
					availableRowsPerPage: RowPerPageVarinats,
					onRowsPerPageChanged: (int value)=>ChangeRowsPerPage(value),
					sortColumnIndex: SortColumnIndex,
					sortAscending: SortAscending,
					columns: Columns,
					source: Source,
					dataRowHeight: 30.0,
					headingRowHeight: 40.0,
				),
			),
		);
	}

	List<int> RowPerPageQuantityCalculation(int rowCount)
	{
		List<int> row_quantity_variants;
		if(rowCount <= 25) {
			row_quantity_variants = [25];
		}
		else{
			if(rowCount <= 50)
				row_quantity_variants = [10, 25, rowCount];
			else
				row_quantity_variants = [10, 25, 50, rowCount];
		}
		return row_quantity_variants;
	}

	void ChangeRowsPerPage(int newrperP)
	{
		setState(()=>ReportRowsPerPage = newrperP);
	}

	ReportTableSource Source;
	List<DataColumnErik> Columns;
	int SortColumnIndex;
	bool SortAscending;
	int ReportRowsPerPage;
	List<int> RowPerPageVarinats;
	Widget TableHeader;
}

//Именно в таком виде выводятся строки таблицу PeginatedDataTable. Они все должны быть обебрнуты в этот класс
class ReportTableSource extends DataTableSourceErik {
	ReportTableSource(this._Lines, this._numColumns);

	//берем каждый элемент _strings и выводим в наш виджет.
	//причем кол-во выводимых полей в строке всегда равно кол-ву колонок
	@override DataRowErik getRow(int index)
	{
		//В виде DataCell выводятся данные. Это функция - преобразователь
		List<DataCellErik> toDataCellList(TRow str, int numColumns){
			List<DataCellErik> data_cell = [];
			for(int i = 0; i < numColumns; i++){
				data_cell.add(DataCellErik(
					Text('${str.StrItem[i]}'),
				));
			}
			return data_cell;
		}

		assert(index >= 0);
		if (index >= _Lines.length)
			return null;
		final TRow string = _Lines[index];
		return DataRowErik(
			selected: string.Selected,
			onSelectChanged: (bool value) {
				_selectedCount += value ? 1 : -1;
				string.Selected = value;
				notifyListeners();
			},
			cells: toDataCellList(string, _numColumns));
	}
	@override int  get rowCount => _Lines.length;
	@override bool get isRowCountApproximate => false;
	@override int  get selectedRowCount => _selectedCount;

	void Sort<T>(Comparable<T> getField(TRow d), bool ascending) {
		_Lines.sort((TRow a, TRow b) {
			if (!ascending) {
				final TRow c = a;
				a = b;
				b = c;
			}
			final Comparable<T> aValue = getField(a);
			final Comparable<T> bValue = getField(b);
			return Comparable.compare(aValue, bValue);
		});
		notifyListeners();
	}

	int _selectedCount = 0;
	List<TRow> _Lines;
	final int _numColumns;
}

class TRow {// Data class. каждый объект этого класса - это строка в таблице
	TRow(this.StrItem);
	List StrItem;
	bool Selected = false;
}