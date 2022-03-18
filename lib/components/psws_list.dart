import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:psw_manager/models/psw.dart';
import 'package:psw_manager/constants.dart';
import 'package:psw_manager/widgets/psw_card.dart';

class PswsList extends StatelessWidget {
  final String headline;
  final List<Psw> psws;

  const PswsList({
    Key? key,
    required this.headline,
    required this.psws,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final bool _isSm = _size.width <= screenSm;
    final bool _isLg = _size.width <= screenLg;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline.toUpperCase(),
            style: const TextStyle(
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
            itemCount: psws.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _isSm ? 1 : (_isLg ? 2 : 3),
              childAspectRatio: 1.63,
            ),
            itemBuilder: (context, index) => PswCard(
              psw: psws[index],
            ),
          ),
        ],
      ),
    );
  }
}
