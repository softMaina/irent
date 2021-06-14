import 'package:irent/sizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../sizeConfig.dart';

class DefaultButton extends StatelessWidget{

  const DefaultButton({
    Key key,
    this.text,
    this.press
  }) : super(key: key);
  final String text;
  final Function press;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
        width: double.infinity,
        height: getProportionateScreenHeight(56.0),
        child: RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: Theme.of(context).buttonColor,
            onPressed: press,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    text,
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(18),
                      color: Colors.white,
                    )
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                )
              ],
            )
        )
    );
  }
}