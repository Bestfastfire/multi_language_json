import 'package:flutter/material.dart';
import 'package:multilanguage/multi_language.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Multi Language - Example',
        home: Home(),
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('pt', 'BR')
        ]
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final language = MultiLanguageBloc(
      initialLanguage: 'pt_BR',
      defaultLanguage: 'pt_BR',
      commonRoute: 'common',
      supportedLanguages: [
        'en_US', 'pt_BR'
      ]
  );
  
  @override
  Widget build(BuildContext context) {

    return MultiLanguageStart(
      future: language.init(), 
      builder: (c) => MultiStreamLanguage(
        screenRoute: ['home'],
        builder: (c, d) => Scaffold(
          appBar: AppBar(
            title: Text(d.getValue(route: ['title'])),
          ),
          body: Center(
            child: RaisedButton(
              child: Text(d.getValue(route: ['btn'])),
              onPressed: () => language.showAlertChangeLanguage(
                context: context,
                title: d.getValue(
                    route: ['dialog', 'title'],
                    inRoute: false
                ),
                btnNegative: d.getValue(
                    route: ['dialog', 'btn_negative'],
                    inRoute: false
                )
              ),
            ),
          ),
        )
      )
    );
  }
}

