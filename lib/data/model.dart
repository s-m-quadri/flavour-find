import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myapp/data/structure.dart';

class DataModel {
  String baseUrl = "https://www.themealdb.com/api/json/v1/1";
  final client = http.Client();
  List<Ingredient> ingredients = [];
  List<String> categories = [];
  List<Recipe> recipes = [];

  Future<void> fetchIngredients() async {
    try {
      final response = await client.get(Uri.parse("$baseUrl/list.php?i=list"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ingredients.clear();
        ingredients = (data["meals"] as List)
            .map<Ingredient>((item) => Ingredient(
                  id: int.parse(item["idIngredient"]),
                  name: item["strIngredient"] ?? "Something",
                  details: item["strDescription"] ?? "No details available",
                ))
            .toList();
        return;
      } else {
        throw Exception('Failed to load ingredients');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await client.get(Uri.parse("$baseUrl/list.php?c=list"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        categories.clear();
        categories = (data["meals"] as List)
            .map<String>((item) => item["strCategory"])
            .toList();
        return;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> fetchRecipes() async {
    recipes.clear();
    try {
      for (String letter in [
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
        'i',
        'j',
        'k',
        'l',
        'm',
        'n',
        'o',
        'p',
        'q',
        'r',
        's',
        't',
        'u',
        'v',
        'w',
        'x',
        'y',
        'z'
      ]) {
        final response =
            await client.get(Uri.parse("$baseUrl/search.php?f=$letter"));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data["meals"] == null) continue;
          recipes.addAll((data["meals"] as List).map<Recipe>((item) {
            Map<String, String> itoMeasure = {};
            for (var i = 1; i <= 20; i++) {
              if (item["strMeasure$i"] != null &&
                  item["strMeasure$i"] != "" &&
                  item["strIngredient$i"] != null &&
                  item["strIngredient$i"] != "") {
                itoMeasure[item["strIngredient$i"]] = item["strMeasure$i"];
              }
            }
            Recipe newRecipe = Recipe(
              id: int.parse(item["idMeal"]),
              name: item["strMeal"] ?? "Untitled",
              category: item["strCategory"] ?? "No Category",
              tag: item["strTags"] ?? "No Tag",
              instructions:
                  item["strInstructions"] ?? "No Instructions Available!",
              thumbURL: item["strMealThumb"] ?? "",
              youtubeURL: item["strYoutube"] ?? "",
              ingredient: itoMeasure,
            );
            newRecipe.name = newRecipe.name.toUpperCase();
            
            return newRecipe;
          }).toList());
        } else {
          throw Exception('Failed to load recipes');
        }
      }
      return;
    } catch (error) {
      throw Exception(error);
    }
  }
}
