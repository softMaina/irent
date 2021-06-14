import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BuyerHistory extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Bid History'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          // list of all the bids on an item
          children: [
            Container(
                child: Text('Item Specs')
            ),
            Container(
                child: Column(
                  children: [
                    Container(
                        child: Text('This Item Has 100 bids for 100k by Allan')
                    )
                  ],
                )
            )
          ],
        ),
      ),
    );
  }

}