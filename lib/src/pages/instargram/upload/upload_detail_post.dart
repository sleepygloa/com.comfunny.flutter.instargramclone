import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_clone_instagram/src/pages/instargram/controller/upload_controller.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_clone_instagram/src/controller/api_service.dart';
import 'package:image/image.dart' as img;


class UploadDetailPost extends StatefulWidget {
  final List<AssetEntity>? selectedImages; // 여러 이미지를 받을 수 있도록 변경

  const UploadDetailPost({super.key, this.selectedImages});

  @override
  State<UploadDetailPost> createState() => _UploadDetailPostState();
}

class _UploadDetailPostState extends State<UploadDetailPost> {
  final UploadController controller = Get.put(UploadController());
  // List<AssetEntity>? get selectedImages => widget.selectedImages; // 여러 이미지를 참조
  final TextEditingController _contentController = TextEditingController();
  String? _taggedPeoples;
  String? _music;
  String? _shareTarget;
  String? _location;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // 이미지 미리보기 위젯 (여러 이미지 지원)
  Widget _imagePreview() {
    return Obx(() {
      return SizedBox(
        height: MediaQuery.of(context).size.width,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.filteredImages!.length,
          itemBuilder: (context, index) {
            return Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.grey,
              child: _photoWidget(
                controller.filteredImages![index],
                MediaQuery.of(context).size.width.toInt(),
                builder: (data) {
                  return Image.memory(
                    data,
                    fit: BoxFit.cover,
                  );
                },
              ),
            );
          },
        ),
      );
    });
  }

  Widget _photoWidget(AssetEntity asset, int size, {required Widget Function(Uint8List) builder}) {
    return FutureBuilder(
      future: asset.thumbnailDataWithSize(ThumbnailSize(size, size)),
      builder: (_, AsyncSnapshot<Uint8List?> snapshot) {
        if (snapshot.hasData) {
          return builder(snapshot.data!);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // 이벤트 그룹 위젯 (기존과 동일)
  Widget _eventGroup() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 내용 입력 필드
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: '문구를 작성하거나 설문을 추가하세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: null,
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.grey),
          // 나머지 이벤트 필드
          _buildRow(Icons.person_add, '사람 태그', () => setState(() => _taggedPeoples = 'Tagged People')),
          _buildRow(Icons.music_note, '음악 추가', () => setState(() => _music = 'Selected Music')),
          _buildRow(Icons.share_rounded, '공개 대상', () => setState(() => _shareTarget = 'Selected Audience')),
          _buildRow(Icons.location_pin, '위치 추가', () => setState(() => _location = 'Selected Location')),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _savePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '공유',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 공통 행 빌더
  Widget _buildRow(IconData icon, String title, VoidCallback onTap) {
    return Row(
      children: [
        IconButton(icon: Icon(icon), onPressed: onTap),
        Text(title),
        const Spacer(),
        const Icon(Icons.chevron_right),
      ],
    );
  }

  // 게시물 저장
  Future<void> _savePost() async {
    final content = _contentController.text;

    // 최대 크기 (예: 10MB = 10 * 1024 * 1024 bytes)
    const int maxSizeInBytes = 10 * 1024 * 1024;

    // 이미지를 압축하여 ByteData로 변환
    List<Uint8List> compressedImageDataList = [];
    for (var asset in controller.selectedImages ?? []) {
      final data = await asset.originBytes; // 원본 이미지 데이터
      if (data != null) {
        try {
          final compressedData = await compressImage(data, maxSizeInBytes);
          compressedImageDataList.add(compressedData);
        } catch (e) {
          print("이미지 압축 실패: $e");
        }
      }
    }

    // API 요청
    var result = await ApiService.sendApiFile(context, '/api/instargram/post/savePost', {
      'images': compressedImageDataList, // 압축된 이미지 전달
      'content': content,
      'taggedPeople': _taggedPeoples,
      'music': _music,
      'audience': _shareTarget,
      'location': _location,
    });

    if (result == null) {
      print('게시물 저장 실패');
      return;
    }
    print('게시물 저장 성공: $result');
  }

  //이미지 압축
  Future<Uint8List> compressImage(Uint8List data, int maxSizeInBytes) async {
  // 이미지 디코딩
  img.Image? originalImage = img.decodeImage(data);
  if (originalImage == null) {
    throw Exception("이미지를 디코딩할 수 없습니다.");
  }

  int quality = 100; // 초기 품질
  Uint8List compressedImage = Uint8List.fromList(img.encodeJpg(originalImage, quality: quality));

  // 품질을 줄여가며 용량이 maxSizeInBytes 이하가 될 때까지 반복
  while (compressedImage.lengthInBytes > maxSizeInBytes && quality > 10) {
    quality -= 10; // 품질을 10씩 줄임
    compressedImage = Uint8List.fromList(img.encodeJpg(originalImage, quality: quality));
  }

  return compressedImage;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시물 업로드')),
      body: Column(
        children: [
          _imagePreview(),
          const SizedBox(height: 8),
          Expanded(child: _eventGroup()),
        ],
      ),
    );
  }
}