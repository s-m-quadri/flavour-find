import 'package:dart_casing/dart_casing.dart';
import 'package:flutter/material.dart';
import 'package:myapp/data/model.dart';
import 'package:myapp/data/structure.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RecipeDetails extends StatefulWidget {
  const RecipeDetails({
    super.key,
    required this.recipe,
    required this.dataModel,
  });

  final Recipe recipe;
  final DataModel dataModel;

  @override
  State<RecipeDetails> createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {
  @override
  Widget build(BuildContext context) {
    final YoutubePlayerController controller = YoutubePlayerController(
        initialVideoId:
            YoutubePlayer.convertUrlToId(widget.recipe.youtubeURL) ?? "");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Details"),
      ),
      body: ListView(
        children: [
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
            padding: const EdgeInsets.only(top: 20),
            child: ListTile(
              title: Center(
                child: ChoiceChip(
                  label: const Text("Mark Favorite"),
                  selected: widget.dataModel.likedIds
                      .contains(widget.recipe.id.toString()),
                  showCheckmark: false,
                  avatar: const Icon(Icons.favorite_outline),
                  onSelected: (value) {
                    value
                        ? widget.dataModel
                            .addLikedId(widget.recipe.id.toString())
                        : widget.dataModel
                            .removeLikedId(widget.recipe.id.toString());
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
            child: ListTile(
              title: Center(
                child: Text(
                  Casing.titleCase(
                      "${widget.recipe.category} | ${widget.recipe.tag}"),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          YoutubePlayer(
            controller: controller,
            aspectRatio: 16 / 9,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: ListTile(
              title: Center(
                child: Text(
                  Casing.titleCase("Ingredients"),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          ...List.generate(
            widget.recipe.ingredient.length,
            (index) {
              String ingItem = widget.recipe.ingredient.keys.toList()[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.check_outlined),
                  title: Text(Casing.titleCase(ingItem)),
                  trailing: Text(
                      Casing.titleCase(widget.recipe.ingredient[ingItem]!)),
                ),
              );
            },
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
        ],
      ),
    );
  }
}
