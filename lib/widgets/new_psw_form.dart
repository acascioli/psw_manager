import 'package:flutter/material.dart';
import 'package:psw_manager/providers/sql_helper.dart';
import 'package:file_picker/file_picker.dart';

class NewPswForm extends StatefulWidget {
  const NewPswForm({Key? key}) : super(key: key);

  @override
  State<NewPswForm> createState() => _NewPswFormState();
}

class _PswData {
  String? title = '';
  String? username = '';
  String? password = '';
  String? userAvatar = '';
}

class _NewPswFormState extends State<NewPswForm> {
  // All psws
  List<Map<String, dynamic>> _psws = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _createPswsTable() async {
    await SQLHelper.createTables();
    setState(() {
      _isLoading = false;
    });
  }

  // This function is used to fetch all data from the database
  void _refreshPsws() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _psws = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _createPswsTable();
    _refreshPsws(); // Loading the diary when the app starts
  }

  Future<void> _addItem(_PswData _data) async {
    await SQLHelper.createItem(
      _data.title!,
      _data.username,
      _data.password,
      _data.userAvatar,
    );
    _refreshPsws();
  }

  final _formKey = GlobalKey<FormState>();
  final _PswData _data = _PswData();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add new password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Title',
                // hintText: 'you@example.com',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: (String? value) {
                _data.title = value;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'you@example.com',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: (String? value) {
                _data.username = value;
              },
            ),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                // hintText: 'you@example.com',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value != null && value.length > 8) {
                  return null;
                }
                return 'Minimum length is 8 characters';
              },
              onSaved: (String? value) {
                _data.password = value;
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
              child: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();
                    setState(() {
                      if (result == null) {
                        print("No file selected");
                      } else {
                        _data.userAvatar = result.files.single.name;
                        print(result.files.single.path);
                      }
                    });
                  },
                  child: const Text("File Picker"),
                ),
              ),
            ),
            Text(
              'File chosen: ' + _data.userAvatar!,
              style: const TextStyle(
                fontSize: 12,
              ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            // Validate returns true if the form is valid, or false otherwise.
            if (_formKey.currentState!.validate()) {
              _formKey.currentState?.save();
              print(_data.username);
              // If the form is valid, display a snackbar. In the real world,
              // you'd often call a server or save the information in a database.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
              );
            }
          },
          child: const Text('Submit'),
        ),
        // TextButton(
        //   onPressed: () {
        //     // Navigator.of(context).pop();
        //   },
        //   child: Text(
        //     'Confirm',
        //     style: TextStyle(
        //       color: Theme.of(context).primaryColor,
        //     ),
        //   ),
        // ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Close',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
