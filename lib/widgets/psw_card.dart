import 'package:flutter/material.dart';
import 'dart:io';
import 'package:psw_manager/models/psw.dart';
import 'package:psw_manager/providers/sql_helper.dart';
import '../constants.dart';

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
                  color: darkColor.withOpacity(.03),
                  blurRadius: 8),
              BoxShadow(
                offset: const Offset(0, 2),
                color: darkColor.withOpacity(.03),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: darkColor,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        widget.psw.createdOn,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (entered) ...[
                    const Spacer(),
                    Column(
                      children: [
                        PopupMenuButton(
                            onSelected: (selectedValue) {
                              setState(() {
                                selectedItem = selectedValue.toString();
                              });
                              print(selectedItem);
                            },
                            itemBuilder: (BuildContext ctx) => [
                                  const PopupMenuItem(
                                      child: Text('Copy password'), value: '1'),
                                  const PopupMenuItem(
                                      child: Text('Show password'), value: '2'),
                                  const PopupMenuItem(
                                      child: Text('Edit'), value: '3'),
                                  PopupMenuItem(
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.red,
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
                          ),
                        ),
                      ],
                    )
                  ] else ...[
                    const Spacer(),
                    if (widget.psw.pinned)
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.push_pin,
                          color: darkColor,
                        ),
                      ),
                  ],
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                widget.psw.username,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: darkColor,
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
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                  softWrap: true,
                  maxLines: 5,
                ),
              ),
            ],
          ),
        ),
      );
}
