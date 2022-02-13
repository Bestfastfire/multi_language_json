library multi_language_json;

import 'package:country_pickers/country.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';

class MultiStreamLanguage extends StatelessWidget {
  /// On language change
  final Function? onChange;

  /// route in json, ex:
  /// {
  ///   "a" : {
  ///     "b" : "value"
  ///   }
  /// }
  ///
  /// to get only "b" I pass: ['a', 'b']
  final List<String> screenRoute;
  final languageBloc = MultiLanguageBloc._instance;

  /// Widget child
  final Widget Function(BuildContext c, LangSupport data) builder;

  MultiStreamLanguage(
      {required this.builder, this.screenRoute = const [], this.onChange}) {
    if (onChange != null) {
      languageBloc?.outStreamList.listen((v) => onChange!());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: languageBloc?.currentValue,
        stream: languageBloc?.outStreamList,
        builder: (context, s) {
          dynamic globalScreenRoute =
              languageBloc?._languages[languageBloc?.defaultLanguage];
          dynamic screenRoute = s.data;

          this.screenRoute.forEach((v) {
            if (globalScreenRoute != null)
              globalScreenRoute = globalScreenRoute[v];
            if (screenRoute != null) screenRoute = screenRoute[v];
          });

          return builder(
              context,
              LangSupport(
                  languageBloc?._languages[languageBloc?.defaultLanguage],
                  s.data,
                  globalScreenRoute,
                  screenRoute,
                  languageBloc?.commonRoute));
        });
  }
}

class MultiLanguageBloc implements _Bloc {
  /// Last language selected
  String lastLanguage;

  /// List ofs languages
  final _languages = {};

  /// Route common in to screens
  final String? commonRoute;

  /// Default language
  final String defaultLanguage;

  /// List of supported languages ex: ['en_US', 'pt_BR']
  /// Here you pass the names of files in folder "lang" without the ".json"
  final List<String> supportedLanguages;
  final _language = BehaviorSubject<Map<String, dynamic>>();

  /// Stream of languages
  Stream<dynamic> get outStreamList => _language.stream;

  /// Current json [Full]
  Map<dynamic, dynamic> get currentValue => _languages[lastLanguage];

  /// Current common in current json selected
  Map<dynamic, dynamic> get currentCommon =>
      commonRoute != null ? currentValue[commonRoute] : [];

  static MultiLanguageBloc? _instance;
  factory MultiLanguageBloc(
      {required List<String> supportedLanguages,
      required String defaultLanguage,
      String? initialLanguage,
      String? commonRoute}) {
    return _instance ??= MultiLanguageBloc._internal(
        supportedLanguages: supportedLanguages,
        defaultLanguage: defaultLanguage,
        lastLanguage: initialLanguage ?? defaultLanguage,
        commonRoute: commonRoute);
  }

  MultiLanguageBloc._internal(
      {required this.supportedLanguages,
      required this.defaultLanguage,
      required this.lastLanguage,
      this.commonRoute});

  /// Required called before all to load all jsons
  Future<void> init() async {
    for (int i = 0; i < supportedLanguages.length; i++) {
      this._languages[supportedLanguages[i]] =
          await parseJsonFromAssets('lang/' + supportedLanguages[i]);
    }

    await _setDeviceLanguage();
  }

  Future<MultiLanguageBloc> _setDeviceLanguage() async {
    await changeLanguage(this.defaultLanguage);
    return this;
  }

  /// Change current language passing prefix ex: [changeLanguage('en_US')]
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

  /// Get list of languages in route "config" inside jsons
  List<Map<dynamic, dynamic>> getListLanguage() {
    return _languages.values.map<Map>((v) => v['config']).toList();
  }

  /// Show alert to change language
  Future<dynamic> showAlertChangeLanguage(
      {required BuildContext context,
      required String title,
      required String btnNegative}) async {
    List<Map<dynamic, dynamic>> out = this.getListLanguage();

    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              actions: <Widget>[
                TextButton(
                    child: Text(btnNegative),
                    onPressed: () => Navigator.pop(context)),
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
                        leading: CountryPickerUtils.getDefaultFlagImage(Country(
                            isoCode: out[index]['iso_code'],
                            iso3Code: '',
                            name: '',
                            phoneCode: '')),
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
    return rootBundle
        .loadString(assetsPath + '.json')
        .then((jsonStr) => jsonDecode(jsonStr));
  }

  @override
  void dispose() {
    _language.close();
  }
}

class MultiLanguageStart extends StatelessWidget {
  final future;
  final Widget? loadWidget;
  final Function(BuildContext context) builder;

  MultiLanguageStart(
      {required this.future, required this.builder, this.loadWidget});

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

class LangSupport {
  final _defaultLang;
  final _currentLang;
  final _defaultRouteLang;
  final _currentRouteLang;
  final _commonKey;

  LangSupport(this._defaultLang, this._currentLang, this._defaultRouteLang,
      this._currentRouteLang, this._commonKey);

  dynamic getCommon() {
    return getValue(inRoute: false, route: [this._commonKey]);
  }

  dynamic getValue({required List<String> route, bool inRoute = true}) {
    dynamic toReturn = inRoute ? _currentRouteLang : _currentLang;
    dynamic toHelp = inRoute ? _defaultRouteLang : _defaultLang;

    route.forEach((e) {
      if (toHelp != null) toHelp = toHelp[e];
      if (toReturn != null) toReturn = toReturn[e];
    });

    return toReturn ?? (toHelp ?? 'NULL');
  }
}

abstract class _Bloc {
  void dispose();
}
