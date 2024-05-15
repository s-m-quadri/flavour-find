class Ingredient {
  Ingredient({
    required this.id,
    required this.name,
    required this.details,
  });

  int id;
  String name;
  String details;
}

class Recipe{
  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.tag,
    required this.instructions,
    required this.thumbURL,
    required this.youtubeURL,
    required this.ingredient,
  });

  int id;
  String name;
  String category;
  String tag;
  String instructions;
  String thumbURL;
  String youtubeURL;
  Map<String, String> ingredient;

  String ingredientStrList(){
    String ingStr = ingredient.keys.first;
    for (var ingItem in ingredient.keys) {
      ingStr += ", $ingItem";
    }
    return ingStr;
  }
}