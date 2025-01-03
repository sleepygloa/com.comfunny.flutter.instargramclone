import 'package:flutter/material.dart';
import 'package:flutter_clone_instagram/src/components/image_data.dart';
import 'package:flutter_clone_instagram/src/pages/instargram/controller/bottom_nav_controller.dart';
import 'package:flutter_clone_instagram/src/pages/instargram/active_history.dart';
import 'package:flutter_clone_instagram/src/pages/instargram/home.dart';
import 'package:flutter_clone_instagram/src/pages/instargram/mypage.dart';
import 'package:flutter_clone_instagram/src/pages/instargram/search.dart';
import 'package:get/get.dart';

class AppInstargram extends StatefulWidget {
  const AppInstargram({super.key});

  @override
  State<AppInstargram> createState() => _AppInstargramState();
}

class _AppInstargramState extends State<AppInstargram> {
  final BottomNavController controller = Get.put(BottomNavController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.willPopAction,
      child: Obx(
          () => Scaffold(
          // backgroundColor: Colors.red,
          body: IndexedStack(
            index: controller.pageIndex.value,
            children: [
              const Home(),
              Navigator(
                key: controller.searchPageNavigationKey,
                onGenerateRoute: (settings){
                  return MaterialPageRoute(builder: (context)=> const Search());
                },
              ),
              // const Search(),
              Container(),
              const ActiveHistory(),
              const MyPage()
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed, //아이콘의 크기가 고정된다.
            showSelectedLabels: false, //선택된 아이콘의 라벨을 보여줄지 여부
            showUnselectedLabels: false, //선택되지 않은 아이콘의 라벨을 보여줄지 여부
            currentIndex: controller.pageIndex.value, //선택된 아이콘의 인덱스
            elevation: 0, //바텀 네비게이션바의 그림자
            onTap: controller.changeBottomNav, //아이콘을 선택했을 때 호출되는 콜백함수
            items: [
              BottomNavigationBarItem(
                icon: ImageData(IconPath.homeOff),
                activeIcon: ImageData(IconPath.homeOn),
                label: 'home',
              ),
              BottomNavigationBarItem(
                icon: ImageData(IconPath.searchOff),
                activeIcon: ImageData(IconPath.searchOn),
                label: 'search',
              ),
              BottomNavigationBarItem(
                icon: ImageData(IconPath.uploadIcon),
                label: 'upload',
              ),
              BottomNavigationBarItem(
                icon: ImageData(IconPath.activeOff),
                activeIcon: ImageData(IconPath.activeOn),
                label: 'active',
              ),
              BottomNavigationBarItem(
                icon: ImageData(IconPath.menuIconProfileOff),
                label: 'mypage',
                activeIcon: ImageData(IconPath.menuIconProfileOn),
              ),
            ],
          ),
        ), 
      )
      
    );
  }


}