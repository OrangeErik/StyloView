// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;

import 'package:flutter/material.dart';




abstract class DataTableSourceErik extends ChangeNotifier {
	/// Called to obtain the data about a particular row.
	///
	/// The [new DataRow.byIndex] constructor provides a convenient way to construct
	/// [DataRow] objects for this callback's purposes without having to worry about
	/// independently keying each row.
	///
	/// If the given index does not correspond to a row, or if no data is yet
	/// available for a row, then return null. The row will be left blank and a
	/// loading indicator will be displayed over the table. Once data is available
	/// or once it is firmly established that the row index in question is beyond
	/// the end of the table, call [notifyListeners].
	///
	/// Data returned from this method must be consistent for the lifetime of the
	/// object. If the row count changes, then a new delegate must be provided.
	DataRowErik getRow(int index);

	/// Called to obtain the number of rows to tell the user are available.
	///
	/// If [isRowCountApproximate] is false, then this must be an accurate number,
	/// and [getRow] must return a non-null value for all indices in the range 0
	/// to one less than the row count.
	///
	/// If [isRowCountApproximate] is true, then the user will be allowed to
	/// attempt to display rows up to this [rowCount], and the display will
	/// indicate that the count is approximate. The row count should therefore be
	/// greater than the actual number of rows if at all possible.
	///
	/// If the row count changes, call [notifyListeners].
	int get rowCount;

	/// Called to establish if [rowCount] is a precise number or might be an
	/// over-estimate. If this returns true (i.e. the count is approximate), and
	/// then later the exact number becomes available, then call
	/// [notifyListeners].
	bool get isRowCountApproximate;

	/// Called to obtain the number of rows that are currently selected.
	///
	/// If the selected row count changes, call [notifyListeners].
	int get selectedRowCount;
}





/// A material design data table that shows data using multiple pages.
///
/// A paginated data table shows [rowsPerPage] rows of data per page and
/// provides controls for showing other pages.
///
/// Data is read lazily from from a [DataTableSourceErik]. The widget is presented
/// as a [Card].
///
/// See also:
///
///  * [DataTableErik], which is not paginated.
///  * <https://material.io/go/design-data-tables#data-tables-tables-within-cards>
class PaginatedDataTableErik extends StatefulWidget {
	/// Creates a widget describing a paginated [DataTableErik] on a [Card].
	///
	/// The [header] should give the card's header, typically a [Text] widget. It
	/// must not be null.
	///
	/// The [columns] argument must be a list of as many [DataColumnErik] objects as
	/// the table is to have columns, ignoring the leading checkbox column if any.
	/// The [columns] argument must have a length greater than zero and cannot be
	/// null.
	///
	/// If the table is sorted, the column that provides the current primary key
	/// should be specified by index in [sortColumnIndex], 0 meaning the first
	/// column in [columns], 1 being the next one, and so forth.
	///
	/// The actual sort order can be specified using [sortAscending]; if the sort
	/// order is ascending, this should be true (the default), otherwise it should
	/// be false.
	///
	/// The [source] must not be null. The [source] should be a long-lived
	/// [DataTableSourceErik]. The same source should be provided each time a
	/// particular [PaginatedDataTableErik] widget is created; avoid creating a new
	/// [DataTableSourceErik] with each new instance of the [PaginatedDataTableErik]
	/// widget unless the data table really is to now show entirely different
	/// data from a new source.
	///
	/// The [rowsPerPage] and [availableRowsPerPage] must not be null (they
	/// both have defaults, though, so don't have to be specified).
	PaginatedDataTableErik({
		Key key,
		@required this.header,
		this.actions,
		@required this.columns,
		this.sortColumnIndex,
		this.sortAscending = true,
		this.onSelectAll,
		this.dataRowHeight = kMinInteractiveDimension,
		this.headingRowHeight = 56.0,
		this.horizontalMargin = 24.0,
		this.columnSpacing = 56.0,
		this.initialFirstRowIndex = 0,
		this.onPageChanged,
		this.rowsPerPage = defaultRowsPerPage,
		this.availableRowsPerPage = const <int>[defaultRowsPerPage, defaultRowsPerPage * 2, defaultRowsPerPage * 5, defaultRowsPerPage * 10],
		this.onRowsPerPageChanged,
		this.dragStartBehavior = DragStartBehavior.start,
		@required this.source,
	}) : assert(header != null),
			assert(columns != null),
			assert(dragStartBehavior != null),
			assert(columns.isNotEmpty),
			assert(sortColumnIndex == null || (sortColumnIndex >= 0 && sortColumnIndex < columns.length)),
			assert(sortAscending != null),
			assert(dataRowHeight != null),
			assert(headingRowHeight != null),
			assert(horizontalMargin != null),
			assert(columnSpacing != null),
			assert(rowsPerPage != null),
			assert(rowsPerPage > 0),
			assert(() {
				if (onRowsPerPageChanged != null)
					assert(availableRowsPerPage != null && availableRowsPerPage.contains(rowsPerPage));
				return true;
			}()),
			assert(source != null),
			super(key: key);

