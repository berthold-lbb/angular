import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:mime/mime.dart';

class HomePocWidget extends StatefulWidget {
  const HomePocWidget({Key? key}) : super(key: key);

  @override
  State<HomePocWidget> createState() => _UploadFileWidgetState();
}

class _UploadFileWidgetState extends State<HomePocWidget> {
  FilePickerResult? _filePickerResult;
  double progress = 0.0;


  void onUploadFile() async {
    if (_filePickerResult != null) {
      final result = _filePickerResult!;
      Uint8List fileBytes = result.files.first.bytes!;
      String fileName = result.files.first.name;

      String mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

      // Upload file
      // UploadTask task = FirebaseStorage.instance
      //     .ref()
      //     .child("files/$fileName")
      //     .putData(file!);

      // first way to do

      // final downloadUrl = await (await FirebaseStorage.instance
      //     .ref('uploads/$fileName')
      //     .putData(fileBytes, SettableMetadata(contentType: mimeType),)).ref.getDownloadURL();

      // other way to do

      UploadTask task = FirebaseStorage.instance
          .ref("uploads/$fileName")
          .putData(fileBytes, SettableMetadata(contentType: mimeType));

      task.snapshotEvents.listen((event) {
        setState(() {
          progress = ((event.bytesTransferred.toDouble() /
              event.totalBytes.toDouble()) *
              100)
              .roundToDouble();

          if (progress == 100) {
            event.ref
                .getDownloadURL()
                .then((downloadUrl) => print(downloadUrl));
          }

          print(progress);
        });
      });

    }


  }

  void onPickFile() async {
    FilePickerResult? localUploadResult;
    if (kIsWeb) {
      localUploadResult = await FilePicker.platform.pickFiles();
    } else {
      localUploadResult = await FilePicker.platform.pickFiles();
    }
    if (localUploadResult != null) {
      setState(() {
        _filePickerResult = localUploadResult;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              onPickFile();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blueGrey),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        // const Icon(
                        //   Icons.attach_file_rounded,
                        // ),
                        const SizedBox(width: 10),
                        Text(
                          'Add Text',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ],
                    ),
                  ),
                  // SHOW FILE NAME
                ],
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 50.0,
        ),

        // UPLOAD BUTTON
        TextButton(
          onPressed: () {
            onUploadFile();
          },
          child: Text(
            'load',
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),

        const SizedBox(
          height: 50.0,
        ),
        Container(
          height: 200.0,
          width: 200,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 375),
            child: progress == 100.0
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  'Up Complete',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 15.0
                  ),
                ),
              ],
            )
                : LiquidCircularProgressIndicator(
              value: progress / 100,
              valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
              backgroundColor: Colors.white,
              direction: Axis.vertical,
              center: Text(
                "$progress%",
                style: const TextStyle(
                    color: Colors.black87, fontSize: 22.0),
              ),
            ),
          ),
        )
      ],
    );
  }
}