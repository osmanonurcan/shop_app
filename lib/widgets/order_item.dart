import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders.dart' as orderData;

class OrderItem extends StatefulWidget {
  final orderData.OrderItem order;
  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
      height:
          _expanded ? min(widget.order.cartItems.length * 20 + 110.0, 200) : 95,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('\$${widget.order.amount}'),
              subtitle: Text(
                  DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime)),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: _expanded
                  ? min(widget.order.cartItems.length * 20 + 10.0, 100)
                  : 0,
              child: ListView(
                children: [
                  ...widget.order.cartItems
                      .map((cartItem) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${cartItem.title}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${cartItem.quantity}x \$${cartItem.price}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ))
                      .toList()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