	/// The table card's header.
	///
	/// This is typically a [Text] widget, but can also be a [ButtonBar] with
	/// [FlatButton]s. Suitable defaults are automatically provided for the font,
	/// button color, button padding, and so forth.
	///
	/// If items in the table are selectable, then, when the selection is not
	/// empty, the header is replaced by a count of the selected items.
	final Widget header;

	/// Icon buttons to show at the top right of the table.
	///
	/// Typically, the exact actions included in this list will vary based on
	/// whether any rows are selected or not.
	///
	/// These should be size 24.0 with default padding (8.0).
	final List<Widget> actions;

	/// The configuration and labels for the columns in the table.
	final List<DataColumnErik> columns;

	/// The current primary sort key's column.
	///
	/// See [DataTableErik.sortColumnIndex].
	final int sortColumnIndex;

	/// Whether the column mentioned in [sortColumnIndex], if any, is sorted
	/// in ascending order.
	///
	/// See [DataTableErik.sortAscending].
	final bool sortAscending;

	/// Invoked when the user selects or unselects every row, using the
	/// checkbox in the heading row.
	///
	/// See [DataTableErik.onSelectAll].
	final ValueSetter<bool> onSelectAll;

	/// The height of each row (excluding the row that contains column headings).
	///
	/// This value is optional and defaults to kMinInteractiveDimension if not
	/// specified.
	final double dataRowHeight;

	/// The height of the heading row.
	///
	/// This value is optional and defaults to 56.0 if not specified.
	final double headingRowHeight;

	/// The horizontal margin between the edges of the table and the content
	/// in the first and last cells of each row.
	///
	/// When a checkbox is displayed, it is also the margin between the checkbox
	/// the content in the first data column.
	///
	/// This value defaults to 24.0 to adhere to the Material Design specifications.
	final double horizontalMargin;

	/// The horizontal margin between the contents of each data column.
	///
	/// This value defaults to 56.0 to adhere to the Material Design specifications.
	final double columnSpacing;

	/// The index of the first row to display when the widget is first created.
	final int initialFirstRowIndex;

	/// Invoked when the user switches to another page.
	///
	/// The value is the index of the first row on the currently displayed page.
	final ValueChanged<int> onPageChanged;

	/// The number of rows to show on each page.
	///
	/// See also:
	///
	///  * [onRowsPerPageChanged]
	///  * [defaultRowsPerPage]
	final int rowsPerPage;

	/// The default value for [rowsPerPage].
	///
	/// Useful when initializing the field that will hold the current
	/// [rowsPerPage], when implemented [onRowsPerPageChanged].
	static const int defaultRowsPerPage = 10;

	/// The options to offer for the rowsPerPage.
	///
	/// The current [rowsPerPage] must be a value in this list.
	///
	/// The values in this list should be sorted in ascending order.
	final List<int> availableRowsPerPage;

	/// Invoked when the user selects a different number of rows per page.
	///
	/// If this is null, then the value given by [rowsPerPage] will be used
	/// and no affordance will be provided to change the value.
	final ValueChanged<int> onRowsPerPageChanged;

	/// The data source which provides data to show in each row. Must be non-null.
	///
	/// This object should generally have a lifetime longer than the
	/// [PaginatedDataTableErik] widget itself; it should be reused each time the
	/// [PaginatedDataTableErik] constructor is called.
	final DataTableSourceErik source;

	/// {@macro flutter.widgets.scrollable.dragStartBehavior}
	final DragStartBehavior dragStartBehavior;

	@override
	PaginatedDataTableErikState createState() => PaginatedDataTableErikState();
}

