import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onBottomBarTap;
  const BottomBar({Key key, this.selectedIndex, this.onBottomBarTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BubbleBottomBar(
      opacity: .2,
      currentIndex: selectedIndex ?? 0,
      onTap: onBottomBarTap ?? (index) {},
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      elevation: 8,
      fabLocation: BubbleBottomBarFabLocation.end,
      //hasNotch: true,
      hasInk: true,
      inkColor: Colors.black12,
      items: <BubbleBottomBarItem>[
        BubbleBottomBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(
              Icons.local_offer,
              color: Colors.grey[800],
            ),
            activeIcon: Icon(
              Icons.local_offer,
              color: Colors.blue,
            ),
            title: Text("Items")),
        BubbleBottomBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(
              Icons.collections,
              color: Colors.grey[800],
            ),
            activeIcon: Icon(
              Icons.collections,
              color: Colors.blue,
            ),
            title: Text("Outfits")),
        BubbleBottomBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(
              Icons.insert_chart,
              color: Colors.grey[800],
            ),
            activeIcon: Icon(
              Icons.insert_chart,
              color: Colors.blue,
            ),
            title: Text("Insights")),
      ],
    );

    // return BottomNavigationBar(items: const <BottomNavigationBarItem>[
    //   BottomNavigationBarItem(
    //     icon: Icon(Icons.home),
    //     title: Text('Home'),
    //   ),
    //   BottomNavigationBarItem(
    //     icon: Icon(Icons.folder),
    //     title: Text('Folder'),
    //   ),
    // ]);
  }
}
