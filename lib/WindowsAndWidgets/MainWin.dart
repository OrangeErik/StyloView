import 'package:flutter/material.dart';
import 'package:StyloView/functional/SELib.dart';
import 'package:StyloView/functional/StyloViewLib.dart';
import 'package:StyloView/functional/elements.dart';
import 'package:provider/provider.dart' as p;
import 'package:StyloView/WindowsAndWidgets/DataDrawer.dart';
import 'package:StyloView/WindowsAndWidgets/SettingWindow.dart';

class MainWin extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: C.c_TEAL,
			appBar: AppBar(
				title: Text(C.s_styloview),
				backgroundColor: C.c_TEAL,
				actions: <Widget>[
					IconButton(
						icon: Icon(Icons.settings),
						tooltip: C.s_setting,
						onPressed: () => goToPage(context, SettingWindow())
					),
				],
			),
			body: UniCont(child: p.Provider.of<AppState>(context).ReportWidget ?? Center(child: Image.asset("images/PPY_IMAGE1.png")),),
			drawer: DataDrawer(),
		);
	}
}