/// Holds the state of a [PaginatedDataTableErik].
///
/// The table can be programmatically paged using the [pageTo] method.
class PaginatedDataTableErikState extends State<PaginatedDataTableErik> {
	int _firstRowIndex;
	int _rowCount;
	bool _rowCountApproximate;
	int _selectedRowCount;
	final Map<int, DataRowErik> _rows = <int, DataRowErik>{};

	@override
	void initState() {
		super.initState();
		_firstRowIndex = PageStorage.of(context)?.readState(context) ?? widget.initialFirstRowIndex ?? 0;
		widget.source.addListener(_handleDataSourceChanged);
		_handleDataSourceChanged();
	}

	@override
	void didUpdateWidget(PaginatedDataTableErik oldWidget) {
		super.didUpdateWidget(oldWidget);
		if (oldWidget.source != widget.source) {
			oldWidget.source.removeListener(_handleDataSourceChanged);
			widget.source.addListener(_handleDataSourceChanged);
			_handleDataSourceChanged();
		}
	}

	@override
	void dispose() {
		widget.source.removeListener(_handleDataSourceChanged);
		super.dispose();
	}

	void _handleDataSourceChanged() {
		setState(() {
			_rowCount = widget.source.rowCount;
			_rowCountApproximate = widget.source.isRowCountApproximate;
			_selectedRowCount = widget.source.selectedRowCount;
			_rows.clear();
		});
	}

	/// Ensures that the given row is visible.
	void pageTo(int rowIndex) {
		final int oldFirstRowIndex = _firstRowIndex;
		setState(() {
			final int rowsPerPage = widget.rowsPerPage;
			_firstRowIndex = (rowIndex ~/ rowsPerPage) * rowsPerPage;
		});
		if ((widget.onPageChanged != null) &&
			(oldFirstRowIndex != _firstRowIndex))
			widget.onPageChanged(_firstRowIndex);
	}

	DataRowErik _getBlankRowFor(int index) {
		return DataRowErik.byIndex(
			index: index,
			cells: widget.columns.map<DataCellErik>((DataColumnErik column) => DataCellErik.empty).toList(),
		);
	}

	DataRowErik _getProgressIndicatorRowFor(int index) {
		bool haveProgressIndicator = false;
		final List<DataCellErik> cells = widget.columns.map<DataCellErik>((DataColumnErik column) {
			if (!column.numeric) {
				haveProgressIndicator = true;
				return const DataCellErik(CircularProgressIndicator());
			}
			return DataCellErik.empty;
		}).toList();
		if (!haveProgressIndicator) {
			haveProgressIndicator = true;
			cells[0] = const DataCellErik(CircularProgressIndicator());
		}
		return DataRowErik.byIndex(
			index: index,
			cells: cells,
		);
	}

	List<DataRowErik> _getRows(int firstRowIndex, int rowsPerPage) {
		final List<DataRowErik> result = <DataRowErik>[];
		final int nextPageFirstRowIndex = firstRowIndex + rowsPerPage;
		bool haveProgressIndicator = false;
		for (int index = firstRowIndex; index < nextPageFirstRowIndex; index += 1) {
			DataRowErik row;
			if (index < _rowCount || _rowCountApproximate) {
				row = _rows.putIfAbsent(index, () => widget.source.getRow(index));
				if (row == null && !haveProgressIndicator) {
					row ??= _getProgressIndicatorRowFor(index);
					haveProgressIndicator = true;
				}
			}
			row ??= _getBlankRowFor(index);
			result.add(row);
		}
		return result;
	}

	void _handlePrevious() {
		pageTo(math.max(_firstRowIndex - widget.rowsPerPage, 0));
	}

	void _handleNext() {
		pageTo(_firstRowIndex + widget.rowsPerPage);
	}

	final GlobalKey _tableKey = GlobalKey();

