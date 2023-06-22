import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trial_fyp_mobile/size_config.dart';
import 'package:trial_fyp_mobile/utility/constants.dart';
import 'package:trial_fyp_mobile/widgets/generated_meal.dart';

import '../../models/authentication/meal/listOfMeal.dart';
import '../../models/authentication/meal/meal.dart';
import '../../services/authenticationServices/authenticationServices.dart';
import '../../services/mealservices/mealServices.dart';
import '../../utility/utility.dart';
import '../MealPlan/meal.dart';

class SearchResultsScreen extends StatefulWidget {
  late List<Meal> listOfSearchedMeals;
  late String searchString;

  SearchResultsScreen(
      {super.key,
      required this.listOfSearchedMeals,
      required this.searchString});

  @override
  State<SearchResultsScreen> createState() =>
      _SearchResultsScreenState(listOfSearchedMeals, searchString);
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late List<Meal> listOfSearchedMeals;
  late String searchString;
  late bool isLoading;
  final searchController = TextEditingController();

  _SearchResultsScreenState(this.listOfSearchedMeals, this.searchString);

  @override
  void initState() {
    searchController.text = searchString;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              child: Padding(
        padding: EdgeInsets.fromLTRB(getProportionateScreenWidth(20), 0,
            getProportionateScreenWidth(20), 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: getProportionateScreenHeight(10)),
            const Center(
              child: Text(
                'FOODIFIED',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(40)),
            TextFormField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchString = value;
                });
              },
              onFieldSubmitted: (value) async {
                if (await hasInternetConnection()) {
                  var apiResponse =
                      await getSearchedMeals(searchController.text);
                  if (apiResponse!.message == failure) {
                    setState(() {
                      isLoading = false;
                    });
                    showErrorSnackBar(apiResponse.error!.message, context);
                  } else {
                    setState(() {
                      listOfSearchedMeals =
                          mealsFromJson(json.encode(apiResponse.data));
                    });
                  }
                } else {
                  setState(() {
                    isLoading = false;
                  });
                  showErrorSnackBar(
                      "Failed to connect, Check your internet connection",
                      context);
                }
              },
              decoration: InputDecoration(
                  hintText: "Search for a Meal",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () async {
                      if (await hasInternetConnection()) {
                        var apiResponse =
                            await getSearchedMeals(searchController.text);
                        if (apiResponse!.message == failure) {
                          setState(() {
                            isLoading = false;
                          });
                          showErrorSnackBar(
                              apiResponse.error!.message, context);
                        } else {
                          setState(() {
                            listOfSearchedMeals =
                                mealsFromJson(json.encode(apiResponse.data));
                          });
                        }
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        showErrorSnackBar(
                            "Failed to connect, Check your internet connection",
                            context);
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
            SizedBox(height: getProportionateScreenHeight(20)),
            Container(
              height: getProportionateScreenHeight(700),
              //padding: const EdgeInsets.only(bottom: 10),
              child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  itemCount: listOfSearchedMeals.length,
                  separatorBuilder: (context, _) => SizedBox(
                        width: getProportionateScreenWidth(30),
                        child: const Divider(
                          color: Color(kGreenColor),
                          height: 30,
                          thickness: 1,
                        ),
                      ),
                  itemBuilder: (context, index) => GeneratedMeal(
                        meal: listOfSearchedMeals[index],
                        onPressed: () =>
                            moveToMealScreen(listOfSearchedMeals[index]),
                      )),
            ),
          ],
        ),
      ))),
    );
  }

  dynamic moveToMealScreen(Meal meal) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MealScreen(
              meal: meal,
            )));
  }
}
