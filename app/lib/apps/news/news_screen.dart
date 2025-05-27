import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:xml2json/xml2json.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final Xml2Json xml2json = Xml2Json();
  static const int articlesPerPage = 20;
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);
  final String newsUrl = Globals().newsUrl;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(getArticles);
  }

  Future<void> getArticles(int pageKey) async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw Exception('No internet connection. Please check your network.');
      }

      final response = await http.get(Uri.parse(newsUrl)).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Loading news feed timed out');
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load news feed: ${response.statusCode}');
      }
      xml2json.parse(response.body);

      var data = json.decode(xml2json.toGData());
      var allEntries =
          List<Map<String, dynamic>>.from(data['feed']['entry'] ?? []);

      final startIndex = pageKey * articlesPerPage;
      final endIndex =
          (startIndex + articlesPerPage).clamp(0, allEntries.length);
      final newArticles = allEntries.sublist(startIndex, endIndex);

      final isLastPage = newArticles.length < articlesPerPage;
      isLastPage
          ? _pagingController.appendLastPage(newArticles)
          : _pagingController.appendPage(newArticles, pageKey + 1);

      _isLoading = false;
      _errorMessage = null;
    } on TimeoutException catch (e) {
      _handleError(
          'Loading news feed timed out. Please check your connection.', e);
    } on Exception catch (e) {
      _handleError(
          e.toString().contains('No internet connection')
              ? 'No internet connection. Please check your network.'
              : 'Failed to load news feed. Please try again.',
          e);
    }
  }

  void _handleError(String message, Exception error) {
    logger.e('News feed error: $message', error: error);

    _isLoading = false;
    _errorMessage = message;

    _pagingController.error = message;

    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _refreshNews() async {
    _pagingController.refresh();
    return Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'News',
      content: RefreshIndicator(
        onRefresh: _refreshNews,
        child: PagedListView<int, Map<String, dynamic>>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
            itemBuilder: (context, entry, index) =>
                buildArticleCard(entry, context),
            firstPageProgressIndicatorBuilder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text('Loading Articles...',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            firstPageErrorIndicatorBuilder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _refreshNews,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
            noItemsFoundIndicatorBuilder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No articles found',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildArticleCard(Map<String, dynamic> entry, BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    final title = entry['title']?['\$t'] ?? 'No Title';
    final content =
        (entry['content']?['\$t'] ?? 'No Content').replaceAll(r'\\n', '');
    final link = entry['link'] is List
        ? entry['link'].first['href']
        : entry['link']['href'];

    final publishedDate =
        DateTime.tryParse(entry['published']?['\$t'] ?? '')?.toLocal() ??
            DateTime.now();
    final formattedDate = timeago.format(publishedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _launchURL(link),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/tf_chain.png',
                        color: onSurfaceColor, height: 20, width: 20),
                    const SizedBox(width: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'THREEFOLD - ',
                            style: theme.textTheme.bodySmall!
                                .copyWith(color: onSurfaceColor),
                          ),
                          TextSpan(
                            text: formattedDate,
                            style: theme.textTheme.bodySmall!
                                .copyWith(color: onSurfaceColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold, color: onSurfaceColor),
                ),
                const SizedBox(height: 5),
                HtmlWidget(
                  content.length > 200
                      ? '${content.substring(0, 200)}...'
                      : content,
                  textStyle: TextStyle(color: onSurfaceColor),
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
                      onPressed: () => _launchURL(link),
                      child: Text('Read more',
                          style: theme.textTheme.bodyLarge!
                              .copyWith(color: theme.colorScheme.primary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
