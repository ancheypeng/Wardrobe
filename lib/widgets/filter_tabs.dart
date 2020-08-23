import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';

class FilterTabs extends StatefulWidget {
  final TabController tabController;
  final List listToFilter;
  final List<String> tabNames;
  final void Function(List<List<int>> filteredList) updateParent;
  final void Function() reloadParent;
  FilterTabs({
    Key key,
    this.tabController,
    this.listToFilter,
    this.tabNames,
    this.updateParent,
    this.reloadParent,
  }) : super(key: key);

  @override
  _FilterTabsState createState() => _FilterTabsState();
}

class _FilterTabsState extends State<FilterTabs> with TickerProviderStateMixin {
  //List _listToFilter;
  List<String> _tabNames;
  //var _numTabs;
  TabController _tabController;
  //List<List<int>> _filteredList;
  //void Function(List<List<int>> filteredList) _updateParent;
  //void Function() _reloadParent;

  @override
  void initState() {
    super.initState();
    //_listToFilter = widget.listToFilter;
    _tabNames = widget.tabNames;
    //_numTabs = _tabNames.length;
    _tabController = widget.tabController;
    //_updateParent = widget.updateParent;
    //_reloadParent = widget.reloadParent;

    // _tabController.addListener(() {
    //   if (_tabController.indexIsChanging) {
    //     _updateParent(_filterList());
    //     //_reloadParent();
    //   }
    // });
  }

  // List<List<int>> _filterList() {
  //   List<int> tempList = [];
  //   _filteredList = List.filled(_numTabs, []);
  //   _filteredList[0] = List.generate(_listToFilter.length, (index) => index);
  //   for (int i = 1; i < _numTabs; i++) {
  //     tempList = [];
  //     for (int j = 0; j < _listToFilter.length; j++) {
  //       if (_listToFilter[j].contains(_tabNames[i])) {
  //         tempList.add(j);
  //         _filteredList[i] = tempList;
  //       }
  //     }
  //   }
  //   return _filteredList;
  // }

  List<Widget> _buildTabs() {
    return _tabNames
        .map(
          (name) => Text(
            name,
            maxLines: 1,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Builder(
          builder: (context) {
            //_updateParent(_filterList());
            return TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: new BubbleTabIndicator(
                indicatorHeight: 18.0,
                indicatorColor: Colors.blueAccent,
                tabBarIndicatorSize: TabBarIndicatorSize.tab,
              ),
              tabs: _buildTabs(),
              controller: _tabController,
            );
          },
        ),
      ),
    );
  }
}
