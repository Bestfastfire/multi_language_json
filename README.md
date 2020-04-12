# Stream Language
Check it out at [Pub.Dev](https://pub.dev/packages/multi_language)

A simple way to support your Flutter application with multiple languages!

![ezgif com-video-to-gif (1)](https://user-images.githubusercontent.com/22732544/65823906-9b68ee00-e235-11e9-989c-1c05a845b832.gif)

## Getting Started
First you need create a directory in your main folder with name lang like this:

<image>

Note that each json file must have its language and country code as its name.
Remember to add them to your pubspec:

<IMAGE>

In the code, to start you must first create an object with the following attributes:
    final language = MultiLanguageBloc(
          initialLanguage: 'pt_BR',
          defaultLanguage: 'pt_BR',
          commonRoute: 'common',
          supportedLanguages: [
            'en_US', 'pt_BR'
          ]
      );

MultiLanguageBloc is a singleton, after the first start, it will have the same attributes.

### CommonRoute:
Here you enter the key within the language that contains words that can be used on more than one screen as in the example below:

<Image>

The first time you use firebase language you should do this:

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
      return MultiLanguageStart( // # Use this widget to init languages, this will only be necessary once, after that you will only use the 'MultiStreamLanguage' widget
        future: language.init(), // # Here you call the method to init
        builder: (c) => MultiStreamLanguage(
          screenRoute: ['home'],
          builder: (context, data) => Scaffold(
            appBar: AppBar(
              title: Text(d.getValue(route: ['title'])),
            ),
            body: Center(
              child: RaisedButton(
                child: Text(data.getValue(route: ['btn'])),
                onPressed: () => language.showAlertChangeLanguage(
                  context: context,
                  title: data.getValue(
                    route: ['dialog', 'title'],
                    inRoute: false
                  ),
                  btnNegative: data.getValue(
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

From the next you start using only the `MultiStreamLanguage` widget, the first one is needed because the first app should load all language and start the default language from the user's mobile language.

## Widget StreamLanguage

### ScreenRoute
This is where the magic happens, as a parameter it receives the screen route within the language key, see that in the code above is as:
`screenRoute: ['home']`, in json it looks like this:

<IMAGE>

If the route were a node within 'home' you would go something like this: `screenRoute: ['home', 'route_inside_home']`

### [Very Important] Builder -> Data
Here is the parent object to access the texts, for that use the getValue method that has *route* as parameter, here it will work like ScreenRoute, its second parameter is *inRoute*, if true, the passed route will be traveled inside the path gives wheel informed in *ScreenRoute*, if false, it will look in the parent route, that is, in the beginning of json, ex:

<IMAGE>

#### inRoute true:
It will return: *B*

#### inRoute false:
It will return: *A*

# Changing Language
For this, every language node must have a child named config with the following attributes:
![Captura de Tela (104)](https://user-images.githubusercontent.com/22732544/65823821-c5211580-e233-11e9-8df3-666120569cbf.png)

After that you can call the method:

    language.showAlertChangeLanguage(
        context: context,
        title: 'title',
        btnNegative: 'text'
    )

This will show an alert dialog like this (Language and flag listing is done automatically from the data passed in the **config** node):

<IMAGE>

To change the language programmatically, just call this method passing as the language prefix ex:

    language.changeLanguage('pt_BR');

## Help Maintenance

I've been maintaining quite many repos these days and burning out slowly. If you could help me cheer up, buying me a cup of coffee will make my life really happy and get much energy out of it.

<a href="https://www.buymeacoffee.com/RtrHv1C" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a>