import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final TextEditingController searchController;
  final List listToSearch;
  final void Function(List<int> searchedList) updateParent;

  SearchBar({
    Key key,
    @required this.searchController,
    @required this.listToSearch,
    @required this.updateParent,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  List _listToSearch;
  TextEditingController _searchController;
  String _searchText;
  List<int> _searchedList;
  void Function(List<int> searchList) _updateParent;

  @override
  void initState() {
    super.initState();
    _listToSearch = widget.listToSearch;
    _searchController = widget.searchController;
    _searchText = '';
    _searchedList = [];
    _updateParent = widget.updateParent;

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
        _updateParent(_searchList());
      });
    });
  }

  List<int> _searchList() {
    if (_searchText == '') {
      _searchedList = List.generate(_listToSearch.length, (index) => index);
    } else {
      _searchedList = [];
      for (int i = 0; i < _listToSearch.length; i++) {
        if (_listToSearch[i].contains(_searchText)) {
          _searchedList.add(i);
        }
      }
    }
    return _searchedList;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28.0, 20.0, 28.0, 10.0),
      child: Material(
        borderRadius: BorderRadius.circular(50.0),
        elevation: 2.0,
              child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            fillColor: Colors.white,
            contentPadding: EdgeInsets.all(0.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
            ),
            suffixIcon: Builder(
              builder: (BuildContext context) {
                if (_searchText != '') {
                  return IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                    onPressed: () => _searchController.clear(),
                  );
                }
                return SizedBox.shrink();
              },
            ),
            hintText: 'Search',
          ),
          cursorColor: Colors.grey,
        ),
      ),
    );
  }
}
