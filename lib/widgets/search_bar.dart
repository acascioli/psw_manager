import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:psw_manager/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.zero,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextField(
                cursorColor: textColor,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search passwords',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(
                    FontAwesomeIcons.search,
                    size: 22,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(
              FontAwesomeIcons.businessTime,
              color: textColor,
              size: 16,
            ),
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
              side: const BorderSide(
                width: .3,
                color: textColor,
              ),
              backgroundColor: Colors.transparent,
              enableFeedback: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            label: RichText(
              text: const TextSpan(
                text: 'Sort: ',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: 'Chronological',
                    style: TextStyle(
                        color: darkColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
