import 'dart:ffi';

class Psw {
  final int id;
  final String title;
  final String username;
  final String password;
  final String pswIcon;
  final String pswColor;
  final bool pinned;
  final String createdOn;

  Psw(
    this.id,
    this.title,
    this.username,
    this.password,
    this.pswIcon,
    this.pswColor,
    this.pinned,
    this.createdOn,
  );
}
