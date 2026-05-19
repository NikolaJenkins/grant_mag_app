import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'bookmark_log.dart';
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
  final ScrollController _scrollController = ScrollController();
  String featuredImage = '';
  List<String> bookmarks = []; 
  int currentPage = 0;
  final int pageSize = 25;
  final allowedTags = {
    'featured',
    'features',
    'feature',
  };

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    bookmarks =
        await BookmarkService.loadBookmarks();

    if (mounted) {
      setState(() {});
    }
  }

Widget list() { //article list builder
  final filteredItems = widget.feed.items?.where((item) {
    final categories = item.categories
            ?.map((c) => c.value.toLowerCase())
            .toSet() ??
        {};
    return categories.any((cat) => allowedTags.contains(cat));
  }).toList() ?? [];
  final start = currentPage * pageSize;
  final end = (start + pageSize > filteredItems.length)
    ? filteredItems.length
    : start + pageSize;

  final currentItems = filteredItems.sublist(start, end);
  return Column(children: [
    Expanded(child: ListView.builder(
      controller: _scrollController,
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
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: snapshot.hasData && snapshot.data!.isNotEmpty
                      ? Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: Image.asset('assets/blendertimer-load-37.gif'),
                                      ),
                              FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            ],
                        )
                        : Container(color: Colors.grey[300]), //fixing scroll physics using preset container
                  );
                },
              )
            ]),
            trailing: IconButton( //bookmark icon
            icon: Icon(
              bookmarks.contains(item.link) ? Icons.bookmark : Icons.bookmark_add,
              color: bookmarks.contains(item.link) ? Colors.blue : null,
            ),
            onPressed: () async { //new bookmark adding function, calling bookmarkservice
              final link = item.link;

              if (link == null) return;

              await BookmarkService.toggleBookmark(
                link,
                item.title,
              );

              setState(() {
                if (bookmarks.contains(link)) {
                  bookmarks.remove(link);
                } else {
                  bookmarks.add(link);
                }
              });
            },
          ),
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
              ? () {
                  setState(() => currentPage--);
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              : null,
        ),
        Text('Page ${currentPage + 1}'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: end < filteredItems.length
              ? () {
                  setState(() => currentPage++);
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
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