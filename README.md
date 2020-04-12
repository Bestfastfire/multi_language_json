# Stream Language
Check it out at [Pub.Dev](https://pub.dev/packages/multi_language)

A simple way to support your Flutter application with multiple languages!

![Gravar_2020_04_12_05_50_22_436](https://user-images.githubusercontent.com/22732544/79065252-6aa64e80-7c85-11ea-99f4-32904a624331.gif)

## Getting Started
First you need create a directory in your main folder with name lang like this:

![Screenshot_20](https://user-images.githubusercontent.com/22732544/79065270-81e53c00-7c85-11ea-87cb-e39040d1cb6a.png)

Note that each json file must have its language and country code as its name.
Remember to add them to your pubspec:

![Screenshot_21](https://user-images.githubusercontent.com/22732544/79065273-83166900-7c85-11ea-914b-3ae277816c36.png)

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

![Screenshot_22](https://user-images.githubusercontent.com/22732544/79065283-94f80c00-7c85-11ea-9d39-05b6e38bdcc3.png)

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

## Widget MultiStreamLanguage

### ScreenRoute
This is where the magic happens, as a parameter it receives the screen route within the language key, see that in the code above is as:
`screenRoute: ['home']`, in json it looks like this:

![Screenshot_23](https://user-images.githubusercontent.com/22732544/79065294-a17c6480-7c85-11ea-9e89-e34f30fdd2fe.png)

If the route were a node within 'home' you would go something like this: `screenRoute: ['home', 'route_inside_home']`

### [Very Important] Builder -> Data
Here is the parent object to access the texts, for that use the getValue method that has **route** as parameter, here it will work like ScreenRoute, its second parameter is **inRoute**, if true, the passed route will be traveled inside the path gives wheel informed in **ScreenRoute**, if false, it will look in the parent route, that is, in the beginning of json, ex:

if i called `data.getValue(route: ['my_route'], inRoute: true/false);`

![Screenshot_23](https://user-images.githubusercontent.com/22732544/79065294-a17c6480-7c85-11ea-9e89-e34f30fdd2fe.png)

#### with inRoute true:
It will return: **B**

#### with inRoute false:
It will return: **A**

Another very interesting point, if the past route does not exist in the current language, it will search in the standard language, and if it does not exist there, it will return a string with the text 'NULL', ex:

![Gravar_2020_04_12_05_49_28_636~1](https://user-images.githubusercontent.com/22732544/79065457-ce7d4700-7c86-11ea-8da2-21a03b78f62c.gif)

# Changing Language
For this, every language node must have a child named config with the following attributes:

![Screenshot_18](https://user-images.githubusercontent.com/22732544/79065332-e7d1c380-7c85-11ea-9380-8262ba6b5a8d.png)

The **title** key is what will appear as the language name in the dialog you select.

After that you can call the method:

    language.showAlertChangeLanguage(
        context: context,
        title: 'title',
        btnNegative: 'text'
    )

This will show an alert dialog like this (Language and flag listing is done automatically from the data passed in the **config** node):

![Screenshot_19](https://user-images.githubusercontent.com/22732544/79065375-4139f280-7c86-11ea-94bc-7202dfad3be1.png)

To change the language programmatically, just call this method passing as the language prefix ex:

    language.changeLanguage('pt_BR');

## Help Maintenance

I've been maintaining quite many repos these days and burning out slowly. If you could help me cheer up, buying me a cup of coffee will make my life really happy and get much energy out of it.

<a href="https://www.buymeacoffee.com/RtrHv1C" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a>