	@override
	Widget build(BuildContext context) {
		// TODO(ianh): This whole build function doesn't handle RTL yet.
		assert(debugCheckHasMaterialLocalizations(context));
		final ThemeData themeData = Theme.of(context);
		final MaterialLocalizations localizations = MaterialLocalizations.of(context);
		// HEADER
		final List<Widget> headerWidgets = <Widget>[];
		double startPadding = 24.0;
		if (_selectedRowCount == 0) {
			headerWidgets.add(Expanded(child: widget.header));
			if (widget.header is ButtonBar) {
				// We adjust the padding when a button bar is present, because the
				// ButtonBar introduces 2 pixels of outside padding, plus 2 pixels
				// around each button on each side, and the button itself will have 8
				// pixels internally on each side, yet we want the left edge of the
				// inside of the button to line up with the 24.0 left inset.
				// TODO(ianh): Better magic. See https://github.com/flutter/flutter/issues/4460
				startPadding = 12.0;
			}
		} else {
			headerWidgets.add(Expanded(
				child: Text(localizations.selectedRowCountTitle(_selectedRowCount)),
			));
		}
		if (widget.actions != null) {
			headerWidgets.addAll(
				widget.actions.map<Widget>((Widget action) {
					return Padding(
						// 8.0 is the default padding of an icon button
						padding: const EdgeInsetsDirectional.only(start: 24.0 - 8.0 * 2.0),
						child: action,
					);
				}).toList()
			);
		}

		// FOOTER
		final TextStyle footerTextStyle = themeData.textTheme.caption;
		final List<Widget> footerWidgets = <Widget>[];
		if (widget.onRowsPerPageChanged != null) {
			final List<Widget> availableRowsPerPage = widget.availableRowsPerPage
				.where((int value) => value <= _rowCount || value == widget.rowsPerPage)
				.map<DropdownMenuItem<int>>((int value) {
				return DropdownMenuItem<int>(
					value: value,
					child: Text('$value'),
				);
			})
				.toList();
			footerWidgets.addAll(<Widget>[
				Container(width: 14.0), // to match trailing padding in case we overflow and end up scrolling
				Text(localizations.rowsPerPageTitle),
				ConstrainedBox(
					constraints: const BoxConstraints(minWidth: 64.0), // 40.0 for the text, 24.0 for the icon
					child: Align(
						alignment: AlignmentDirectional.centerEnd,
						child: DropdownButtonHideUnderline(
							child: DropdownButton<int>(
								items: availableRowsPerPage,
								value: widget.rowsPerPage,
								onChanged: widget.onRowsPerPageChanged,
								style: footerTextStyle,
								iconSize: 24.0,
							),
						),
					),
				),
			]);
		}
		footerWidgets.addAll(<Widget>[
			Container(width: 32.0),
			Text(
				localizations.pageRowsInfoTitle(
					_firstRowIndex + 1,
					_firstRowIndex + widget.rowsPerPage,
					_rowCount,
					_rowCountApproximate,
				)
			),
			Container(width: 32.0),
			IconButton(
				icon: const Icon(Icons.chevron_left),
				padding: EdgeInsets.zero,
				tooltip: localizations.previousPageTooltip,
				onPressed: _firstRowIndex <= 0 ? null : _handlePrevious,
			),
			Container(width: 24.0),
			IconButton(
				icon: const Icon(Icons.chevron_right),
				padding: EdgeInsets.zero,
				tooltip: localizations.nextPageTooltip,
				onPressed: (!_rowCountApproximate && (_firstRowIndex + widget.rowsPerPage >= _rowCount)) ? null : _handleNext,
			),
			Container(width: 14.0),
		]);

		// CARD
		return Card(
			semanticContainer: false,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: <Widget>[
					Semantics(
						container: true,
						child: DefaultTextStyle(
							// These typographic styles aren't quite the regular ones. We pick the closest ones from the regular
							// list and then tweak them appropriately.
							// See https://material.io/design/components/data-tables.html#tables-within-cards
							style: _selectedRowCount > 0 ? themeData.textTheme.subhead.copyWith(color: themeData.accentColor)
								: themeData.textTheme.title.copyWith(fontWeight: FontWeight.w400),
							child: IconTheme.merge(
								data: const IconThemeData(
									opacity: 0.54
								),
								child: ButtonTheme.bar(
									child: Ink(
										height: 64.0,
										color: _selectedRowCount > 0 ? themeData.secondaryHeaderColor : null,
										child: Padding(
											padding: EdgeInsetsDirectional.only(start: startPadding, end: 14.0),
											child: Row(
												mainAxisAlignment: MainAxisAlignment.end,
												children: headerWidgets,
											),
										),
									),
								),
							),
						),
					),
					SingleChildScrollView(
						scrollDirection: Axis.horizontal,
						dragStartBehavior: widget.dragStartBehavior,
						child: DataTableErik(
							key: _tableKey,
							columns: widget.columns,
							sortColumnIndex: widget.sortColumnIndex,
							sortAscending: widget.sortAscending,
							onSelectAll: widget.onSelectAll,
							dataRowHeight: widget.dataRowHeight,
							headingRowHeight: widget.headingRowHeight,
							horizontalMargin: widget.horizontalMargin,
							columnSpacing: widget.columnSpacing,
							rows: _getRows(_firstRowIndex, widget.rowsPerPage),
						),
					),
					DefaultTextStyle(
						style: footerTextStyle,
						child: IconTheme.merge(
							data: const IconThemeData(
								opacity: 0.54
							),
							child: Container(
								height: 56.0,
								child: SingleChildScrollView(
									dragStartBehavior: widget.dragStartBehavior,
									scrollDirection: Axis.horizontal,
									reverse: true,
									child: Row(
										children: footerWidgets,
									),
								),
							),
						),
					),
				],
			),
		);
	}
}


