// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'package:webfeed_plus/domain/media/group.dart';
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';


class GrantMagFeed extends StatefulWidget { //primary builder
  final RssFeed feed;

  const GrantMagFeed({required this.feed, super.key});
  
  @override 
  State<GrantMagFeed> createState() => GrantMagFeedState(); 
}

class GrantMagFeedState extends State<GrantMagFeed> {
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  final Map<String, Future<String>> imageCache = {};
  String featuredImage = '';
  List<String> bookmarks = []; //disc version

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

    Future<void> loadBookmarks() async {
      final prefs = await SharedPreferences.getInstance();
      List<String> storedBookmarks = prefs.getStringList('bookmarks') ?? []; //sharedPref mirror
    setState(() {bookmarks = storedBookmarks;});
  }


 Future<void> addBookmark(String? link, String? title) async {
  if (link == null) return;

  final prefs = await SharedPreferences.getInstance();
  List<String> storedBookmarks = prefs.getStringList('bookmarks') ?? [];
  List<String> bookmarkDates = prefs.getStringList('bookmark_dates') ?? [];

  setState(() {
    if (storedBookmarks.contains(link)) {
      //remove bookmark
      final index = storedBookmarks.indexOf(link);
      storedBookmarks.removeAt(index);
      if (index < bookmarkDates.length) {
        bookmarkDates.removeAt(index);
      }
      this.bookmarks.remove(link); // update in-memory list
      prefs.remove('bookmark_title_$link'); // remove saved title
    } else {
      //add bookmark
      storedBookmarks.add(link);
      bookmarkDates.add(DateTime.now().millisecondsSinceEpoch.toString());
      this.bookmarks.add(link); // update in-memory list
      prefs.setString('bookmark_title_$link', title ?? link);
    }
  });

  //save changes to SharedPreferences
  await prefs.setStringList('bookmarks', storedBookmarks);
  await prefs.setStringList('bookmark_dates', bookmarkDates);
}

  Widget list() {
    const excludedCategories = {'PDF Issues', 'Flipbooks'};

    final filteredItems = widget.feed.items
        ?.where((item) {
          final categories = item.categories?.map((c) => c.value).toSet() ?? {};
          return categories.intersection(excludedCategories).isEmpty;
        })
        .toList() ?? [];

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        
        return ListTile(
          title: Text(item.title ?? ''),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.categories?.map((c) => c.value).join(', ') ?? ''),
              FutureBuilder<String>(
                future: imageCache.putIfAbsent(
                item.link ?? '',
                () => item.getFeaturedImage(),
              ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Image.network(
                    snapshot.data!,
                    fit: BoxFit.contain,
                  );
                },
              )
            ]),
          trailing: IconButton(
            icon: Icon(
              bookmarks.contains(item.link) ? Icons.bookmark : Icons.bookmark_add,
              color: bookmarks.contains(item.link) ? Colors.blue : null,
            ),
            onPressed: () => addBookmark(item.link, item.title),
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

  Future<void> _loadFeaturedImage(RssItem item) async { //fetches html and loads image
    final url = item.link;
    if (url == null) return;
    try {
      final response = await http.get(Uri.parse(url));//url parse

      if (response.statusCode != 200) return;
      final html = response.body;

      final ogMatch = RegExp( //og syntax for fallback
        r'<meta property="og:image" content="([^"]+)"',
        caseSensitive: false,
      ).firstMatch(html);

      if (ogMatch != null) {
        featuredImage = ogMatch.group(1) ?? '';
      } else {
        final photoMatch = RegExp( //wordpress specific featured image grabber
          r'<div class="photowrap">[\s\S]*?<img[^>]+src="([^"]+)"',
          caseSensitive: false,
        ).firstMatch(html);
        featuredImage = photoMatch?.group(1) ?? ''; //sets featured image to variable
      }
    } catch (e) {
      debugPrint('Image scrape failed: $e'); //error catch
    }

    // if (mounted) { //fallback for disposed widget
    //   setState(() => loadingImage = false);
    // }
  }
}

