import 'dart:ffi';

class Psw {
  final int id;
  final String title;
  final String username;
  final String password;
  final String userAvatar;
  final bool pinned;
  final String createdOn;

  Psw(
    this.id,
    this.title,
    this.username,
    this.password,
    this.userAvatar,
    this.pinned,
    this.createdOn,
  );
}
