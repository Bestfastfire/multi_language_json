library multi_language;

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class MultiStreamLanguage extends StatelessWidget {
  final Function onChange;
  final List<String> screenRoute;
  final languageBloc = MultiLanguageBloc._instance;
  final Widget Function(BuildContext c, LangSupport data) builder;

  MultiStreamLanguage({@required this.builder, this.screenRoute = const [], this.onChange}){
    if(onChange != null){
      languageBloc.outStreamList.listen((v) => onChange());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: languageBloc.currentValue,
      stream: languageBloc.outStreamList,
      builder: (context, s) {
        dynamic globalScreenRoute = languageBloc
            ._languages[languageBloc.defaultLanguage];
        dynamic screenRoute = s.data;

        this.screenRoute.forEach((v){
          if(globalScreenRoute != null) globalScreenRoute = globalScreenRoute[v];
          if(screenRoute != null) screenRoute = screenRoute[v];
        });

        return builder(context, LangSupport(
            languageBloc._languages[languageBloc.defaultLanguage],
            s.data,
            globalScreenRoute,
            screenRoute,
            languageBloc.commonRoute
        ));
      },
    );
  }
}

class MultiLanguageBloc implements BlocBase {
  String lastLanguage;
  final _languages = {};
  final String commonRoute;
  final String defaultLanguage;
  final List<String> supportedLanguages;
  final _language = BehaviorSubject<Map<String, dynamic>>();

  Stream<dynamic> get outStreamList => _language.stream;
  Map<dynamic, dynamic> get currentValue => _language.value;
  Map<dynamic, dynamic> get currentCommon =>
      commonRoute != null ? currentValue[commonRoute] : [];

  static MultiLanguageBloc _instance;
  factory MultiLanguageBloc({@required List<String> supportedLanguages, @required String defaultLanguage, @required String initialLanguage, String commonRoute}) {
    _instance ??= MultiLanguageBloc._internal(
        supportedLanguages: supportedLanguages,
        defaultLanguage: defaultLanguage,
        lastLanguage: initialLanguage,
        commonRoute: commonRoute);
    return _instance;
  }

  MultiLanguageBloc._internal(
      {this.supportedLanguages, this.defaultLanguage, this.lastLanguage, this.commonRoute});

  Future<void> init() async {
    this.lastLanguage ??= defaultLanguage;
    for(int i = 0; i < supportedLanguages.length; i++){
      this._languages[supportedLanguages[i]] = await parseJsonFromAssets('lang/' + supportedLanguages[i]);
    }

    await _setDeviceLanguage();
  }

  Future<MultiLanguageBloc> _setDeviceLanguage() async {
    await changeLanguage(await Devicelocale.currentLocale);
    return this;
  }

  Future<void> changeLanguage(String prefix) async {
    if (_languages[prefix] == null) {
      prefix = this.defaultLanguage;
      print(
          'setting language with defaultLanguage because prefix: $prefix dont exists in map!');
    }

    if (this.lastLanguage != prefix) {
      this.lastLanguage = prefix;
      _language.sink.add(_languages[this.lastLanguage]);
      print('language inited with language: $prefix');
    } else {
      print(
          'language dont changed because informed prefix is the same as current language: $prefix');
    }
  }

  List<Map<dynamic, dynamic>> getListLanguage() {
    return _languages.values.map<Map>((v) => v['config']).toList();
  }

  Future<dynamic> showAlertChangeLanguage(
      {@required context,
        @required String title,
        @required String btnNegative}) async {
    List<Map<dynamic, dynamic>> out = this.getListLanguage();

    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          actions: <Widget>[
            FlatButton(
              child: Text(btnNegative),
              onPressed: () => Navigator.pop(context),
            ),
          ],
          content: Container(
            width: MediaQuery.of(context).size.height * 0.8,
            height: MediaQuery.of(context).size.height * 0.3,
            child: ListView.builder(
              itemCount: out.length,
              itemBuilder: (BuildContext context, int index) {
                return Material(
                  color: currentValue['config']['prefix'] ==
                      out[index]['prefix']
                      ? Colors.blueAccent[700]
                      : Colors.transparent,
                  child: ListTile(
                    leading: CountryPickerUtils.getDefaultFlagImage(
                        Country(isoCode: out[index]['iso_code'])),
                    selected: currentValue['config']['prefix'] ==
                        out[index]['prefix'],
                    title: Text(
                      out[index]['title'].toString(),
                      style: TextStyle(
                          color: currentValue['config']['prefix'] ==
                              out[index]['prefix']
                              ? Colors.white
                              : Colors.black),
                    ),
                    onTap: () {
                      changeLanguage(out[index]['prefix']);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ));
  }

  Future<Map<String, dynamic>> parseJsonFromAssets(String assetsPath) async {
    return rootBundle.loadString(assetsPath + '.json')
        .then((jsonStr) => jsonDecode(jsonStr));
  }

  @override
  void dispose() {
    _language.close();
  }

  @override
  void addListener(listener) {}

  @override
  bool get hasListeners => null;

  @override
  void notifyListeners() {}

  @override
  void removeListener(listener) {}
}

class MultiLanguageStart extends StatelessWidget {
  final future;
  final Widget loadWidget;
  final Function(BuildContext context) builder;
  MultiLanguageStart(
      {@required this.future, @required this.builder, this.loadWidget});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return builder(context);
        }
        return loadWidget ?? CircularProgressIndicator();
      },
    );
  }
}

class LangSupport{
  final _defaultLang;
  final _currentLang;
  final _defaultRouteLang;
  final _currentRouteLang;
  final _commonKey;

  LangSupport(this._defaultLang,
      this._currentLang,
      this._defaultRouteLang,
      this._currentRouteLang,
      this._commonKey
      );

  dynamic getCommon(){
    return getValue(
        inRoute: false,
        route: [this._commonKey]
    );
  }

  dynamic getValue({@required List<String> route, bool inRoute = true}){
    dynamic toReturn = inRoute ? _currentRouteLang : _currentLang;
    dynamic toHelp = inRoute ? _defaultRouteLang : _defaultLang;

    route.forEach((e) {
      if(toHelp != null) toHelp = toHelp[e];
      if(toReturn != null) toReturn = toReturn[e];
    });

    return toReturn ?? (toHelp ?? 'NULL');
  }
}