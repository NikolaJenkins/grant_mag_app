import 'dart:collection';

import 'package:http/http.dart' as http;
import 'package:webfeed_plus/domain/media/group.dart';
import 'package:webfeed_plus/domain/media/group.dart';
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'rss.dart';

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
        toolbarHeight: 75,
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
                return Dismissible(
                  key: Key(item.link ?? index.toString()),
                  direction: DismissDirection.endToStart, // swipe left
                  background: Container(
                    color: Colors.red[300],
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    final prefs = await SharedPreferences.getInstance();

                    final links = prefs.getStringList('bookmarks') ?? [];
                    final dates = prefs.getStringList('bookmark_dates') ?? [];

                    final link = item.link;
                    if (link == null) return;

                    final index = links.indexOf(link);
                    if (index != -1) {
                      links.removeAt(index);
                      if (index < dates.length) {
                        dates.removeAt(index);
                      }

                      await prefs.setStringList('bookmarks', links);
                      await prefs.setStringList('bookmark_dates', dates);
                      prefs.remove('bookmark_title_$link');
                    }

                    setState(() {
                      bookmarks.remove(link);
                      bookmarkDates.remove(link);
                    });
                  },
                  child:
                ListTile(
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
                ),
                );
              },
            ),
    );
  }
}
