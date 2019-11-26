import 'package:flutter/material.dart';
import 'package:StyloView/functional/StyloViewLib.dart';
import 'package:StyloView/functional/elements.dart';
import 'package:provider/provider.dart' as p;

class DataDrawer extends StatelessWidget {
//	DataDrawer(this._context);
//	BuildContext _context;
	@override
	Widget build(BuildContext context) {
		return Drawer(
			child: ListView(
				children: <Widget>[
					DrawerHeader(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: <Widget>[
								Text( C.s_domain +': ${p.Provider.of<AppState>(context).getAuth.DomainName ?? 'not auth'}'),
								Text( C.s_login +': ${p.Provider.of<AppState>(context).getAuth.Name ?? ''}')
							],
						),
						decoration: BoxDecoration(
							color: C.c_TEAL,
						),
					),
					Container(
						child: ReportsList(),
					)
				],
			),
		);
	}
}

class ReportsList extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return p.Consumer<AppState>(
			builder: (context, appState, child){
				return Column(
					children: appState.choiceList ?? <Widget>[],
				);
			},
		);
	}
}
