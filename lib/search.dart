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

class GrantMagSearch extends StatefulWidget {
  final RssFeed feed;

  const GrantMagSearch({required this.feed, super.key});

  @override
  State<GrantMagSearch> createState() => GrantMagSearchState();
}

class GrantMagSearchState extends State<GrantMagSearch> {

  FocusNode _searchFocusNode = FocusNode();
  String? _searchingWithQuery;
  String? selectedFilter = 'Title';
  final List<String> filterOptions = ['Title', 'Author', 'Genre'];
  late final List<DropdownMenuEntry<String>> menuEntries = filterOptions.map(
    (String filter) => DropdownMenuEntry<String>(
      value: filter,
      label: filter,
    )
  ).toList();
  final TextEditingController filterController = TextEditingController();
  final Map<String, Future<String>> imageCache = {};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(title: const Text("Article Search")),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  focusNode: _searchFocusNode,
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                  leading: const Icon(Icons.search),
                  hintText: 'Search',
                  trailing: <Widget>[DropdownMenu<String>(
                    initialSelection: "Title",
                    controller: filterController,
                    requestFocusOnTap: false,
                    enableSearch: false,
                    label: const Text('Filter'),
                    inputDecorationTheme: const InputDecorationTheme(
                      filled: false,
                      border: InputBorder.none,
                    ),
                    onSelected: (String? filter) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    dropdownMenuEntries: menuEntries,
                  ),]
                );
              },
              suggestionsBuilder: (BuildContext context, SearchController controller) {
                // _searchingWithQuery = controller.text;
                // final options = widget.feed.items?.where(
                //   (item) =>
                // )
                var searchResults = switch (selectedFilter) {
                  'Title' =>
                    widget.feed.items
                    ?.where((item) =>
                      item.title!.toLowerCase().contains(controller.text.toLowerCase())
                    ),
                  'Author' =>
                    widget.feed.items
                    ?.where((item) =>
                      (item.author ?? '').toLowerCase().contains(controller.text.toLowerCase())
                    ),
                  _ =>
                    widget.feed.items
                    ?.where((item) =>
                      (item.categories?.map((c) => c.value).join(', ') ?? '').toLowerCase().contains(controller.text.toLowerCase())
                    ),
                }!.toList();
                return [
                  ListView.builder(
                    itemCount: searchResults.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = searchResults[index];
                      return ListTile(
                        title: Text(item.title ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.categories?.map((c) => c.value).join(', ') ?? ''),
                            Text(item.author ?? ''),
                            // FutureBuilder<String>(
                            //   future: imageCache.putIfAbsent(
                            //     item.link ?? '',
                            //     () => item.getFeaturedImage(),
                            //   ),
                            //   builder: (context, snapshot) {
                            //     if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            //       return const SizedBox.shrink();
                            //     }
                            //     return Image.network(
                            //       snapshot.data!,
                            //       fit: BoxFit.contain,
                            //     );
                            //   },
                            // )
                          ]),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArticlePage(article: item),
                          )
                        )
                      );
                    }
                  )
                ];
              },
            )
          )
        )
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }
}

typedef FilterEntry = DropdownMenuEntry<String>;