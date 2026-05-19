// ignore_for_file: avoid_print

import 'dart:collection';

import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:webfeed_plus/domain/media/group.dart';
import 'package:webfeed_plus/domain/media/group.dart';
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
class CustomScrollPhysics extends BouncingScrollPhysics {
  const CustomScrollPhysics({super.parent});

  @override
    CustomScrollPhysics applyTo(ScrollPhysics ? ancestor) {
      return CustomScrollPhysics(parent: buildParent(ancestor));
    }
  
  @override
  double get maxFlingVelocity => 4000.0;

  @override
  SpringDescription get spring => const SpringDescription(
      mass: 1.0,
      stiffness: 60.0, // lower = slower bounce
      damping: 25.0,    // higher = less oscillation
    );

}


class GrantMagFeed extends StatefulWidget { //primary builder
  final RssFeed feed;

  const GrantMagFeed({required this.feed, super.key});
  
  @override 
  State<GrantMagFeed> createState() => GrantMagFeedState(); 
}

class GrantMagFeedState extends State<GrantMagFeed> {
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  final Map<String, Future<String>> imageCache = {};
  final ScrollController _scrollController = ScrollController();
  String featuredImage = '';
  List<String> bookmarks = []; 
  int currentPage = 0;
  final int pageSize = 25;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

Widget list() { //article list builder
  const excludedCategories = {'PDF Issues', "PDF Issue", 'Flipbooks', "Flipbook", "Video", "Videos", "Interactive", "Quiz", "Quizzes"};
  final filteredItems = widget.feed.items?.where((item) {
          final categories = item.categories?.map((c) => c.value).toSet() ?? {};
          return categories.intersection(excludedCategories).isEmpty;
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
                        : Container(color: Colors.grey[300]),
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

class ArticlePage extends StatefulWidget { //declares article page widget
  final RssItem article;
  const ArticlePage({required this.article, super.key}); //passes RSS widget key

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  bool _isInteracting = false;
  String? featuredImage;
  bool loadingImage = true;
  String? url;
  String? imageUrl;
  int tapCount = 0; //For stopping scroll when zooming in on photoview
  @override
  void initState() {
    super.initState();
    _loadFeaturedImage(); // async fetch starts here
  }

  void _showLargeImage(BuildContext context, String imageUrl) { //Shows an image when one is tapped on in the article. Allows zooming in and scrolling to dismiss
    Image image = Image.network(imageUrl);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
            ),
            Listener(
              onPointerDown: (event) => setState(() => tapCount++),
              onPointerUp: (event) => setState(() => tapCount--),
              onPointerCancel: (event) => setState(() => tapCount--),
              child: Dismissible( //Doesn't quite work yet
                key: UniqueKey(),
                direction: tapCount > 1 //Dismisses image only when two fingers are not on the screen, allowing for pinch zooming without accidentally dismissing (thanks vscode ai for predicting this comment)
                    ? DismissDirection.none
                    : DismissDirection.vertical,
                onDismissed: (direction) => Navigator.of(context).pop(),
                child: ClipRRect(
                  child: PhotoView( // Image zooming
                  imageProvider: NetworkImage(imageUrl),
                  backgroundDecoration: BoxDecoration(
                    color: Colors.transparent
                  ),
                  
                  loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator()),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                            ),
                ),
              ),
            ),
          ]
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
    String html = widget.article.content?.value ?? widget.article.description ?? '';
      debugPrint('HTML: ');
      debugPrint(html);

      return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 100, //max height
        title: AutoSizeText(
          style: TextStyle(
            fontFamily: 'Georgia',
            color: Colors.white
          ),
          widget.article.title ?? 'Article',
          maxLines: 3,                     
          minFontSize: 18,                  
          overflow: TextOverflow.ellipsis,   //title bounds and wrapping
        ),
      ),

       body: SingleChildScrollView(
        physics: _isInteracting
        ? const NeverScrollableScrollPhysics()
        : const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loadingImage) const LinearProgressIndicator(), //loading bar 
            if (!loadingImage && featuredImage != null)
              GestureDetector( //makes images clickable using a GestureDetector
                onTap: () => _showLargeImage(context, featuredImage!),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: GestureDetector(
                            onTap: () => _showLargeImage(this.context, src),
                            child: Image.network(
                              src,
                              width: screenWidth,
                              fit: BoxFit.fitWidth,
                               //uses flutter boxfit for proper aspect ratio rendering
                                                          ),
                          ),
                                                  ),
                      );
                    },
                  ),
                ],

                style: { //html style rendering for figs (captions) and text
                  "figure": Style(
                    width: Width(screenWidth),
                    fontSize: FontSize(16), //caption text styling
                    height: Height.auto(),
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight(500),
                    display: Display.block,
                    textAlign: TextAlign.center,
                    margin: Margins.symmetric(vertical: 48),
                    padding: HtmlPaddings.only(right: 16.0),
                  ),

                  "p": Style(
                    fontFamily: 'Georgia', //body text styling
                    fontSize: FontSize(18),
                    fontWeight: FontWeight(500),
                    margin: Margins.symmetric(horizontal: 25),
                    padding: HtmlPaddings.only(bottom: 20.0)
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