class DataTableErik extends StatelessWidget {
	/// Creates a widget describing a data table.
	///
	/// The [columns] argument must be a list of as many [DataColumnErik]
	/// objects as the table is to have columns, ignoring the leading
	/// checkbox column if any. The [columns] argument must have a
	/// length greater than zero and must not be null.
	///
	/// The [rows] argument must be a list of as many [DataRowErik] objects
	/// as the table is to have rows, ignoring the leading heading row
	/// that contains the column headings (derived from the [columns]
	/// argument). There may be zero rows, but the rows argument must
	/// not be null.
	///
	/// Each [DataRowErik] object in [rows] must have as many [DataCellErik]
	/// objects in the [DataRowErik.cells] list as the table has columns.
	///
	/// If the table is sorted, the column that provides the current
	/// primary key should be specified by index in [sortColumnIndex], 0
	/// meaning the first column in [columns], 1 being the next one, and
	/// so forth.
	///
	/// The actual sort order can be specified using [sortAscending]; if
	/// the sort order is ascending, this should be true (the default),
	/// otherwise it should be false.
	DataTableErik({
		Key key,
		@required this.columns,
		this.sortColumnIndex,
		this.sortAscending = true,
		this.onSelectAll,
		this.dataRowHeight = kMinInteractiveDimension,
		this.headingRowHeight = 56.0,
		this.horizontalMargin = 24.0,
		this.columnSpacing = 56.0,
		@required this.rows,
	}) : assert(columns != null),
			assert(columns.isNotEmpty),
			assert(sortColumnIndex == null || (sortColumnIndex >= 0 && sortColumnIndex < columns.length)),
			assert(sortAscending != null),
			assert(dataRowHeight != null),
			assert(headingRowHeight != null),
			assert(horizontalMargin != null),
			assert(columnSpacing != null),
			assert(rows != null),
			assert(!rows.any((DataRowErik row) => row.cells.length != columns.length)),
			_onlyTextColumn = _initOnlyTextColumn(columns),
			super(key: key);

	/// The configuration and labels for the columns in the table.
	final List<DataColumnErik> columns;
	final int sortColumnIndex;
	final bool sortAscending;
	final ValueSetter<bool> onSelectAll;
	final double dataRowHeight;
	final double headingRowHeight;
	final double horizontalMargin;
	final double columnSpacing;
	final List<DataRowErik> rows;
	final int _onlyTextColumn;
	static int _initOnlyTextColumn(List<DataColumnErik> columns) {
		int result;
		for (int index = 0; index < columns.length; index += 1) {
			final DataColumnErik column = columns[index];
			if (!column.numeric) {
				if (result != null)
					return null;
				result = index;
			}
		}
		return result;
	}

	bool get _debugInteractive {
		return columns.any((DataColumnErik column) => column._debugInteractive)
			|| rows.any((DataRowErik row) => row._debugInteractive);
	}

	static final LocalKey _headingRowKey = UniqueKey();

	void _handleSelectAll(bool checked) {
		if (onSelectAll != null) {
			onSelectAll(checked);
		} else {
			for (DataRowErik row in rows) {
				if ((row.onSelectChanged != null) && (row.selected != checked))
					row.onSelectChanged(checked);
			}
		}
	}

	static const double _sortArrowPadding = 2.0;
	static const double _headingFontSize = 12.0;
	static const Duration _sortArrowAnimationDuration = Duration(milliseconds: 150);
	static const Color _grey100Opacity = Color(0x0A000000); // Grey 100 as opacity instead of solid color
	static const Color _grey300Opacity = Color(0x1E000000); // Dark theme variant is just a guess.

