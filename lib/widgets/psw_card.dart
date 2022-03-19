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
  Future<void> _copyToClipboard(psw_text) async {
    await Clipboard.setData(ClipboardData(text: psw_text));
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: (widget.psw.userAvatar == '')
                              ? Image.asset(
                                  'assets/images/psw.png',
                                  fit: BoxFit.cover,
                                  color: darkColor.withOpacity(.3),
                                  colorBlendMode: BlendMode.srcOver,
                                )
                              : Image.file(
                                  File(
                                    widget.psw.userAvatar,
                                  ),
                                  fit: BoxFit.cover,
                                  color: darkColor.withOpacity(.3),
                                  colorBlendMode: BlendMode.srcOver,
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
                    widget.psw.password,
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
                        onPressed: () {
                          // _togglePinned(widget.psw);
                          print('Pong');
                        },
                        padding: const EdgeInsets.all(4),
                        icon: Icon(
                          widget.psw.pinned
                              ? Icons.lock_outline_rounded
                              : Icons.lock_open_rounded,
                          color: widget.psw.pinned
                              ? Colors.green
                              : Colors.redAccent,
                          size: getSize(context, 3),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy password to clipboard',
                        onPressed: () {
                          _copyToClipboard(widget.psw.password);
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
