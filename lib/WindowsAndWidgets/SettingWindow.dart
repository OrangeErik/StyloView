import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart' as p;
import 'package:StyloView/functional/SELib.dart';
import 'package:StyloView/functional/StyloViewLib.dart';
import 'package:StyloView/functional/elements.dart';

class SettingWindow extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: C.c_TEAL,
			appBar: AppBar(
				title: Text(C.s_setting),
				backgroundColor: C.c_TEAL,
			),
			body: UniCont(
				child: ListView(
					children: <Widget>[
						ExpansionTile(
							title: Text(C.s_reportSetting),
							children: <Widget>[
								Column(
									crossAxisAlignment: CrossAxisAlignment.stretch,
									children: <Widget>[
										ReportSetting(),
									],
								)
							]
						),
						ExpansionTile(
							title: Text(C.s_auth),
							children: <Widget>[
								Column(
									crossAxisAlignment: CrossAxisAlignment.stretch,
									children: <Widget>[
										AuthForm(),
									],
								)
							]
						),
					],
				),
			),
		);
	}
}

class AuthForm extends StatefulWidget { //Auth setting window
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
	final GlobalKey<FormState> _DomainFormKey = GlobalKey<FormState>();
	final GlobalKey<FormState> _GlobalAccFormKey = GlobalKey<FormState>();
	bool _RememberMe = false;
	@override
	Widget build(BuildContext context){
		return p.Consumer<AppState>(
			builder: (context, appState, child){
				if(appState.GetAuth.AuthState != AccessState.auth){ // если не авторизирован то...
					return  Column(
					  children: <Widget>[
					    Form(
					    	key  : _DomainFormKey,
					    	child: Column(
					    		crossAxisAlignment: CrossAxisAlignment.start,
					    		children          : <Widget>[
					    			Padding(  //Ввод домена
					    				padding: const EdgeInsets.all(8.0),
					    				child  : TextFormField(
					    					initialValue: GetDomainFromMemory(C.Dir),
					    					decoration : InputDecoration(
					    						labelText: C.s_domain,
					    						border   : OutlineInputBorder(
					    							gapPadding  : 3.3,
					    							borderRadius: BorderRadius.circular(3.3)
					    						)
					    					),
					    					validator: (value) {
					    						String err = null;
					    						if(value.isEmpty)
					    							err = C.s_enterYourDomain;
					    						else {
					    							File("${C.Dir}/${C.s_DOMAINNAMEFILE}").writeAsString(value.trim());
					    							appState.SetAuthDomain(value.trim());
					    							appState.GetGlobalAccountList(context, appState.GetAuth.DomainName);
					    						}
					    						return err;
					    					},

					    				),
					    			),
					    			Container(
					    				child: Row(
					    					mainAxisAlignment: MainAxisAlignment.spaceEvenly,
					    					children         : <Widget>[
					    						Padding(
					    							padding: const EdgeInsets.all(8.0),
					    							child  : RaisedButton(
					    								onPressed: () {
					    									_DomainFormKey.currentState.validate();
					    								},
					    								child: Text(C.s_loginRequest),
					    							),
					    						),
					    					],
					    				)
					    			),
								],
					    	),
					    ),
						  Form(
							  key: _GlobalAccFormKey,
							  child: Column(
								  crossAxisAlignment: CrossAxisAlignment.start,
								  children: <Widget>[
									  Padding( //ввод пароля
										  padding: const EdgeInsets.all(8.0),
										  child  : TextFormField(
											  enabled: appState.GetAuth.Name != null ? true : false,
											  obscureText: true, //скрывает текст в поле
											  decoration : InputDecoration(
												  labelText: C.s_pass,
												  border   : OutlineInputBorder(
													  gapPadding  : 3.3,
													  borderRadius: BorderRadius.circular(3.3)
												  ),
											  ),
											  validator: (value){
												  String err = null;
												  if(value.isEmpty)
													  err = C.s_enterYourPass;
												  else {
													  appState.LogIn(context: context, password: value, rememberMe: _RememberMe);
												  }
												  return err;
											  },
										  ),
									  ),
									  Container(
										  child: Row(
											  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
											  children         : <Widget>[
												  Padding(
													  padding: const EdgeInsets.all(8.0),
													  child  : Row(
														  children: <Widget>[
															  Row(
																  children: <Widget>[
																	  Text(C.s_rememberMe),
																	  Checkbox(
																		  value: _RememberMe,
																		  onChanged: (value){
																			  setState(() {
																				  _RememberMe = value;
																			  });
																		  },
																	  )
																  ],
															  ),
															  SizedBox(width: 60.0,),
															  RaisedButton(
																  padding: EdgeInsets.symmetric(horizontal: 40.0),
																  onPressed: () async {
																	  if(appState.GetAuth.DomainName != null){
																		  _GlobalAccFormKey.currentState.validate();
																	  }
																  },
																  child: Text(C.s_signin,),
															  ),
														  ],
													  ),
												  ),
											  ],
										  )
									  ),
								  ],
							  ),
						  )
					  ],
					);
				}
				else{
					return Container(
						child: Row(
							mainAxisAlignment: MainAxisAlignment.spaceEvenly,
							children         : <Widget>[
								Padding(
									padding: const EdgeInsets.all(8.0),
									child  : RaisedButton(
										onPressed: () {
											appState.LogOut();
											print('Signed OUT');
										},
										child: Text(C.s_signout),
									),
								),
							],
						)
					);
				}
			}
		);
	}

	String GetDomainFromMemory(String directory)
	{
		final File file = File("$directory/${C.s_DOMAINNAMEFILE}");
		String temp_buf;
		if(file != null && file.existsSync()){
			temp_buf = file.readAsStringSync();
			if(temp_buf == null || temp_buf.isEmpty){
				temp_buf = "";
			}
		}
		return temp_buf;
	}
}

class ReportSetting extends StatefulWidget {
  @override
  _ReportSettingState createState() => _ReportSettingState();
}

class _ReportSettingState extends State<ReportSetting> {
  @override
  Widget build(BuildContext context) {
    return p.Consumer<AppState>(
		builder: (context, appState, child){
			return Column(
				children: <Widget>[
					Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							RaisedButton(
								child: Text(C.s_resetSetting),
								onPressed: (){

								},
							),
							SizedBox(width: 40.0,),
							RaisedButton(
								child: Text(C.s_apply),
								onPressed: (){

								},
							)
						],
					)
				],
			);
		}
	);
  }
}

