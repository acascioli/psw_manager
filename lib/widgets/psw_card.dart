import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:psw_manager/models/psw.dart';
import 'package:psw_manager/providers/sql_helper.dart';
import '../constants.dart';
import '../responsive.dart';
import 'package:get/get.dart';
import 'package:psw_manager/providers/app_controller.dart';
import 'package:psw_manager/widgets/new_psw_form.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PswCard extends StatefulWidget {
  const PswCard({
    Key? key,
    required this.psw,
  }) : super(key: key);

  final Psw psw;

  @override
  State<PswCard> createState() => _PswCardState();
}

class _PswCardState extends State<PswCard> {
  List<Icon> icons = [
    const Icon(Icons.account_circle, size: 64, color: Colors.white),
    const Icon(Icons.add, size: 64, color: Colors.white),
    const Icon(Icons.access_alarms, size: 64, color: Colors.white),
    const Icon(Icons.ac_unit, size: 64, color: Colors.white),
    const Icon(Icons.accessible, size: 64, color: Colors.white),
    const Icon(Icons.account_balance, size: 64, color: Colors.white),
    const Icon(Icons.add_circle_outline, size: 64, color: Colors.white),
    const Icon(Icons.airline_seat_individual_suite,
        size: 64, color: Colors.white),
    const Icon(Icons.arrow_drop_down_circle, size: 64, color: Colors.white),
    const Icon(Icons.assessment, size: 64, color: Colors.white),
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

  // All psws
  List<Map<String, dynamic>> _psws = [];
  bool entered = false;
  final controller = Get.put(AppController());
  var selectedItem = '';

  void _deleteItem(title) async {
    await SQLHelper.deleteItem(title);
    setState(() {
      _refreshPsws();
    });
  }

  void _togglePinned(Psw psw) async {
    await SQLHelper.togglePinned(psw);
    setState(() {
      _refreshPsws();
    });
  }

  void _refreshPsws() async {
    final data = await SQLHelper.getItems();
    setState(() {
      controller.refreshPswsController(data);
      _psws = data;
    });
  }

  // This function is triggered when the copy icon is pressed
  Future<void> _copyToClipboard(pswText) async {
    await Clipboard.setData(ClipboardData(text: pswText));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Copied to clipboard'),
    ));
  }

  double? getSize(BuildContext context, int selector) {
    if (Responsive.isMobile(context)) {
      switch (selector) {
        case 0:
          return 12;
        case 1:
          return 5;
        case 2:
          return 10;
        case 3:
          return 12;
      }
    } else if (Responsive.isTablet(context)) {
      switch (selector) {
        case 0:
          return 15;
        case 1:
          return 10;
        case 2:
          return 13;
        case 3:
          return 15;
      }
    } else {
      switch (selector) {
        case 0:
          return 18;
        case 1:
          return 14;
        case 2:
          return 18;
        case 3:
          return 18;
      }
    }
    return null;
  }

  TextEditingController masterPassController = TextEditingController();
  bool decrypt = false;
  String decrypted = "*" * 15;
  String masterPassString = "";

  Future<String> getMasterPass() async {
    final storage = FlutterSecureStorage();
    String masterPass = await storage.read(key: 'master') ?? '';
    return masterPass;
  }

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
                "To decrypt the password enter your master password:",
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
                decryptPass(widget.psw.password, masterPassString);
                masterPassController.clear();
                if (!decrypt) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wrong Master Password')),
                  );
                }
              },
              child: const Text("Done"),
            )
          ],
        );
      },
    );
  }

  decryptPass(String encryptedPass, String masterPass) {
    String keyString = masterPass;
    if (keyString.length < 32) {
      int count = 32 - keyString.length;
      for (var i = 0; i < count; i++) {
        keyString += ".";
      }
    }

    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.fromLength(16);

    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      print('encrypter.decrypt64(encryptedPass, iv: iv)');
      final d = encrypter.decrypt64(encryptedPass, iv: iv);
      setState(() {
        decrypted = d;
        decrypt = true;
      });
    } catch (exception) {
      setState(() {
        decrypted = "Wrong Master Password";
      });
    }
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (event) {
          setState(() {
            entered = true;
          });
        },
        onExit: (event) {
          setState(() {
            entered = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 8,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 900),
            transform: entered ? (Matrix4.identity()..scale(1.025)) : null,
            margin: const EdgeInsets.only(
              top: 12,
              right: 14,
              bottom: 12,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 4),
                  color: darkColor.withOpacity(.2),
                  blurRadius: 8,
                ),
                BoxShadow(
                  offset: const Offset(0, 2),
                  color: darkColor.withOpacity(.2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (Responsive.isDesktop(context))
                      Material(
                        shape: const CircleBorder(),
                        elevation: 4.0,
                        child: CircleAvatar(
                          backgroundColor: hexToColor(widget.psw.pswColor),
                          radius: 30,
                          child: Icon(
                            icons[iconNames.indexOf(widget.psw.pswIcon)].icon,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.psw.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: darkColor,
                            fontSize: getSize(context, 0),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          widget.psw.createdOn,
                          style: TextStyle(
                            color: textColor,
                            fontSize: getSize(context, 1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  widget.psw.username,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: darkColor,
                    fontSize: getSize(context, 2),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Expanded(
                  child: Text(
                    decrypted,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: textColor,
                      fontSize: getSize(context, 2),
                    ),
                    softWrap: true,
                    maxLines: 5,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Pin password',
                        onPressed: () {
                          _togglePinned(widget.psw);
                        },
                        padding: const EdgeInsets.all(4),
                        icon: Icon(
                          widget.psw.pinned
                              ? Icons.push_pin
                              : Icons.push_pin_outlined,
                          color: darkColor,
                          size: getSize(context, 3),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Show password',
                        onPressed: () async {
                          if (!decrypt) {
                            buildShowDialogBox(context);
                          } else if (!decrypt) {
                            decryptPass(widget.psw.password, masterPassString);
                          } else if (decrypt) {
                            setState(() {
                              decrypted = "*" * 15;
                              decrypt = !decrypt;
                            });
                          }
                        },
                        padding: const EdgeInsets.all(4),
                        icon: Icon(
                          !decrypt
                              ? Icons.lock_outline_rounded
                              : Icons.lock_open_rounded,
                          color: !decrypt ? Colors.green : Colors.redAccent,
                          size: getSize(context, 3),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy password to clipboard',
                        onPressed: () {
                          decrypt
                              ? _copyToClipboard(decrypted)
                              : _copyToClipboard(widget.psw.password);
                        },
                        padding: const EdgeInsets.all(4),
                        icon: Icon(
                          Icons.copy,
                          color: Theme.of(context).primaryColor,
                          size: getSize(context, 3),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => NewPswForm(
                              receivedPsw: widget.psw,
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(4),
                        icon: Icon(
                          Icons.edit,
                          color: Colors.amber,
                          size: getSize(context, 3),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Please Confirm'),
                              content: const Text(
                                  'Are you sure you want to delete the password?'),
                              actions: [
                                // The "Yes" button
                                TextButton(
                                    onPressed: () {
                                      // Remove the box
                                      setState(() {
                                        _deleteItem(widget.psw.title);
                                      });
                                      // Close the dialog
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Yes')),
                                TextButton(
                                    onPressed: () {
                                      // Close the dialog
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('No'))
                              ],
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(4),
                        icon: Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                          size: getSize(context, 3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