class ArticlePage extends StatefulWidget { //declares article page widget
  final RssItem article;
  const ArticlePage({required this.article, super.key}); //passes RSS widget key

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  String? featuredImage;
  bool loadingImage = true;
  String? url;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _loadFeaturedImage(); // async fetch starts here
  }

  void _showLargeImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(2),
          title: Container(
            decoration: BoxDecoration(),
            width: MediaQuery.of(context).size.width,
            child: Image.network(
              imageUrl,
              fit: BoxFit.fitWidth
              ),
          ),
        );
      },
    );
  }

  Future<void> _loadFeaturedImage() async { //fetches html and loads featured image
    url = widget.article.link;
    if (url == null) return;
    try {
      final encodedUrl = Uri.encodeComponent(url!);
      final response = await http.get(Uri.parse(url!));//url parse

      if (response.statusCode != 200) return;
      final html = response.body;

      final ogMatch = RegExp( //og syntax for fallback
        r'<meta property="og:image" content="([^"]+)"',
        caseSensitive: false,
      ).firstMatch(html);

      if (ogMatch != null) {
        featuredImage = ogMatch.group(1);
      } else {
        final photoMatch = RegExp( //wordpress specific featured image grabber
          r'<div class="photowrap">[\s\S]*?<img[^>]+src="([^"]+)"',
          caseSensitive: false,
        ).firstMatch(html);
        featuredImage = photoMatch?.group(1); //sets featured image to variable
      }
    } catch (e) {
      debugPrint('Image scrape failed: $e'); //error catch
    }

    if (mounted) { //fallback for disposed widget
      setState(() => loadingImage = false);
    }
  }
  
  
    //article list builder
   @override
   Widget build(BuildContext context){
    final screenWidth = MediaQuery.of(context).size.width;
    bool _isInteracting = false;
    String html = widget.article.content?.value ?? widget.article.description ?? '';
      debugPrint('HTML: ');
      debugPrint(html);

      return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100, //max height
        title: AutoSizeText(
          widget.article.title ?? 'Article',
          maxLines: 3,                      
          minFontSize: 18,                  
          overflow: TextOverflow.ellipsis,   //title bounds and wrapping
        ),
      ),

       body: SingleChildScrollView(
        physics: _isInteracting
        ? const NeverScrollableScrollPhysics()
        : const AlwaysScrollableScrollPhysics()
        ,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loadingImage) const LinearProgressIndicator(), //loading bar 
            if (!loadingImage && featuredImage != null)
              GestureDetector( //makes featured images clickable using a GestureDetector
                onTap: () => _showLargeImage(context, featuredImage!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    featuredImage!,
                    width: screenWidth,
                    fit: BoxFit.fitWidth,
                    loadingBuilder: (context, child, loadingProgress) =>
                      (loadingProgress == null) ? child : CircularProgressIndicator(),
                  ),
                ),
              ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Html(
                data: html,
                extensions: [
                  TagExtension(
                    tagsToExtend: {"img"}, //handles img rendering in a seperate builder
                    builder: (context) {
                      final src = context.attributes['src'] ?? '';
                      if (src.isEmpty) return const SizedBox.shrink();
                      return Padding( //padding details for imgs
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child:
                        GestureDetector(
                          onScaleStart: (_) {},
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _showLargeImage(this.context, src),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: InteractiveViewer(
                                panEnabled: true,
                                scaleEnabled: true,
                                //clipBehavior: Clip.none,
                                minScale: 1,
                                maxScale: 4.0,
                                onInteractionStart: (_) {
                                  setState(() => _isInteracting = true);
                                },
                                onInteractionEnd: (_) {
                                  setState(() => _isInteracting = false);
                                },
                                child: Image.network(
                                  src,
                                  width: screenWidth,
                                  fit: BoxFit.fitWidth, //uses flutter boxfit for proper aspect ratio rendering
                              ),
                            ),
                          )
                        ),
                      );
                    },
                  ),
                ],

                style: { //html style rendering for figs (captions) and text
                  "figure": Style(
                    width: Width(screenWidth),
                    fontSize: FontSize(11), //captions
                    height: Height.auto(),
                    display: Display.block,
                    textAlign: TextAlign.center,
                    margin: Margins.symmetric(vertical: 16),
                    padding: HtmlPaddings.only(right: 16.0),
                  ),

                  "p": Style(
                    fontSize: FontSize(14.0)
                  ),
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}