	Widget _buildCheckbox({
		Color color,
		bool checked,
		VoidCallback onRowTap,
		ValueChanged<bool> onCheckboxChanged,
	}) {
		Widget contents = Semantics(
			container: true,
			child: Padding(
				padding: EdgeInsetsDirectional.only(start: horizontalMargin, end: horizontalMargin / 2.0),
				child: Center(
					child: Checkbox(
						activeColor: color,
						value: checked,
						onChanged: onCheckboxChanged,
					),
				),
			),
		);
		if (onRowTap != null) {
			contents = TableRowInkWell(
				onTap: onRowTap,
				child: contents,
			);
		}
		return TableCell(
			verticalAlignment: TableCellVerticalAlignment.fill,
			child: contents,
		);
	}

	Widget _buildHeadingCell({
		BuildContext context,
		EdgeInsetsGeometry padding,
		Widget label,
		String tooltip,
		bool numeric,
		VoidCallback onSort,
		bool sorted,
		bool ascending,
	}) {
		if (onSort != null) {
			final Widget arrow = _SortArrowErik(
				visible: sorted,
				down: sorted ? ascending : null,
				duration: _sortArrowAnimationDuration,
			);
			const Widget arrowPadding = SizedBox(width: _sortArrowPadding);
			label = Row(
				textDirection: numeric ? TextDirection.rtl : null,
				children: <Widget>[ label, arrowPadding, arrow ],
			);
		}
		label = Container(
			padding: padding,
			height: headingRowHeight,
			alignment: numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
			child: AnimatedDefaultTextStyle(
				style: TextStyle(
					// TODO(ianh): font family should match Theme; see https://github.com/flutter/flutter/issues/3116
					fontWeight: FontWeight.w500,
					fontSize: _headingFontSize,
					height: math.min(1.0, headingRowHeight / _headingFontSize),
					color: (Theme.of(context).brightness == Brightness.light)
						? ((onSort != null && sorted) ? Colors.black87 : Colors.black54)
						: ((onSort != null && sorted) ? Colors.white : Colors.white70),
				),
				softWrap: false,
				duration: _sortArrowAnimationDuration,
				child: label,
			),
		);
		if (tooltip != null) {
			label = Tooltip(
				message: tooltip,
				child: label,
			);
		}
		if (onSort != null) {
			label = InkWell(
				onTap: onSort,
				child: label,
			);
		}
		return label;
	}

	Widget _buildDataCell({
		BuildContext context,
		EdgeInsetsGeometry padding,
		Widget label,
		bool numeric,
		bool placeholder,
		bool showEditIcon,
		VoidCallback onTap,
		VoidCallback onSelectChanged,
	}) {
		final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
		if (showEditIcon) {
			const Widget icon = Icon(Icons.edit, size: 18.0);
			label = Expanded(child: label);
			label = Row(
				textDirection: numeric ? TextDirection.rtl : null,
				children: <Widget>[ label, icon ],
			);
		}
		label = Container(
			padding: padding,
			height: dataRowHeight,
			alignment: numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
			child: DefaultTextStyle(
				style: TextStyle(
					// TODO(ianh): font family should be Roboto; see https://github.com/flutter/flutter/issues/3116
					fontSize: 13.0,
					color: isLightTheme
						? (placeholder ? Colors.black38 : Colors.black87)
						: (placeholder ? Colors.white38 : Colors.white70),
				),
				child: IconTheme.merge(
					data: IconThemeData(
						color: isLightTheme ? Colors.black54 : Colors.white70,
					),
					child: DropdownButtonHideUnderline(child: label),
				),
			),
		);
		if (onTap != null) {
			label = InkWell(
				onTap: onTap,
				child: label,
			);
		} else if (onSelectChanged != null) {
			label = TableRowInkWell(
				onTap: onSelectChanged,
				child: label,
			);
		}
		return label;
	}

