import 'package:psw_manager/models/menu_item.dart';
import 'package:psw_manager/models/psw.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  bool isDesktop = true;
  MenuItem? menuItem;

  List<Map<String, dynamic>> _psws = [];
  List<Psw> allPsws = [];
  List<Psw> pinnedPsws = [];

  void refreshPswsController(data) {
    allPsws = [];
    pinnedPsws = [];
    _psws = data;
    for (var psw in _psws) {
      allPsws.add(
        Psw(
          psw['title'],
          psw['username'],
          psw['password'],
          psw['userAvatar'],
          (psw['pinned'] == 'FALSE') ? false : true,
          psw['createdOn'],
        ),
      );
      if (psw['pinned'] != 'FALSE') {
        pinnedPsws.add(
          Psw(
            psw['title'],
            psw['username'],
            psw['password'],
            psw['userAvatar'],
            true,
            psw['createdOn'],
          ),
        );
      }
    }
    update();
  }

  void toggleSideBar() {
    print('TOGGLING SIDE');

    isDesktop = !isDesktop;
    update();
  }

  void setCurrentItem(MenuItem item) {
    menuItem = item;
  }

  MenuItem? get item => menuItem;
}
