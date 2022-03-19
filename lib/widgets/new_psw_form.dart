import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

import 'package:psw_manager/providers/sql_helper.dart';
import 'package:psw_manager/models/psw.dart';
import 'package:file_picker/file_picker.dart';

import 'package:get/get.dart';
import 'package:psw_manager/providers/app_controller.dart';
import 'package:psw_manager/random_string.dart';

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
  String? pswIcon = '';
  String? pswColor = '';
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

  late Color pickedColor;

  late encrypt.Encrypted encrypted;
  String keyString = "";
  String encryptedString = "";
  String decryptedString = "";
  String masterPassString = "";
  late int pickedIcon;

  List<Icon> icons = [
    const Icon(Icons.account_circle, size: 28, color: Colors.white),
    const Icon(Icons.add, size: 28, color: Colors.white),
    const Icon(Icons.access_alarms, size: 28, color: Colors.white),
    const Icon(Icons.ac_unit, size: 28, color: Colors.white),
    const Icon(Icons.accessible, size: 28, color: Colors.white),
    const Icon(Icons.account_balance, size: 28, color: Colors.white),
    const Icon(Icons.add_circle_outline, size: 28, color: Colors.white),
    const Icon(Icons.airline_seat_individual_suite,
        size: 28, color: Colors.white),
    const Icon(Icons.arrow_drop_down_circle, size: 28, color: Colors.white),
    const Icon(Icons.assessment, size: 28, color: Colors.white),
  ];

  List<String> iconNames = [
    "Icon 1",
    "Icon 2",
    "Icon 3",
    "Icon 4",
    "Icon 5",
    "Icon 6",
    "Icon 7",
    "Icon 8",
    "Icon 9",
    "Icon 10",
  ];
  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 9), radix: 16) + 0xFF000000);
  }

  Future<void> getMasterPass() async {
    const storage = FlutterSecureStorage();
    String masterPass = await storage.read(key: 'master') ?? '';
    masterPassString = masterPass;
  }

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

  _openColorPicker() async {
    Color _tempShadeColor = pickedColor;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: const Text("Color picker"),
          actions: [
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  pickedColor = _tempShadeColor;
                });
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: Navigator.of(context).pop,
            ),
          ],
          content: MaterialColorPicker(
            allowShades: true,
            selectedColor: _tempShadeColor,
            onColorChange: (color) => setState(() => _tempShadeColor = color),
            onMainColorChange: (color) =>
                setState(() => _tempShadeColor = color!),
          ),
        );
      },
    );
  }

  TextEditingController masterPassController = TextEditingController();

  Future buildShowDialogBox(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Master Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                "To enctypy the password enter your master password:",
                style: TextStyle(fontFamily: 'Subtitle'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  obscureText: true,
                  maxLength: 32,
                  decoration: InputDecoration(
                      hintText: "Master Pass",
                      hintStyle: const TextStyle(fontFamily: "Subtitle"),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16))),
                  controller: masterPassController,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                masterPassString = masterPassController.text;
                masterPassController.clear();
              },
              child: const Text("DONE"),
            )
          ],
        );
      },
    );
  }

  encryptPass(String text) {
    keyString = masterPassString;
    if (keyString.length < 32) {
      int count = 32 - keyString.length;
      for (var i = 0; i < count; i++) {
        keyString += ".";
      }
    }
    final key = encrypt.Key.fromUtf8(keyString);
    final plainText = text;
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final e = encrypter.encrypt(plainText, iv: iv);
    encryptedString = e.base64.toString();
  }

  @override
  void initState() {
    super.initState();
    // getMasterPass();
    if (widget.receivedPsw.pswIcon.isNotEmpty) {
      pickedIcon = iconNames.indexOf(widget.receivedPsw.pswIcon);
      pickedColor = hexToColor(widget.receivedPsw.pswColor);
    } else {
      pickedIcon = 0;
      pickedColor = Colors.red;
    }
    _createPswsTable();
    _refreshPsws(); // Loading the diary when the app starts
    titleController.text = widget.receivedPsw.title;
    userController.text = widget.receivedPsw.username;
    pswController.text = widget.receivedPsw.password;
    _checkPassword(pswController.text);
  }

  Future<void> _addItem(_PswData _data) async {
    await SQLHelper.createItem(
      _data.title!,
      _data.username,
      _data.password,
      _data.pswIcon,
      _data.pswColor,
    );
    _refreshPsws();
  }

  Future<void> _updateItem(_PswData _data) async {
    await SQLHelper.updateItem(
      widget.receivedPsw.id,
      _data.title!,
      _data.username,
      _data.password,
      _data.pswIcon,
      _data.pswColor,
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
      scrollable: true,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      String pass = generatePassword();
                      pswController.text = pass;
                      _checkPassword(pass);
                    });
                  },
                  child: const Text("Generate"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(left: 0.0, right: 8.0, top: 8.0),
                    child: Text(
                      "Pick an Icon",
                      style: TextStyle(
                        fontFamily: 'Title',
                        fontSize: 20,
                        // color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    child: Material(
                      shape: const CircleBorder(),
                      elevation: 4.0,
                      child: CircleAvatar(
                          backgroundColor: pickedColor,
                          radius: 25,
                          child: icons[pickedIcon]),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 15, 0, 10),
              child: SizedBox(
                height: 120,
                width: 300,
                child: GridView.count(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  crossAxisCount: 5,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.3,
                  children: List.generate(
                    icons.length,
                    (index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            pickedIcon = index;
                          });
                        },
                        child: Material(
                            elevation: 4.0,
                            color: pickedColor,
                            shape: const CircleBorder(),
                            child: icons[index]),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Pick a Color",
                      style: TextStyle(
                        fontFamily: 'Title',
                        fontSize: 20,
                        // color: primaryColor,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _openColorPicker();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 8.0),
                      child: Material(
                          shape: const CircleBorder(),
                          elevation: 4.0,
                          child: CircleAvatar(
                            backgroundColor: pickedColor,
                            radius: 25,
                          )),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            await buildShowDialogBox(context);
            // Validate returns true if the form is valid, or false otherwise.
            if (_formKey.currentState!.validate()) {
              _formKey.currentState?.save();
              encryptPass(pswController.text);
              _data.password = encryptedString;
              _data.pswIcon = iconNames[pickedIcon];
              _data.pswColor = "#" + pickedColor.value.toRadixString(16);
              if (widget.receivedPsw.title.isEmpty) {
                await _addItem(_data);
              } else {
                await _updateItem(_data);
              }

              // If the form is valid, display a snackbar. In the real world,
              // you'd often call a server or save the information in a database.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
              );
              setState(() {
                titleController.clear();
                userController.clear();
                pswController.clear();
                _checkPassword(pswController.text);
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