	@override
	Widget build(BuildContext context) {
		assert(!_debugInteractive || debugCheckHasMaterial(context));
		final ThemeData theme = Theme.of(context);
		final BoxDecoration _kSelectedDecoration = BoxDecoration(
			border: Border(bottom: Divider.createBorderSide(context, width: 1.0)),
			// The backgroundColor has to be transparent so you can see the ink on the material
			color: (Theme.of(context).brightness == Brightness.light) ? _grey100Opacity : _grey300Opacity,
		);
		final BoxDecoration _kUnselectedDecoration = BoxDecoration(
			border: Border(bottom: Divider.createBorderSide(context, width: 1.0)),
		);
//    final bool showCheckboxColumn = rows.any((DataRowErik row) => row.onSelectChanged != null);
		bool showCheckboxColumn = false;
		final bool allChecked = showCheckboxColumn && !rows.any((DataRowErik row) => row.onSelectChanged != null && !row.selected);
		final List<TableColumnWidth> tableColumns = List<TableColumnWidth>(columns.length + (showCheckboxColumn ? 1 : 0));
		final List<TableRow> tableRows = List<TableRow>.generate(
			rows.length + 1, // the +1 is for the header row
				(int index) {
				return TableRow(
					key: index == 0 ? _headingRowKey : rows[index - 1].key,
					decoration: index > 0 && rows[index - 1].selected ? _kSelectedDecoration
						: _kUnselectedDecoration,
					children: List<Widget>(tableColumns.length),
				);
			},
		);
		int rowIndex;
		int displayColumnIndex = 0;
		if (showCheckboxColumn) {
			tableColumns[0] = FixedColumnWidth(horizontalMargin + Checkbox.width + horizontalMargin / 2.0);
			tableRows[0].children[0] = _buildCheckbox(
				color: theme.accentColor,
				checked: allChecked,
				onCheckboxChanged: _handleSelectAll,
			);
			rowIndex = 1;
			for (DataRowErik row in rows) {
				tableRows[rowIndex].children[0] = _buildCheckbox(
					color: theme.accentColor,
					checked: row.selected,
					onRowTap: () => row.onSelectChanged != null ? row.onSelectChanged(!row.selected) : null ,
					onCheckboxChanged: row.onSelectChanged,
				);
				rowIndex += 1;
			}
			displayColumnIndex += 1;
		}

		for (int dataColumnIndex = 0; dataColumnIndex < columns.length; dataColumnIndex += 1) {
			final DataColumnErik column = columns[dataColumnIndex];
			double paddingStart = 5.0;
//      if (dataColumnIndex == 0 && showCheckboxColumn) {
//        paddingStart = horizontalMargin / 2.0;
//      } else if (dataColumnIndex == 0 && !showCheckboxColumn) {
//        paddingStart = horizontalMargin;
//      } else {
//        paddingStart = columnSpacing / 2.0;
//      }
			double paddingEnd;
			if (dataColumnIndex == columns.length - 1) {
				paddingEnd = horizontalMargin;
			} else {
				paddingEnd = columnSpacing / 2.0;
			}
			final EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
				start: paddingStart,
				end: paddingEnd,
			);
			if (dataColumnIndex == _onlyTextColumn) {
				tableColumns[displayColumnIndex] = const IntrinsicColumnWidth(flex: 1.0);
			} else {
				tableColumns[displayColumnIndex] = const IntrinsicColumnWidth();
			}
			tableRows[0].children[displayColumnIndex] = _buildHeadingCell(
				context: context,
				padding: padding,
				label: column.label,
				tooltip: column.tooltip,
				numeric: column.numeric,
				onSort: () => column.onSort != null ? column.onSort(dataColumnIndex, sortColumnIndex != dataColumnIndex || !sortAscending) : null,
				sorted: dataColumnIndex == sortColumnIndex,
				ascending: sortAscending,
			);
			rowIndex = 1;
			for (DataRowErik row in rows) {
				final DataCellErik cell = row.cells[dataColumnIndex];
				tableRows[rowIndex].children[displayColumnIndex] = _buildDataCell(
					context: context,
					padding: padding,
					label: cell.child,
					numeric: column.numeric,
					placeholder: cell.placeholder,
					showEditIcon: cell.showEditIcon,
					onTap: cell.onTap,
					onSelectChanged: () => row.onSelectChanged != null ? row.onSelectChanged(!row.selected) : null,
				);
				rowIndex += 1;
			}
			displayColumnIndex += 1;
		}
		return Table(
			columnWidths: tableColumns.asMap(),
			children: tableRows,
		);
	}
}

class _SortArrowErik extends StatefulWidget {
	const _SortArrowErik({
		Key key,
		this.visible,
		this.down,
		this.duration,
	}) : super(key: key);

	final bool visible;

	final bool down;

	final Duration duration;

	@override
	_SortArrowErikState createState() => _SortArrowErikState();
}

class _SortArrowErikState extends State<_SortArrowErik> with TickerProviderStateMixin {

	AnimationController _opacityController;
	Animation<double> _opacityAnimation;

	AnimationController _orientationController;
	Animation<double> _orientationAnimation;
	double _orientationOffset = 0.0;

	bool _down;

