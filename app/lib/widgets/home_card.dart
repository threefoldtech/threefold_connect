import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/globals.dart';

class HomeCardWidget extends StatelessWidget {
  const HomeCardWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.pageNumber,
    this.fullWidth = false,
  });

  final String name;
  final IconData icon;
  final int pageNumber;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    Globals globals = Globals();
    final size = MediaQuery.of(context).size.width;
    const double margin = 3;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      margin: const EdgeInsets.all(margin),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
              height: size / 8,
              width: fullWidth ? size * 2 / 2.5 + 2 * margin : size / 2.5,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
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
