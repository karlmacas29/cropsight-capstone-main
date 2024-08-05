import 'dart:io';
import 'package:cropsight/views/navigation/scanning.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_v2/tflite_v2.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final picker = ImagePicker();
  File? _image;

  @override
  void initState() {
    super.initState();
    Tflite.close();
    loadML().then((value) {
      setState(() {
        print('Model has been loaded!');
      });
    });
  }

  //function Future
  Future<void> loadML() async {
    try {
      await Tflite.loadModel(
        model: "assets/mobilenet.tflite", // trained model
        labels: "assets/labels.txt", // class label by order
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false, // defaults to false, set to true to use GPU delegate
      );
    } on Exception catch (e) {
      print('Error loading model: ${e.toString()}');
    }
  }

  //run tflite
  Future<void> runModelOnImage(File? image) async {
    try {
      var img = image;
      var output = await Tflite.runModelOnImage(
        path: img!.path,
        numResults: 3,
        threshold: 0.0,
        imageMean: 0.0,
        imageStd: 1.0,
        asynch: true,
      );

      print(output);
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ScanPage(imageSc: img, output: output);
      }));
    } on Exception catch (e) {
      print('Code error: $e');
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 10),
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          const Text(
            'Welcome',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(
            height: 20,
          ),
          Card(
            shadowColor: Colors.grey,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : const Color.fromARGB(255, 26, 26, 26),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('What is Cropsight?',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt_rounded,
                        color: Color.fromRGBO(2, 101, 0, 1),
                        size: 38,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          'Turn your mobile phone into a crop insect identifier.',
                          style: TextStyle(
                            overflow: TextOverflow.clip,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt_rounded,
                        color: Color.fromRGBO(2, 101, 0, 1),
                        size: 38,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          'With just one photo, CropSight diagnoses infected crops and offers management options for any insect damage.',
                          style: TextStyle(
                            overflow: TextOverflow.clip,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt_rounded,
                        color: Color.fromRGBO(2, 101, 0, 1),
                        size: 38,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          'CropSight will give you an insect wikipedia page with information about different crop insects.',
                          style: TextStyle(
                            overflow: TextOverflow.clip,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Features',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                onTap: () {
                  getImage(context, ImageSource.camera);
                },
                child: Ink(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            blurStyle: BlurStyle.outer,
                            spreadRadius: 0.1,
                            blurRadius: 0.4,
                            offset: Offset.fromDirection(1))
                      ],
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : const Color.fromARGB(255, 26, 26, 26),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(23),
                            decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: const Icon(
                              Icons.camera_rounded,
                              color: Colors.white,
                            )),
                        const Text(
                          'Scan',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                onTap: () {
                  pickImage();
                },
                child: Ink(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            blurStyle: BlurStyle.outer,
                            spreadRadius: 0.1,
                            blurRadius: 0.4,
                            offset: Offset.fromDirection(1))
                      ],
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : const Color.fromARGB(255, 26, 26, 26),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(23),
                            decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: const Icon(Icons.photo_library_rounded,
                                color: Colors.white)),
                        const Text(
                          'Photos',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> pickImage() async {
    final permissionStatus = await _getPermissionStatus();
    if (permissionStatus == PermissionStatus.granted) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );

        if (result != null && result.files.single.path != null) {
          setState(() {
            _image?.deleteSync(); // Delete the previous image file if it exists
            _image = File(result.files.single.path!);
          });
          var im = _image = File(result.files.single.path!);
          showBottomModal(context);
          Future.delayed(const Duration(seconds: 3), () {
            runModelOnImage(im);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    } else {
      // Handle the case when permission is denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied')),
      );
    }
  }

  Future<PermissionStatus> _getPermissionStatus() async {
    if (await Permission.storage.request().isGranted) {
      return PermissionStatus.granted;
    } else {
      // For Android 14+, handle the new permissions
      if (await Permission.photos.request().isGranted) {
        return PermissionStatus.granted;
      } else if (await Permission.mediaLibrary.request().isGranted) {
        return PermissionStatus.granted;
      }
    }
    return PermissionStatus.denied;
  }

  Future<void> getImage(BuildContext context, ImageSource source) async {
    final cameraStatus = await Permission.camera.status;
    final photosStatus = await Permission.photos.status;

    if (cameraStatus.isDenied || photosStatus.isDenied) {
      final requestCamera = await Permission.camera.request().isGranted;
      final requestPhotos = await Permission.photos.request().isGranted;

      if (!requestCamera || !requestPhotos) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied')),
        );
        return;
      }
    }

    if (cameraStatus.isPermanentlyDenied || photosStatus.isPermanentlyDenied) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Permission Error'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'This app needs camera and photo access to function properly. Please grant the permissions in the settings.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () async {
                  await openAppSettings();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (await Permission.camera.isGranted &&
        await Permission.photos.isGranted) {
      try {
        final pickedFile = await ImagePicker().getImage(source: source);

        if (pickedFile != null) {
          setState(() {
            _image?.deleteSync(); // Delete the previous image file if it exists
            _image = File(pickedFile.path);
          });
          var im = _image = File(pickedFile.path);
          showBottomModal(context);
          Future.delayed(const Duration(seconds: 3), () {
            runModelOnImage(im);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected')),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'An error occurred while picking the image. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  //modal loading cool
  showBottomModal(context) {
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return Container(
            height: 200,
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : const Color.fromARGB(255, 26, 26, 26),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0, // has the effect of softening the shadow
                    spreadRadius: 0.0, // has the effect of extending the shadow
                  )
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(top: 5, left: 10),
                        child: const Text(
                          "Scanning Please Wait",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        CircularProgressIndicator(
                          color: Colors.green,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