	static final Animatable<double> _turnTween = Tween<double>(begin: 0.0, end: math.pi)
		.chain(CurveTween(curve: Curves.easeIn));

	@override
	void initState() {
		super.initState();
		_opacityAnimation = CurvedAnimation(
			parent: _opacityController = AnimationController(
				duration: widget.duration,
				vsync: this,
			),
			curve: Curves.fastOutSlowIn,
		)
			..addListener(_rebuild);
		_opacityController.value = widget.visible ? 1.0 : 0.0;
		_orientationController = AnimationController(
			duration: widget.duration,
			vsync: this,
		);
		_orientationAnimation = _orientationController.drive(_turnTween)
			..addListener(_rebuild)
			..addStatusListener(_resetOrientationAnimation);
		if (widget.visible)
			_orientationOffset = widget.down ? 0.0 : math.pi;
	}

	void _rebuild() {
		setState(() {
			// The animations changed, so we need to rebuild.
		});
	}

	void _resetOrientationAnimation(AnimationStatus status) {
		if (status == AnimationStatus.completed) {
			assert(_orientationAnimation.value == math.pi);
			_orientationOffset += math.pi;
			_orientationController.value = 0.0; // TODO(ianh): This triggers a pointless rebuild.
		}
	}

	@override
	void didUpdateWidget(_SortArrowErik oldWidget) {
		super.didUpdateWidget(oldWidget);
		bool skipArrow = false;
		final bool newDown = widget.down ?? _down;
		if (oldWidget.visible != widget.visible) {
			if (widget.visible && (_opacityController.status == AnimationStatus.dismissed)) {
				_orientationController.stop();
				_orientationController.value = 0.0;
				_orientationOffset = newDown ? 0.0 : math.pi;
				skipArrow = true;
			}
			if (widget.visible) {
				_opacityController.forward();
			} else {
				_opacityController.reverse();
			}
		}
		if ((_down != newDown) && !skipArrow) {
			if (_orientationController.status == AnimationStatus.dismissed) {
				_orientationController.forward();
			} else {
				_orientationController.reverse();
			}
		}
		_down = newDown;
	}

	@override
	void dispose() {
		_opacityController.dispose();
		_orientationController.dispose();
		super.dispose();
	}

	static const double _arrowIconBaselineOffset = -1.5;
	static const double _arrowIconSize = 16.0;

	@override
	Widget build(BuildContext context) {
		return Opacity(
			opacity: _opacityAnimation.value,
			child: Transform(
				transform: Matrix4.rotationZ(_orientationOffset + _orientationAnimation.value)
					..setTranslationRaw(0.0, _arrowIconBaselineOffset, 0.0),
				alignment: Alignment.center,
				child: Icon(
					Icons.arrow_downward,
					size: _arrowIconSize,
					color: (Theme.of(context).brightness == Brightness.light) ? Colors.black87 : Colors.white70,
				),
			),
		);
	}

}

@immutable
class DataColumnErik {
	const DataColumnErik({
		@required this.label,
		this.tooltip,
		this.numeric = false,
		this.onSort,
	}) : assert(label != null);
	final Widget label;
	final String tooltip;
	final bool numeric;
	final DataColumnSortCallback onSort;

	bool get _debugInteractive => onSort != null;
}


@immutable
class DataRowErik {
	/// Creates the configuration for a row of a [DataTable].
	///
	/// The [cells] argument must not be null.
	const DataRowErik({
		this.key,
		this.selected = false,
		this.onSelectChanged,
		@required this.cells,
	}) : assert(cells != null);
	DataRowErik.byIndex({
		int index,
		this.selected = false,
		this.onSelectChanged,
		@required this.cells,
	}) : assert(cells != null),
			key = ValueKey<int>(index);
	final LocalKey key;
	final ValueChanged<bool> onSelectChanged;
	final bool selected;
	final List<DataCellErik> cells;
	bool get _debugInteractive => onSelectChanged != null || cells.any((DataCellErik cell) => cell._debugInteractive);
}

@immutable
class DataCellErik {
	const DataCellErik(
		this.child, {
			this.placeholder = false,
			this.showEditIcon = false,
			this.onTap,
		}) : assert(child != null);

	static final DataCellErik empty = DataCellErik(Container(width: 0.0, height: 0.0));
	final Widget child;
	final bool placeholder;
	final bool showEditIcon;
	final VoidCallback onTap;

	bool get _debugInteractive => onTap != null;
}