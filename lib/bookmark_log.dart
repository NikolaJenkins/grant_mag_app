import 'package:shared_preferences/shared_preferences.dart';


class BookmarkService {
  static Future<List<String>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList('bookmarks') ?? [];
  }

  static Future<void> toggleBookmark(
    String link,
    String? title,
  ) async {
    final prefs = await SharedPreferences.getInstance(); //declaring shared list

    List<String> storedBookmarks =
        prefs.getStringList('bookmarks') ?? [];

    List<String> bookmarkDates =
        prefs.getStringList('bookmark_dates') ?? [];

    if (storedBookmarks.contains(link)) {
      final index = storedBookmarks.indexOf(link);

      storedBookmarks.removeAt(index);

      if (index < bookmarkDates.length) { //remove based on index
        bookmarkDates.removeAt(index);
      }

      prefs.remove('bookmark_title_$link');
    } 
    
    else {
      storedBookmarks.add(link);

      bookmarkDates.add(
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      prefs.setString( //list pref setters
        'bookmark_title_$link',
        title ?? link,
      );
    }

    await prefs.setStringList(
      'bookmarks',
      storedBookmarks,
    );

    await prefs.setStringList(
      'bookmark_dates',
      bookmarkDates,
    );
  }
}