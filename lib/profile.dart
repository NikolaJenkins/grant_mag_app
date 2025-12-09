import 'package:flutter/material.dart';
import 'package:grant_mag_app/profile_model.dart';
import 'package:grant_mag_app/theme_model.dart';
import 'package:provider/provider.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {

  @override 
  Widget build(BuildContext context) {
    void log(String message) {
      print(message);
    }

    return Consumer2<ThemeModel, ProfileModel>(
      builder: (context, provider1, provider2, child) => Scaffold(
      appBar: AppBar(title: const Text("Profile",),
                    backgroundColor: provider1.ThemeLabel!.headerColor,),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                color: provider1.ThemeLabel!.shelfColor,
                child: ListTile(
                  leading: Text('Theme'),
                  trailing: CustomDropdown<Genres>.multiSelect( // get rid of scroll menu
                    items: Genres.Genre, 
                    initialItems: Genres.Genre.take(1).toList(),
                    onListChanged: (value) {
                      log('changing value to: $value');
                    },
                    )
                  // trailing: DropdownButton<Genres>(
                  //   value: provider2.genre,
                  //   hint: const Text('Choose'),
                  //   items: Genres.Genre.map((Genres entry) {
                  //     return DropdownMenuItem<Genres>(
                  //       value: entry,
                  //       child: Text(entry.genres),
                  //     );
                  //   }).toList(),
                  //   onChanged: (Genres? newGenre) {
                  //     final genreChooser = context.read<ProfileModel>();
                  //     genreChooser.changeGenre(newGenre);
                  //   },
                  // )
                )
                )
            ],
          )
        )
      )
    ),
    );
  }
}

enum Genres {
    
    sports(
      genres: 'Sports',
    ),

    academics(
      genres: 'Academics',
    ),

    satire(
      genres: 'Satire',
    ),

    profiles(
      genres: 'Profiles',
    ),

    politics(
      genres: "Politics",
    );

    const Genres ({
      required this.genres
    });

    final String genres;

    static List<Genres> get Genre => values.map<Genres>((String) => String).toList();
}