import 'package:dart_casing/dart_casing.dart';
import 'package:flutter/material.dart';
import 'package:myapp/data/structure.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RecipeDetails extends StatefulWidget {
  const RecipeDetails({
    super.key,
    required this.recipe,
  });

  final Recipe recipe;

  @override
  State<RecipeDetails> createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {

      

  @override
  Widget build(BuildContext context) {
    final YoutubePlayerController controller =
      YoutubePlayerController(initialVideoId: YoutubePlayer.convertUrlToId(widget.recipe.youtubeURL) ?? "");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Details"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.recipe.thumbURL,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: ListTile(
              title: Center(
                child: Text(
                  Casing.titleCase(widget.recipe.name),
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: ListTile(
              title: Center(
                child: Text(
                  Casing.titleCase("How to Make?"),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: ListTile(
              title: Center(
                child: Text(
                  widget.recipe.instructions,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          YoutubePlayer(
            controller: controller,
            aspectRatio: 16 / 9,
          ),
        ],
      ),
    );
  }
}
