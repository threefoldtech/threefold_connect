import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CommonPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String description;
  final double? heightPercentage;
  final double? widthPercentage;

  const CommonPage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.description,
    this.heightPercentage = 100,
    this.widthPercentage = 300,
  }) : super(key: key);

  @override
  State<CommonPage> createState() => _CommonPageState();
}

class _CommonPageState extends State<CommonPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.9,
              child: Column(children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: widget.title == 'Welcome to'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (widget.subtitle.isNotEmpty)
                  Text(
                    widget.subtitle,
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                SizedBox(
                  height: widget.subtitle.isEmpty
                      ? MediaQuery.of(context).size.height * 0.15
                      : MediaQuery.of(context).size.height * 0.04,
                ),
                widget.imagePath.endsWith('.svg')
                    ? SvgPicture.asset(
                        widget.imagePath,
                        alignment: Alignment.center,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSurface,
                          BlendMode.srcIn,
                        ),
                        width: widget.widthPercentage != null
                            ? MediaQuery.of(context).size.width *
                                widget.widthPercentage!
                            : null,
                        height: widget.heightPercentage != null
                            ? MediaQuery.of(context).size.width *
                                widget.heightPercentage!
                            : null,
                      )
                    : Image.asset(
                        widget.imagePath,
                        fit: BoxFit.contain,
                        width: widget.widthPercentage != null
                            ? MediaQuery.of(context).size.width *
                                widget.widthPercentage!
                            : null,
                        height: widget.heightPercentage != null
                            ? MediaQuery.of(context).size.width *
                                widget.heightPercentage!
                            : null,
                      ),
              ]),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 100,
              height: MediaQuery.of(context).size.height * 0.2,
              child: Text(
                widget.description,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
