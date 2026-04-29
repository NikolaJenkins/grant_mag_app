import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:flutter/material.dart';

import 'rss.dart';

class FeaturedArticles extends StatefulWidget { //primary builder
  final RssFeed feed;

  const FeaturedArticles({required this.feed, super.key});
  
  @override 
  State<FeaturedArticles> createState() => FeaturedArticlesState(); 
}

class FeaturedArticlesState extends State<FeaturedArticles> {
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  final Map<String, Future<String>> imageCache = {};
  String featuredImage = '';
  List<String> bookmarks = []; 
  int currentPage = 0;
  final int pageSize = 25;

  @override
  void initState() {
    super.initState();
  }

Widget list() { //article list builder
  final filteredItems = widget.feed.items
                    ?.where((item) =>
                      (item.categories?.map((c) => c.value).join(', ') ?? '').toLowerCase().contains('Featured'.toLowerCase())
                    )
                .toList() ?? [];
  final start = currentPage * pageSize;
  final end = (start + pageSize > filteredItems.length)
    ? filteredItems.length
    : start + pageSize;

  final currentItems = filteredItems.sublist(start, end);
  return Column(children: [
    Expanded(child: ListView.builder(
      physics: const CustomScrollPhysics(),
      itemCount: currentItems.length,
      itemBuilder: (context, index) {
        final item = currentItems[index];
        
        return ListTile(
          title: Text(item.title ?? ''),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.categories?.map((c) => c.value).join(', ') ?? ''),
              Text(item.author ?? ''),
              FutureBuilder<String>(
                future: imageCache.putIfAbsent(
                  item.link ?? '',
                  () => item.getFeaturedImage(),
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              )
            ]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticlePage(article: item),
              ),
            );
          },
        );
      },
    )
  ),

  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: currentPage > 0
              ? () => setState(() => currentPage--)
              : null,
        ),
        Text('Page ${currentPage + 1}'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: end < filteredItems.length
              ? () => setState(() => currentPage++)
              : null,
          ),
        ],
      ),
    ],
  );
}
  

  @override 
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () async {
        imageCache.clear();
        setState(() {});
      }, // no-op for now
      child: list(),
    );
  }
}