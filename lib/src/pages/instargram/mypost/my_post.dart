import 'package:flutter/material.dart';
import 'package:flutter_clone_instagram/src/components/avatar_widget.dart';
import 'package:flutter_clone_instagram/src/components/image_data.dart';
import 'package:flutter_clone_instagram/src/controller/api_service.dart';
import 'package:flutter_clone_instagram/src/pages/instargram/mypost/my_post_widget.dart';
import 'package:flutter_clone_instagram/src/pages/instargram/controller/inatargram_data_controller.dart';
import 'package:flutter_clone_instagram/src/pages/instargram/controller/inatargram_login_controller.dart';
import 'package:get/get.dart';

class MyPost extends StatefulWidget{
  const MyPost({super.key});

  @override
  State<MyPost> createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  int currentPage = 0; // 현재 페이지를 추적하기 위한 변수
  //로그인 컨트롤러
  final InstargramLoginController loginController = Get.find<InstargramLoginController>();
  final InstargramDataController dataController = Get.find<InstargramDataController>();

  @override
  void initState() {
    super.initState();
    loginController.checkLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loginController.checkLoginStatus(); // 화면 진입 시 로그인 상태 확인
  }

  //포스트 리스트
  Widget _postList(){
    // return Container();
    return Obx(()=>Column(
      children: List.generate(dataController.myPostList.length, (index) => MyPostWidget(post: dataController.myPostList[index], index: 2)).toList(),
    ));
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Column(
          children: [
            Text(
              dataController.myProfile.value.userName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '게시물',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: (){},
            child: Padding(padding: const EdgeInsets.all(15.0),
            child: ImageData(IconPath.menuIcon, width: 50,),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 데이터 재조회
          await dataController.getBasicData(context);
        },
        child: ListView(
          children: [
            _postList(),
          ],
        ),
      ),
    );
  }
} 