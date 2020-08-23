// import 'package:flutter/material.dart';
// import 'package:wardrobe/database/db_helper.dart';
// import 'package:wardrobe/models/item_model.dart';
// import 'package:wardrobe/widgets/bottom_bar.dart';
// import 'package:wardrobe/widgets/filter_tabs.dart';
// import 'package:wardrobe/widgets/item_card.dart';
// import 'package:wardrobe/widgets/search_bar.dart';
// import 'dart:convert';
// import 'image_capture_screen2.dart';

// class ItemScreen extends StatefulWidget {
//   ItemScreen({Key key}) : super(key: key);

//   @override
//   _ItemScreenState createState() => _ItemScreenState();
// }

// class _ItemScreenState extends State<ItemScreen> with TickerProviderStateMixin {
//   final ItemDbHelper _itemDbHelper = ItemDbHelper();
//   List<Item> _items;
//   List<Image> _itemImages;

//   final TextEditingController _searchController = TextEditingController();
//   List<int> _searchItems;

//   final List<String> _filterTabNames = [
//     'All',
//     'Tops',
//     'Bottoms',
//     'Accessories'
//   ];
//   int _numFilterTabs;
//   List<List<int>> _filterItems;
//   TabController _tabController;

//   List<List<int>> _searchFilterItems;

//   @override
//   initState() {
//     super.initState();

//     _items = [];
//     _searchItems = [];
//     _numFilterTabs = _filterTabNames.length;
//     _filterItems = [];
//     _searchFilterItems = List.filled(_numFilterTabs, []);
//     _tabController = TabController(length: _numFilterTabs, vsync: this);

//     refreshItems();
//     print('Img Screen Initialized');
//   }

//   @override
//   void dispose() {
//     print('Img Screen disposing');
//     _itemDbHelper.close();
//     _searchController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   void refreshItems() {
//     _itemDbHelper.getItems().then((items) {
//       setState(() {
//         _items.clear();
//         _items.addAll(items);

//         _searchItems = List.generate(_items.length, (index) => index);
//         _searchFilterItems[0] = List.generate(_items.length, (index) => index);
//         _updateItemImages();
//       });
//     });
//   }

//   void _updateItemImages() {
//     _itemImages = _items.map((item) {
//       return Image.memory(
//         base64Decode(item.image),
//         fit: BoxFit.cover,
//         gaplessPlayback: true,
//       );
//     }).toList();
//   }

//   void _updateSearchItems(List<int> searchedList) {
//     _searchItems = searchedList;
//     _combineSearchFilterItems();
//     setState(() {});
//   }

//   void _updateFilterItems(List<List<int>> filteredList) {
//     _filterItems = filteredList;
//     _combineSearchFilterItems();
//   }

//   void _combineSearchFilterItems() {
//     List<int> tempList = [];
//     _searchFilterItems = List.filled(_numFilterTabs, []);

//     for (int i = 0; i < _numFilterTabs; i++) {
//       tempList = [];
//       for (int j = 0; j < _items.length; j++) {
//         if (_filterItems[i].contains(j) && _searchItems.contains(j)) {
//           tempList.add(j);
//           _searchFilterItems[i] = tempList;
//         }
//       }
//     }
//   }

//   void _reload() {
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Items'),
//       ),
//       body: Container(
//         color: Colors.grey[200],
//         child: Column(
//           children: <Widget>[
//             SearchBar(
//               searchController: _searchController,
//               listToSearch: _items,
//               updateParent: _updateSearchItems,
//             ),
//             FilterTabs(
//               tabController: _tabController,
//               listToFilter: _items,
//               tabNames: _filterTabNames,
//               updateParent: _updateFilterItems,
//               reloadParent: _reload,
//             ),
//             Flexible(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: List.generate(
//                   _numFilterTabs,
//                   (index) => _buildGridView(index),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ImageCapture2(
//               itemDbHelper: _itemDbHelper,
//             ),
//           ),
//         ).then((_) {
//           _searchController.clear();
//           refreshItems();
//         }),
//         child: Icon(Icons.add),
//       ),
//       //extendBody: true,
//       floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
//       bottomNavigationBar: BottomBar(),
//     );
//   }

//   GridView _buildGridView(int index) {
//     return GridView.builder(
//       padding: EdgeInsets.symmetric(horizontal: 10.0),
//       itemCount: _searchFilterItems[index].length,
//       itemBuilder: (BuildContext context, int index2) {
//         return ItemCard(
//           itemImage: _itemImages[_searchFilterItems[index][index2]],
//         );
//       },
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         childAspectRatio: 8.0 / 10.0,
//       ),
//     );
//   }
// }
