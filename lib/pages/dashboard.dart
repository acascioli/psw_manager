import 'package:flutter/material.dart';
import 'package:psw_manager/components/main_content.dart';
import 'package:psw_manager/layouts/main_layout.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MainLayout(
        child: MainContent(),
      );
}