extension ImageParsing on RssItem {
  Future<String> getFeaturedImage() async {
    final url = link;
    String featuredImage = '';
    if (url == null) {
      return '';
    }
    try {
      final response = await http.get(Uri.parse(url //featured image fetch RECONVERT WHEN SERVER UP
      ));//url parse

      if (response.statusCode != 200) return '';
      final html = response.body;

      final ogMatch = RegExp( //og syntax for fallback
        r'<meta property="og:image" content="([^"]+)"',
        caseSensitive: false,
      ).firstMatch(html);

      if (ogMatch != null) {
        featuredImage = ogMatch.group(1) ?? '';
      } else {
        final photoMatch = RegExp( //wordpress specific featured image grabber
          r'<div class="photowrap">[\s\S]*?<img[^>]+src="([^"]+)"',
          caseSensitive: false,
        ).firstMatch(html);
        featuredImage = photoMatch?.group(1) ?? ''; //sets featured image to variable
      }
    } catch (e) {
      debugPrint('Image scrape failed: $e'); //error catch
    }
    // final response = await http.get(Uri.parse(url));
    // final html = response.body;
    // final ogMatch = RegExp( //og syntax for fallback
    //   r'<meta property="og:image" content="([^"]+)"',
    //   caseSensitive: false,
    // ).firstMatch(html);
    return featuredImage; //error catch
  }
}

class GrantMagBookmarks extends StatefulWidget {
  final RssFeed feed;

  const GrantMagBookmarks({required this.feed, super.key});

  @override 
  State<GrantMagBookmarks> createState() => GrantMagBookmarksState();
}

class GrantMagBookmarksState extends State<GrantMagBookmarks> {
  List<String> bookmarks = [];
  Map<String, int> bookmarkDates = {};
  String bookmarkSort = "Publish Date";

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance(); //across multiple instances bookmark list 

    final links = prefs.getStringList('bookmarks') ?? [];
    final dates = prefs.getStringList('bookmark_dates') ?? [];

    Map<String, int> tempMap = {};

    for (int i = 0; i < links.length; i++) {
      tempMap[links[i]] = int.tryParse(dates[i]) ?? 0;
    }

    setState(() {
      bookmarks = links;
      bookmarkDates = tempMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    var bookmarkedItems = widget.feed.items
        ?.where((item) => bookmarks.contains(item.link)) //sends sorted items to list
        .toList() ?? [];
      
    if (bookmarkSort == 'Publish Date') {
      bookmarkedItems.sort((a, b) => 
          (b.pubDate ?? DateTime(0)).compareTo(a.pubDate ?? DateTime(0)));

    } 
    
    else if (bookmarkSort == 'Bookmark Date') {
      bookmarkedItems.sort((a, b) {
        final aDate = bookmarkDates[a.link] ?? 0;
        final bDate = bookmarkDates[b.link] ?? 0;
        return bDate.compareTo(aDate); // newest first
      });

    } 
    
    else if (bookmarkSort == 'Article Name') {
      bookmarkedItems.sort((a, b) =>
          (a.title ?? '').compareTo(b.title ?? ''));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            const Text("Bookmarked Articles"),
            Text(bookmarkSort, style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          PopupMenuButton<String>( //sorting button dropdown
            onSelected: (value) {
              setState(() {
                bookmarkSort = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Publish Date', child: Text('Publish Date')),
              const PopupMenuItem(value: 'Bookmark Date', child: Text('Bookmark Date')),
              const PopupMenuItem(value: 'Article Name', child: Text('Article Name')),
            ],
          ),
        ]
      ),
      
      body: bookmarkedItems.isEmpty
          ? const Center(child: Text("No bookmarks yet"))
          : ListView.builder(
              itemCount: bookmarkedItems.length,
              itemBuilder: (context, index) {
                final item = bookmarkedItems[index];
                return ListTile(
                  title: Text(item.title ?? ''),
                  subtitle: Text(
                    () {
                      final time = bookmarkDates[item.link ?? ''];
                      if (time == null || time == 0) return '';
                      final date = DateTime.fromMillisecondsSinceEpoch(time);
                      return "Saved ${date.month}/${date.day}/${date.year}";
                    }(),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticlePage(article: item),
                    ),
                  ),
                );
              },
            ),
    );
  }
}