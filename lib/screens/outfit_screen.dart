import 'package:flutter/material.dart';
import 'package:wardrobe/models/item_model.dart';
import 'package:wardrobe/models/outfit_model.dart';
import 'package:wardrobe/widgets/filter_tabs.dart';
import 'package:wardrobe/widgets/outfit_card.dart';
import 'package:wardrobe/widgets/search_bar.dart';

class OutfitScreen extends StatefulWidget {
  final List<Item> items;
  final List<Outfit> outfits;

  final void Function(Outfit, List<Item>) onOutfitCardTap;

  OutfitScreen({Key key, this.items, this.outfits, this.onOutfitCardTap})
      : super(key: key);

  @override
  _OutfitScreenState createState() => _OutfitScreenState();
}

class _OutfitScreenState extends State<OutfitScreen>
    with TickerProviderStateMixin {
  List<Item> _items;
  List<Outfit> _outfits;

  final TextEditingController _searchController = TextEditingController();
  List<int> _searchItems;

  final List<String> _filterTabNames = [
    'All',
    'Athletic',
    'Casual',
    'Formal',
    'Other'
  ];
  int _numFilterTabs;
  List<List<int>> _filterItems;
  TabController _tabController;

  List<List<int>> _searchFilterItems;

  void Function(Outfit, List<Item>) _onOutfitCardTap;

  @override
  void initState() {
    super.initState();
    _items = widget.items ?? [];
    _outfits = widget.outfits ?? [];
    _searchItems = [];
    _numFilterTabs = _filterTabNames.length;
    _filterItems = List.filled(_numFilterTabs, []);
    _searchFilterItems = List.filled(_numFilterTabs, []);
    _tabController = TabController(length: _numFilterTabs, vsync: this);

    _onOutfitCardTap = widget.onOutfitCardTap ?? (_, __) {};
  }

  @override
  void dispose() {
    //_itemDbHelper.close();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateSearchItems(List<int> searchedList) {
    _searchItems = searchedList;
    _combineSearchFilterItems();
    _reload();
  }

  // void _updateFilterItems(List<List<int>> filteredList) {
  //   _filterItems = filteredList;
  //   _combineSearchFilterItems();
  // }

  void _combineSearchFilterItems() {
    List<int> tempList = [];
    _searchFilterItems = List.filled(_numFilterTabs, []);

    for (int i = 0; i < _numFilterTabs; i++) {
      tempList = [];
      for (int j = 0; j < _outfits.length; j++) {
        if (_filterItems[i].contains(j) && _searchItems.contains(j)) {
          tempList.add(j);
          _searchFilterItems[i] = tempList;
        }
      }
    }
  }

  void _reload() {
    setState(() {});
  }

  void updateLists() {
    // initializes filterItems, searchItems, and searchFilterItems to have all items
    // also, rebuilds the lists if a new item is added (2nd part of OR statement)

    if (_filterItems[0].isEmpty || _filterItems[0].length != _outfits.length) {
      List<int> tempList = [];
      _filterItems = List.filled(_numFilterTabs, []);
      _filterItems[0] = List.generate(_outfits.length, (index) => index);
      for (int i = 1; i < _numFilterTabs; i++) {
        tempList = [];
        for (int j = 0; j < _outfits.length; j++) {
          if (_outfits[j].contains(_filterTabNames[i])) {
            tempList.add(j);
            _filterItems[i] = tempList;
          }
        }
      }

      _searchItems = List.generate(_outfits.length, (index) => index);
      _combineSearchFilterItems();
      //_searchFilterItems[0] = List.generate(_outfits.length, (index) => index);
    }
  }

  GridView _buildGridView(int index) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        //childAspectRatio: 8.0 / 10.0,
        //childAspectRatio: 1.0,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      //itemCount: _searchFilterItems[index].length,
      itemCount: _searchFilterItems[index].length,
      itemBuilder: (BuildContext context, int index2) {
        //Item item = _items[_searchFilterItems[index][index2]];
        Outfit outfit = _outfits[_searchFilterItems[index][index2]];

        List<Item> itemsInOutfit = outfit.itemsInOutfit
            .map((itemId) => _items.where((Item item) {
                  return item.id == itemId;
                }).first)
            .toList();
        return Stack(
          children: [
            OutfitCard(
              itemsInOutfit: itemsInOutfit,
              outfit: outfit,
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: EdgeInsets.all(4.0), //same as ItemCard/OutfitCard
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                        12.0), //same as ItemCard/OutfitCard
                    onTap: () => _onOutfitCardTap(outfit, itemsInOutfit),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    updateLists();

    return Column(
      children: <Widget>[
        SearchBar(
          searchController: _searchController,
          listToSearch: _outfits,
          updateParent: _updateSearchItems,
        ),
        FilterTabs(
          tabController: _tabController,
          //listToFilter: _outfits,
          tabNames: _filterTabNames,
          //updateParent: _updateFilterItems,
          //reloadParent: _reload,
        ),
        Flexible(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(
              _numFilterTabs,
              (index) => _buildGridView(index),
            ),
          ),
        ),
      ],
    );
  }
}
