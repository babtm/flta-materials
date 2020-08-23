/*
 * Copyright (c) 2020 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../recipe_card.dart';
import 'recipe_details.dart';

class RecipeList extends StatefulWidget {
  @override
  _RecipeListState createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  static const String prefIndex = "previousSearches";

  TextEditingController searchTextController;
  ScrollController _scrollController = ScrollController();
  List currentSearchList = List();
  int currentCount = 0;
  int currentStartPosition = 0;
  int currentEndPosition = 20;
  int pageCount = 20;
  bool hasMore = false;
  bool loading = false;
  bool inErrorState = false;
  List<String> previousSearches = List<String>();
  String currentSearch;

  @override
  void initState() {
    super.initState();
    searchTextController = TextEditingController(text: "");
    _scrollController
      ..addListener(() {
        var triggerFetchMoreSize =
            0.7 * _scrollController.position.maxScrollExtent;

        if (_scrollController.position.pixels > triggerFetchMoreSize) {
          if (hasMore &&
              currentEndPosition < currentCount &&
              !loading &&
              !inErrorState) {
            setState(() {
              loading = true;
              currentStartPosition = currentEndPosition;
              currentEndPosition =
                  min(currentStartPosition + pageCount, currentCount);
            });
          }
        }
      });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }


  void savePreviousSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(prefIndex, previousSearches);
  }

  void getPreviousSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(prefIndex)) {
      previousSearches = prefs.getStringList(prefIndex);
      if (previousSearches == null) {
        previousSearches = List<String>();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Search Card
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          _buildSearchCard(),
          _buildRecipeLoader(context),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                String newValue = searchTextController.text;
                setState(() {
                  currentSearchList.clear();
                  currentCount = 0;
                  currentEndPosition = pageCount;
                  currentStartPosition = 0;
                  if (!previousSearches.contains(newValue)) {
                    previousSearches.add(newValue);
                    savePreviousSearches();
                  }
                });
              },
            ),
            SizedBox(
              width: 6.0,
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                        controller: searchTextController,
                        onChanged: (value) {
                          print("Text Field $value");
                        },
                      )),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: (String value) {
                      searchTextController.text = value;
                    },
                    itemBuilder: (BuildContext context) {
                      return previousSearches
                          .map<PopupMenuItem<String>>((String value) {
                        return PopupMenuItem(
                            child: Text(value), value: value);
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeLoader(BuildContext context) {
    if (searchTextController.text.length < 3) {
      return Container();
    }
    // Show a loading indicator while waiting for the movies
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildRecipeCard(BuildContext topLevelContext, List hits,
      int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return RecipeDetails();
          },
        ));
      },
      child: recipeStringCard("", ""),
    );
  }
}
