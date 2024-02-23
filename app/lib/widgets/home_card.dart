import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/globals.dart';

class HomeCardWidget extends StatelessWidget {
  const HomeCardWidget(
      {super.key,
      required this.name,
      required this.icon,
      required this.pageNumber});

  final String name;
  final IconData icon;
  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    Globals globals = Globals();
    final size = MediaQuery.of(context).size.width;
    return  Card(
      margin: const EdgeInsets.all(3),
      shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      child: InkWell(
        onTap: () {
          globals.tabController.animateTo(pageNumber);
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              height: size / 4,
              width: size / 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
