import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/model.dart';
import 'recipe.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.title,
    required this.dataModel,
  });

  final String title;
  final DataModel dataModel;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController searchController = TextEditingController();
  String categoryFilterSelected = "All";
  List<String> categoryFilter = ["All"];
  List<String> ingredientsFilter = [];
  bool activateLoader = false;

  void handleRemoveIngredient(String item) {
    ingredientsFilter.remove(item);
    setState(() {});
  }

  void handleAddIngredient(String item) {
    if (!ingredientsFilter.contains(item)) ingredientsFilter.add(item);
    setState(() {});
  }

  void loadEssentials() async {
    try {
      setState(() {
        activateLoader = true;
      });
      await widget.dataModel.fetchIngredients();
      await widget.dataModel.fetchCategories();
      categoryFilter = [
        "Favorite",
        "All",
        ...widget.dataModel.categories.reversed
      ];
      categoryFilter.remove("Beef");
      categoryFilter.remove("Pork");
      await widget.dataModel.fetchRecipes();
      await widget.dataModel.loadLikedIds();
      updateStatus("Success");
    } catch (e) {
      updateStatus(e.toString());
    }
    setState(() {
      activateLoader = false;
    });
  }

  void updateStatus(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void handleFilterSelect(int index) {
    categoryFilterSelected = categoryFilter[index];
    switch (categoryFilter[index]) {
      case "All":
        break;
      default:
    }
    setState(() {});
  }

  @override
  void initState() {
    loadEssentials();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.soup_kitchen_outlined,
            color: Colors.green, size: 32),
        title: Text(widget.title),
        actions: [
          ActionChip(
            label: const Text("Refresh"),
            avatar: const Icon(Icons.refresh_outlined),
            onPressed: () => loadEssentials(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Autocomplete<String>(
              onSelected: (String item) {
                handleAddIngredient(item);
                searchController.clear();
              },
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return widget.dataModel.ingredients
                    .where((element) => element.name
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()))
                    .map((e) => e.name)
                    .toList();
              },
              fieldViewBuilder: searchTextFieldBuilder,
            ),
          ),
          AddedIngredient(
            ingredients: ingredientsFilter,
            handleRemove: handleRemoveIngredient,
          ),
          CategoryFilters(
            filter: categoryFilter,
            filterSelected: categoryFilterSelected,
            handleFilterSelect: handleFilterSelect,
          ),
          Expanded(
            child: activateLoader
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: widget.dataModel.recipes.length,
                    itemBuilder: (context, index) {
                      bool categoryCondition = true;
                      switch (categoryFilterSelected) {
                        case "All":
                          categoryCondition = true;
                          break;
                        case "Favorite":
                          categoryCondition = widget.dataModel.likedIds.contains(
                              widget.dataModel.recipes[index].id.toString());
                          break;
                        default:
                          categoryCondition = categoryFilterSelected.contains(
                              widget.dataModel.recipes[index].category);
                          break;
                      }
                      bool ingredientCondition = ingredientsFilter.every(
                          (key) => widget.dataModel.recipes[index].ingredient
                              .containsKey(key));
                      bool show = categoryCondition && ingredientCondition;

                      return Offstage(
                        key: ValueKey(widget.dataModel.recipes[index].id),
                        offstage: !show,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetails(
                                  recipe: widget.dataModel.recipes[index],
                                  dataModel: widget.dataModel,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    widget.dataModel.recipes[index].thumbURL,
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                        widget.dataModel.recipes[index].name),
                                    subtitle: Text(
                                        "A type of ${widget.dataModel.recipes[index].category}, having ingredients: ${widget.dataModel.recipes[index].ingredientStrList()}."),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios_outlined),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget searchTextFieldBuilder(
      context, textEditingController, focusNode, onFieldSubmitted) {
    searchController = textEditingController;
    return TextField(
      autofocus: true,
      controller: textEditingController,
      focusNode: focusNode,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9-_ ]')),
      ],
      onSubmitted: (value) => onFieldSubmitted(),
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: const Icon(Icons.close_outlined),
          onPressed: () {
            setState(() {
              textEditingController.clear();
            });
          },
        ),
        isDense: true,
        border: const OutlineInputBorder(),
        label: const Text("Search"),
        hintText: "Enter ingredient name to search",
      ),
    );
  }
}

class AddedIngredient extends StatelessWidget {
  const AddedIngredient({
    super.key,
    required this.ingredients,
    required this.handleRemove,
  });

  final List<String> ingredients;
  final Function handleRemove;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: ingredients.isEmpty,
      child: Padding(
        padding: const EdgeInsets.only(right: 15, left: 15, bottom: 5),
        child: SizedBox(
          height: 35,
          child: Row(
            children: [
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    return ChoiceChip(
                      selected: true,
                      showCheckmark: false,
                      label: Text(ingredients[index]),
                      onSelected: (_) => handleRemove(ingredients[index]),
                      avatar: const Icon(Icons.close_outlined),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryFilters extends StatelessWidget {
  const CategoryFilters({
    super.key,
    required this.filter,
    required this.filterSelected,
    required this.handleFilterSelect,
  });

  final List<String> filter;
  final String filterSelected;
  final Function handleFilterSelect;

  Widget? getFilterIcon(String filter) {
    switch (filter) {
      case "Favorite":
        return const Icon(Icons.favorite_outline);
      case "All":
        return const Icon(Icons.apps_outlined);
      case "Vegetarian":
        return const Icon(Icons.eco);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15, left: 10, bottom: 5),
      child: SizedBox(
        height: 35,
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 3),
              child: Chip(
                avatar: Icon(Icons.filter_alt_outlined),
                label: Text("Filters:"),
                shape: LinearBorder.none,
              ),
            ),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filter.length,
                itemBuilder: (context, index) {
                  return ChoiceChip(
                    avatar: getFilterIcon(filter[index]),
                    label: Text(filter[index]),
                    selected: filterSelected.contains(filter[index]),
                    onSelected: (value) => handleFilterSelect(index),
                    showCheckmark: false,
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
