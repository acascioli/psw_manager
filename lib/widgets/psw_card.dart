import 'package:flutter/material.dart';
import 'dart:io';
import 'package:psw_manager/models/psw.dart';
import 'package:psw_manager/providers/sql_helper.dart';
import '../constants.dart';
import '../responsive.dart';
import 'package:get/get.dart';
import 'package:psw_manager/providers/app_controller.dart';

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

  double? getSize(BuildContext context, int selector) {
    if (Responsive.isMobile(context)) {
      switch (selector) {
        case 0:
          return 12;
        case 1:
          return 5;
        case 2:
          return 10;
      }
    } else if (Responsive.isTablet(context)) {
      switch (selector) {
        case 0:
          return 15;
        case 1:
          return 10;
        case 2:
          return 13;
      }
    } else {
      switch (selector) {
        case 0:
          return 20;
        case 1:
          return 15;
        case 2:
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
            // transform: entered ? (Matrix4.skew(0, 0.1)) : null,
            // transform: entered ? (Matrix4.identity()..scale(1.025)) : null,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (Responsive.isDesktop(context))
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: SizedBox(
                              width: 60,
                              height: 60,
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
                  ],
                ),
                if (entered) ...[
                  const Spacer(),
                  Column(
                    children: [
                      PopupMenuButton(
                          iconSize: getSize(context, 0),
                          onSelected: (selectedValue) {
                            setState(() {
                              selectedItem = selectedValue.toString();
                            });
                            print(selectedItem);
                          },
                          itemBuilder: (BuildContext ctx) => [
                                PopupMenuItem(
                                    child: Text(
                                      'Copy password',
                                      style: TextStyle(
                                        fontSize: getSize(context, 2),
                                      ),
                                    ),
                                    value: '1'),
                                PopupMenuItem(
                                    child: Text(
                                      'Show password',
                                      style: TextStyle(
                                        fontSize: getSize(context, 2),
                                      ),
                                    ),
                                    value: '2'),
                                PopupMenuItem(
                                    child: Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontSize: getSize(context, 2),
                                      ),
                                    ),
                                    value: '3'),
                                PopupMenuItem(
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: getSize(context, 2),
                                      ),
                                    ),
                                    value: '4',
                                    onTap: () {
                                      setState(() {
                                        _deleteItem(widget.psw.title);
                                      });
                                    }),
                              ]),
                      // IconButton(
                      //   onPressed: () {
                      //     print('Ping');
                      //   },
                      //   icon: const Icon(
                      //     Icons.more_vert,
                      //     color: darkColor,
                      //   ),
                      // ),
                      IconButton(
                        onPressed: () {
                          _togglePinned(widget.psw);
                          print('Pong');
                        },
                        icon: Icon(
                          widget.psw.pinned
                              ? Icons.push_pin
                              : Icons.push_pin_outlined,
                          color: darkColor,
                          size: getSize(context, 0),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // _togglePinned(widget.psw);
                          print('Pong');
                        },
                        icon: Icon(
                          widget.psw.pinned
                              ? Icons.lock
                              : Icons.push_pin_outlined,
                          color: darkColor,
                          size: getSize(context, 0),
                        ),
                      ),
                    ],
                  )
                ] else ...[
                  const Spacer(),
                  if (widget.psw.pinned)
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.push_pin,
                        color: darkColor,
                        size: getSize(context, 0),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      );
}
