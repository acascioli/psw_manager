import 'package:flutter/material.dart';
import 'package:psw_manager/widgets/search_bar.dart';
import 'package:psw_manager/widgets/new_psw_form.dart';
import 'package:psw_manager/models/psw.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants.dart';

class TopBar extends StatelessWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final bool _isNotSm = _size.width >= screenSm;

    return Container(
      height: 145,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: .3,
            color: darkColor.withOpacity(.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isNotSm)
            const SizedBox(
              height: 18,
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: _isNotSm
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _isNotSm ? 24 : 12,
                ),
                child: const Text(
                  'Passwords',
                  style: TextStyle(
                    color: darkColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              if (_isNotSm) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _isNotSm ? 24 : 12,
                  ),
                  child: TextButton.icon(
                    icon: const Icon(
                      FontAwesomeIcons.plus,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => NewPswForm(
                          receivedPsw: Psw(0, '', '', '', '', '', false, ''),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 12,
                      ),
                      backgroundColor: accentColor,
                      enableFeedback: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    label: const Text(
                      ' Add new password',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _isNotSm ? 24 : 12,
              ),
              child: const SearchBar(),
            ),
          )
        ],
      ),
    );
  }
}
