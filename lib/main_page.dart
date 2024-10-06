import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  File? imageFile;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select & Crop Image'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 25),
            imageFile == null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(150),
                    child: Image.asset(
                      'lib/assets/images/profile.png',
                      height: 300.0,
                      width: 300.0,
                      fit: BoxFit.cover,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(150),
                    child: Image.file(
                      imageFile!,
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                Map<Permission, PermissionStatus> status = await [
                  Permission.storage,
                  Permission.camera,
                ].request();

                if (status[Permission.storage]?.isGranted == true &&
                    status[Permission.camera]?.isGranted == true) {
                  showImagePicker;
                } else {
                  print('Permissions not granted');
                }
              },
              child: const Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }

  void showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Card(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5.2,
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    child: const Column(
                      children: [
                        Icon(Icons.image, size: 60),
                        SizedBox(height: 12),
                        Text('Gallery', textAlign: TextAlign.center),
                      ],
                    ),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: const Column(
                      children: [
                        Icon(Icons.camera, size: 60),
                        SizedBox(height: 12),
                        Text('Camera', textAlign: TextAlign.center),
                      ],
                    ),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _imgFromCamera() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      _cropImage(File(pickedFile.path));
    }
  }

  void _imgFromGallery() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      _cropImage(File(pickedFile.path));
    }
  }

  Future<void> _cropImage(File imgFile) async {
    // Crop the image
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imgFile.path,
    );

    // Check if the cropped file is not null
    if (croppedFile != null) {
      imageCache.clear(); // Clear the image cache
      setState(() {
        imageFile = File(croppedFile.path); // Update the image file
      });
    }
  }
}
