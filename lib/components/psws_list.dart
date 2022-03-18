import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:psw_manager/models/psw.dart';
import 'package:psw_manager/constants.dart';
import 'package:psw_manager/widgets/psw_card.dart';
import 'package:psw_manager/providers/sql_helper.dart';

import 'package:get/get.dart';
import 'package:psw_manager/providers/app_controller.dart';

class PswsList extends StatefulWidget {
  const PswsList({
    Key? key,
  }) : super(key: key);

  @override
  State<PswsList> createState() => _PswsListState();
}

class _PswsListState extends State<PswsList> {
  // All psws
  List<Map<String, dynamic>> _psws = [];
  List<Psw> allPsws = [];
  List<Psw> pinnedPsws = [];

  bool _isLoading = true;
  final controller = Get.put(AppController());

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
      // _psws = data;
      // for (var psw in _psws) {
      //   allPsws.add(
      //     Psw(
      //       psw['title'],
      //       psw['username'],
      //       psw['password'],
      //       psw['userAvatar'],
      //       (psw['pinned'] == 'FALSE') ? false : true,
      //       psw['createdOn'],
      //     ),
      //   );
      //   if (psw['pinned'] != 'FALSE') {
      //     pinnedPsws.add(
      //       Psw(
      //         psw['title'],
      //         psw['username'],
      //         psw['password'],
      //         psw['userAvatar'],
      //         true,
      //         psw['createdOn'],
      //       ),
      //     );
      //   }
      // }
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _createPswsTable();
    _refreshPsws(); // Loading the diary when the app starts
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final bool _isSm = _size.width <= screenSm;
    final bool _isLg = _size.width <= screenLg;

    return GetBuilder<AppController>(
        init: controller,
        builder: (logic) {
          allPsws = controller.allPsws;
          pinnedPsws = controller.pinnedPsws;

          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (pinnedPsws.isNotEmpty)
                          ? const Text(
                              'PINNED PASSWORDS',
                              style: TextStyle(
                                color: darkColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const SizedBox(
                              height: 0,
                            ),
                      (pinnedPsws.isNotEmpty)
                          ? const SizedBox(
                              height: 8,
                            )
                          : const SizedBox(
                              height: 0,
                            ),
                      (pinnedPsws.isNotEmpty)
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: pinnedPsws.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _isSm ? 1 : (_isLg ? 2 : 3),
                                childAspectRatio: 1.63,
                              ),
                              itemBuilder: (context, index) => PswCard(
                                psw: pinnedPsws[index],
                              ),
                            )
                          : const SizedBox(
                              height: 0,
                            ),
                      (pinnedPsws.isNotEmpty)
                          ? const SizedBox(
                              height: 8,
                            )
                          : const SizedBox(
                              height: 0,
                            ),
                      const Text(
                        'ALL PASSWORDS',
                        style: TextStyle(
                          color: darkColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: allPsws.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _isSm ? 1 : (_isLg ? 2 : 3),
                          childAspectRatio: 1.63,
                        ),
                        itemBuilder: (context, index) => PswCard(
                          psw: allPsws[index],
                        ),
                      ),
                    ],
                  ),
          );
        });
  }
}
