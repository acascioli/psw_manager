import 'package:flutter/material.dart';
import 'package:psw_manager/components/psws_list.dart';
import 'package:psw_manager/models/psw.dart';
import 'package:psw_manager/providers/sql_helper.dart';

List<Psw> pinnedPsws = [
  Psw(
    'Focus Time 🎧',
    'Chris Kruger',
    '''Hi guys, I would like to suggest that we 
set a fixed focus time within the company, where you can set a fixed focus time within the company, where you can
''',
    'psw.png',
    false,
    '8/22/2020 . 4:43 pm',
  ),
];

List<Psw> allPsws = [
  Psw(
    'Please close the doors 🚪',
    'Laura Schellen',
    '''I wanted to point out to you that in 
the future please make sure to keep the doors 
wanted to point out to you that all bout 
closed''',
    'psw.png',
    false,
    '8/24/2020 . 4:09 pm',
  ),
];

class MainContent extends StatelessWidget {
  const MainContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          PswsList(
            headline: 'Pinned passwords',
            psws: pinnedPsws,
          ),
          PswsList(
            headline: 'All passwords',
            psws: allPsws,
          ),
        ],
      );
}
