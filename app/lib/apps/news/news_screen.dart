import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:xml2json/xml2json.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final Xml2Json xml2json = Xml2Json();
  List topStories = [];
  bool isLoading = false;
  bool isInitialLoading = true;
  int articlesPerPage = 5;
  int currentPage = 0;
  final ScrollController _scrollController = ScrollController();
  final newsUrl = Globals().newsUrl;


  Future<void> getArticles() async {
    setState(() {
      isLoading = true;
      if (currentPage == 0) {
        isInitialLoading = true;
      }
    });

    final url = Uri.parse(newsUrl);
    final response = await http.get(url);

    xml2json.parse(response.body);

    var jsondata = xml2json.toGData();
    var data = json.decode(jsondata);

    var allEntries = data['feed']['entry'] ?? [];

    setState(() {
      topStories.addAll(allEntries
          .skip(currentPage * articlesPerPage)
          .take(articlesPerPage)
          .toList());
      currentPage++;
      isLoading = false;
      if (currentPage > 0) {
        isInitialLoading = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getArticles();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getArticles();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'News',
      content: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: topStories.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == topStories.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                var entry = topStories[index];

                var title = entry['title']?['\$t'] ?? 'No Title';
                var content = entry['content']?['\$t'] ?? 'No Content';
                var link = entry['link'] is List
                    ? entry['link'].first['href']
                    : entry['link']['href'];

                var publishedDateStr = entry['published']?['\$t'] ?? '';
                DateTime publishedDate;
                try {
                  publishedDate = DateTime.parse(publishedDateStr);
                } catch (e) {
                  publishedDate = DateTime.now();
                }

                String formattedDate = timeago.format(publishedDate);

                content = cleanHtmlContent(content);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.background,
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/tft_icon.png',
                                height: 20,
                                width: 20,
                              ),
                              const SizedBox(width: 2),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: 'THREEFOLD - ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            )),
                                    TextSpan(
                                        text: formattedDate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                          ),
                          const SizedBox(height: 5),
                          HtmlWidget(
                            content.length > 200
                                ? '${content.substring(0, 200)}...'
                                : content,
                            textStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            onTapUrl: (url) {
                              if (url.isNotEmpty) {
                                _launchURL(url);
                                return true;
                              }
                              return false;
                            },
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  _launchURL(link);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                ),
                                child: Text(
                                  'Read more',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading && !isInitialLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String cleanHtmlContent(String content) {
    return content.replaceAll(r'\\n', '');
  }
}
