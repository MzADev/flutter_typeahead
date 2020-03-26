import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:example/data.dart';

class MyMaterialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_typeahead demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title: TabBar(tabs: [
              Tab(text: 'Example 1: Navigation'),
              Tab(text: 'Example 2: Form'),
              Tab(text: 'Example 3: Scroll')
            ]),
          ),
          body: TabBarView(children: [
            NavigationExample(),
            FormExample(),
            ScrollExample(),
          ])),
    );
  }
}

class NavigationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: <Widget>[
              IconButton(
                padding: const EdgeInsets.only(right: 8.0),
                icon: const Icon(Icons.search, color: Colors.grey),
                onPressed: () {},
              ),
              Flexible(
                child: TypeAheadField(
                  suggestionsBoxVerticalOffset: 0.0,
                  topPadding: 150,
                  bottomPadding: 60,
                  suggestionsBoxDecoration: SuggestionsBoxDecoration(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width,
                    minHeight: MediaQuery.of(context).size.height),
                      color: Colors.transparent, elevation: 0, hasScrollbar: false),
                  textFieldConfiguration: TextFieldConfiguration(
                    autofocus: true,
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(fontStyle: FontStyle.italic),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'What are you looking for?'),
                  ),
                  suggestionsCallback: (pattern) async {
                    return await BackendService.getSuggestions(pattern);
                  },
                  hideSuggestionsOnKeyboardHide: false,
                  itemBuilder: (context, suggestion) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 32,),
                            Icon(Icons.shopping_cart),
                            Text(suggestion['name'] + "hahhhhahahahhhhh"),
                            Text('\$${suggestion['price']}'),
                        ],
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProductPage(product: suggestion)));
                  },
                ),
              ),
              IconButton(
                padding: const EdgeInsets.only(left: 8.0),
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FormExample extends StatefulWidget {
  @override
  _FormExampleState createState() => _FormExampleState();
}

class _FormExampleState extends State<FormExample> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();

  String _selectedCity;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: this._formKey,
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: <Widget>[
            Text('What is your favorite city?'),
            TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(labelText: 'City'),
                controller: this._typeAheadController,
              ),
              suggestionsCallback: (pattern) {
                return CitiesService.getSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (suggestion) {
                this._typeAheadController.text = suggestion;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please select a city';
                }
              },
              onSaved: (value) => this._selectedCity = value,
            ),
            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              child: Text('Submit'),
              onPressed: () {
                if (this._formKey.currentState.validate()) {
                  this._formKey.currentState.save();
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content:
                          Text('Your Favorite City is ${this._selectedCity}')));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class ScrollExample extends StatelessWidget {
  final List<String> items = List.generate(5, (index) => "Item $index");

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Suggestion box will resize when scrolling"),
      )),
      SizedBox(height: 200),
      TypeAheadField<String>(
        getImmediateSuggestions: true,
        textFieldConfiguration: TextFieldConfiguration(
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'What are you looking for?'),
        ),
        suggestionsCallback: (String pattern) async {
          return items
              .where((item) =>
                  item.toLowerCase().startsWith(pattern.toLowerCase()))
              .toList();
        },
        itemBuilder: (context, String suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        onSuggestionSelected: (String suggestion) {
          print("Suggestion selected");
        },
      ),
      SizedBox(height: 500),
    ]);
  }
}

class ProductPage extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductPage({this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: [
            Text(
              this.product['name'],
              style: Theme.of(context).textTheme.headline,
            ),
            Text(
              this.product['price'].toString() + ' USD',
              style: Theme.of(context).textTheme.subhead,
            )
          ],
        ),
      ),
    );
  }
}
