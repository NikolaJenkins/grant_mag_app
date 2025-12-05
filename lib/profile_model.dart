import 'package:flutter/foundation.dart';
import 'package:grant_mag_app/profile.dart';

class ProfileModel extends ChangeNotifier{
  Genres? _genre = Genres.academics;
  Genres? get genre => _genre;

  void changeGenre(Genres? newGenre) {
    _genre = newGenre;
    notifyListeners();
  }
}