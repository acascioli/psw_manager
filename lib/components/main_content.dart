import 'package:flutter/material.dart';
import 'package:psw_manager/components/psws_list.dart';
import 'package:psw_manager/models/psw.dart';
import 'package:psw_manager/providers/sql_helper.dart';

class MainContent extends StatelessWidget {
  const MainContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: const [
          PswsList(),
        ],
      );
}
