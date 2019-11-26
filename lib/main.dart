// MAIN.DART
// Copyright (c) E.Sobolev, 2019
// @codepage UTF-8
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as p;
import 'package:StyloView/WindowsAndWidgets/MainWin.dart';
import 'package:StyloView/functional/elements.dart';

void main(){
	runApp(p.MultiProvider(
		providers: [
			p.ChangeNotifierProvider(
				builder: (context) => AppState(),
			)
		],
		child: MaterialApp(
			title: "StyloView",
			home:  MainWin(),
		)
	));
}