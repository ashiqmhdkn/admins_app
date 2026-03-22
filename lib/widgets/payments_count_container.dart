import 'package:flutter/material.dart';

class Paymentcountcontainer extends StatelessWidget {
  const Paymentcountcontainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 167,
        width: double.infinity,
        decoration: BoxDecoration(
          border: BoxBorder.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.tertiary,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Number of Payments",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 22),
                  ),
                  SizedBox(width: 60),
                  IconButton(onPressed: () {}, icon: Icon(Icons.north_east)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: const Text(
                  "666",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 38),
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Per Persons",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
