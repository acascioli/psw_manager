import 'package:flutter/material.dart';
import 'package:psw_manager/providers/sql_helper.dart';
import 'package:psw_manager/models/psw.dart';
import 'package:file_picker/file_picker.dart';

import 'package:get/get.dart';
import 'package:psw_manager/providers/app_controller.dart';

class NewPswForm extends StatefulWidget {
  const NewPswForm({
    Key? key,
    required this.receivedPsw,
  }) : super(key: key);

  final Psw receivedPsw;

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
  bool _isObscure = true;
  final controller = Get.put(AppController());
  RegExp numReg = RegExp(r".*[0-9].*");
  RegExp letterReg = RegExp(r".*[A-Za-z].*");
  late String _password;
  double _strength = 0;
  String _displayText = 'Please enter a password';

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
      controller.refreshPswsController(data);
      _psws = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _createPswsTable();
    _refreshPsws(); // Loading the diary when the app starts
    titleController.text = widget.receivedPsw.title;
    userController.text = widget.receivedPsw.username;
    pswController.text = widget.receivedPsw.password;
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

  void _checkPassword(String value) {
    _password = value.trim();

    if (_password.isEmpty) {
      setState(() {
        _strength = 0;
        _displayText = 'Please enter you password';
      });
    } else if (_password.length < 6) {
      setState(() {
        _strength = 1 / 4;
        _displayText = 'Your password is too short';
      });
    } else if (_password.length < 8) {
      setState(() {
        _strength = 2 / 4;
        _displayText = 'Your password is acceptable\n,but not strong';
      });
    } else {
      if (!letterReg.hasMatch(_password) || !numReg.hasMatch(_password)) {
        setState(() {
          // Password length >= 8
          // But doesn't contain both letter and digit characters
          _strength = 3 / 4;
          _displayText = 'Your password is strong';
        });
      } else {
        // Password length >= 8
        // Password contains both letter and digit characters
        setState(() {
          _strength = 1;
          _displayText = 'Your password is great';
        });
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final userController = TextEditingController();
  final pswController = TextEditingController();
  final _PswData _data = _PswData();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.receivedPsw.title.isEmpty
          ? const Text('Add new password')
          : const Text('Edit password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Title',
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
              controller: userController,
              autofocus: true,
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
              controller: pswController,
              autofocus: true,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                  icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off),
                  // hintText: 'you@example.com',
                ),
              ),
              onChanged: (value) => _checkPassword(value),
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
            const SizedBox(
              height: 20,
            ),
            LinearProgressIndicator(
              value: _strength,
              backgroundColor: Colors.grey[300],
              color: _strength <= 1 / 4
                  ? Colors.red
                  : _strength == 2 / 4
                      ? Colors.yellow
                      : _strength == 3 / 4
                          ? Colors.blue
                          : Colors.green,
              minHeight: 15,
            ),
            // The message about the strength of the entered password
            Text(
              _displayText,
              // style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 20,
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
                        _data.userAvatar = result.files.single.path;
                        print(result.files.single.path);
                      }
                    });
                  },
                  child: const Text("File Picker"),
                ),
              ),
            ),
            widget.receivedPsw.userAvatar.isEmpty
                ? Text(
                    'File chosen: ' + _data.userAvatar!,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  )
                : Text(
                    'File chosen: ' + widget.receivedPsw.userAvatar,
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
              await _addItem(_data);
              // If the form is valid, display a snackbar. In the real world,
              // you'd often call a server or save the information in a database.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
              );
              setState(() {
                titleController.clear();
                userController.clear();
                pswController.clear();
                _data.userAvatar = '';
              });
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
