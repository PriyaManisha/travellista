import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travellista/router/app_router.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  const NavBar({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(homeRoute);
        break;
      case 1:
        context.go(createRoute);
        break;
      case 2:
        context.go(mapRoute);
        break;
      case 3:
        context.go(profileRoute);
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      //unselectedItemColor: Theme.of(context).colorScheme.primary,
      items: [
        BottomNavigationBarItem(
          icon: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(
                color: Colors.black54,
                blurRadius:4,
                offset: Offset(4,4)
              )]
            ),
            child: const SizedBox(
              height:50,
              width:50,
              child:Column(
                children:[
                  Icon(Icons.home),
                  Text("Home")
                ]
              )
            )
          ),
          label: ' ',
        ),
        BottomNavigationBarItem(
          icon: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [ BoxShadow(
                color: Colors.black54,
                blurRadius:4,
                offset: Offset(2,4)
              )]
            ),
            child:const SizedBox(
              height:50,
              width:50,
              child:Column(
                children:[
                  Icon(Icons.add),
                  Text("Add")
                ]
              )
            )
          ),
          label: ' ',
        ),
        BottomNavigationBarItem(
          icon: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(
                color: Colors.black54,
                blurRadius:4,
                offset: Offset(-2,4)
              )]
            ),
            child:const SizedBox(
              height:50,
              width:50,
              child:Column(
                children:[
                  Icon(Icons.map),
                  Text("Map")
                ]
              )
            )
          ),
          label: ' ',
        ),
        BottomNavigationBarItem(
          icon: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(
                color: Colors.black54,
                blurRadius:4,
                offset: Offset(-4,4)
              )]
            ),
            child:const SizedBox(
              height:50,
              width:50,
              child: Column(
                children:[
                  Icon(Icons.person),
                  Text("Profile")
                ]
              )
            )
          ),
          label: ' ',
        ),
      ],
    );
  }
}
