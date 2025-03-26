import 'dart:io';
import 'dart:typed_data';
import 'package:cropsight/views/navigation/notifier/change_notifier.dart';
import 'package:cropsight/views/pages/scanning.dart';
import 'package:cropsight/views/pages/settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
// import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math' as math;

import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:tensorflow_lite_flutter/tensorflow_lite_flutter.dart';
// import 'package:tensorflow_lite_flutter/tensorflow_lite_flutter.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  void updateLocation(String? newLocation) {
    setState(() {
      selectedValue = newLocation;
    });
  }

  final LanguagePreference _languagePreference = LanguagePreference();

  final picker = ImagePicker();
  File? _image;
  String? selectedValue;

  // List of locations
  final List<String> locations = [
    'Southern',
    'Datu Abdul',
    'Quezon',
    'Nanyo',
  ];

  // Method to save the selected value to SharedPreferences
  _saveValue(String? value) async {
    if (value != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedDropdownValue', value);
      debugPrint("Saved value: $value");
    }
  }

  // Method to load the saved value from SharedPreferences
  _loadSavedValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('selectedDropdownValue')) {
      setState(() {
        selectedValue = prefs.getString('selectedDropdownValue');
      });
      debugPrint("Loaded value: $selectedValue"); // Debug log
    } else {
      debugPrint("No value found in SharedPreferences");
      _showLocationModal();
    }
  }

  // Function to show the modal
  void _showLocationModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final locationProvider =
            Provider.of<LocationProvider>(context, listen: false);
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Your Barangay in Panabo City',
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return ListTile(
                    title: Text(
                      location,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    trailing: selectedValue == location
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        selectedValue = location; // Update selected value
                      });
                      locationProvider.updateLocation(location);
                      _saveValue(location);
                      _loadSavedValue();
                      Navigator.pop(context); // Close the modal
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Interpreter? _interpreter;

  // Revised loadML function
  Future<void> loadML() async {
    try {
      final options = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = true;

      _interpreter = await Interpreter.fromAsset(
        'assets/MobileNetV2(InsectRice(2)).tflite',
        options: options,
      );

      debugPrint('Model loaded successfully');
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  // Revised runModelOnImage function
  Future<void> runModelOnImage(File? image) async {
    if (image == null || _interpreter == null) {
      debugPrint('Image or interpreter is null');
      return;
    }

    try {
      // Load and process the image
      final imageBytes = await image.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        debugPrint('Failed to decode image');
        return;
      }

      // Resize image to 224x224
      final resizedImage = img.copyResize(
        originalImage,
        width: 224,
        height: 224,
        interpolation: img.Interpolation.linear,
      );

      // Prepare input data - normalize to [0, 1]
      final inputBuffer = Float32List(1 * 224 * 224 * 3);
      var pixelIndex = 0;

      for (var y = 0; y < resizedImage.height; y++) {
        for (var x = 0; x < resizedImage.width; x++) {
          final pixel = resizedImage.getPixel(x, y);

          // Normalize RGB values to [0, 1]
          inputBuffer[pixelIndex] = pixel.r.toDouble() / 255.0;
          inputBuffer[pixelIndex + 1] = pixel.g.toDouble() / 255.0;
          inputBuffer[pixelIndex + 2] = pixel.b.toDouble() / 255.0;

          pixelIndex += 3;
        }
      }

      // Reshape input to match model's expected shape [1, 224, 224, 3]
      final input = inputBuffer.reshape([1, 224, 224, 3]);

      // Get model output shape from interpreter
      var outputShape = _interpreter!.getOutputTensor(0).shape;
      debugPrint('Model output shape: $outputShape');

      // Create output buffer with correct shape
      final outputBuffer =
          List<double>.filled(outputShape[0] * outputShape[1], 0)
              .reshape(outputShape);

      // Run inference
      _interpreter!.run(input, outputBuffer);

      // Convert output to probabilities using softmax
      final probabilities = _softmax(outputBuffer[0], temperature: 0.25);

      debugPrint('Probabilities: $probabilities');

      int maxIndex = 0;
      double maxProb = probabilities[0];
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      // Map the index to label
      final labels = [
        "Healthy",
        "Leaf Folder",
        "Rice Bugs",
        "Rice Dead Heart",
        "Tungro",
        "Unknown",
      ]; // Adjust based on your labels
      String predictedLabel = labels[maxIndex];

      // Apply confidence threshold
      if (maxProb < 0.5) {
        debugPrint('Low confidence prediction. Label: Unknown');
        predictedLabel = 'Unknown';
      } else {
        predictedLabel = labels[maxIndex];
      }
      // Format output to match ScanPage expectations
      final output = [
        {
          'label': predictedLabel,
          'confidence': maxProb,
        }
      ];

      debugPrint(
          'Prediction: $predictedLabel with confidence: ${(maxProb * 100).toStringAsFixed(2)}%');

      // Navigate to results page
      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanPage(
              imageSc: image,
              output: output,
              location: selectedValue,
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error running model: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing image: $e')),
        );
      }
    }
  }

  // Helper function to compute softmax probabilities
  List<double> _softmax(List<double> inputs, {double temperature = 1.0}) {
    double max = inputs.reduce(math.max);
    List<double> exp =
        inputs.map((x) => math.exp((x - max) / temperature)).toList();
    double sum = exp.reduce((a, b) => a + b);
    return exp.map((x) => x / sum).toList();
  }

  // Future<void> _cropImage(File imageFile) async {
  //   CroppedFile? croppedFile = await ImageCropper().cropImage(
  //     sourcePath: imageFile.path,
  //     uiSettings: [
  //       AndroidUiSettings(
  //         toolbarTitle: 'Crop Image',
  //         toolbarColor: Colors.green,
  //         activeControlsWidgetColor: Colors.green,
  //         toolbarWidgetColor: Colors.white,
  //         initAspectRatio: CropAspectRatioPreset.original,
  //         lockAspectRatio: false,
  //         aspectRatioPresets: [
  //           CropAspectRatioPreset.square,
  //           CropAspectRatioPreset.ratio3x2,
  //           CropAspectRatioPreset.original,
  //           CropAspectRatioPreset.ratio4x3,
  //           CropAspectRatioPreset.ratio16x9
  //         ],
  //       ),
  //       IOSUiSettings(
  //         title: 'Crop Image',
  //       ),
  //     ],
  //   );

  //   if (croppedFile != null) {
  //     setState(() {
  //       _image = File(croppedFile.path);
  //     });

  //     // Run TFLite model on the cropped image
  //     if (mounted) {
  //       showBottomModal(context);
  //     }
  //     Future.delayed(const Duration(seconds: 3), () async {
  //       await runModelOnImage(_image);
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _loadSavedValue();
    loadML();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locationProvider = Provider.of<LocationProvider>(context);
    if (locationProvider.selectedLocation != selectedValue) {
      updateLocation(locationProvider.selectedLocation);
    }
  }

  @override
  void dispose() {
    _interpreter?.close(); // Clean up interpreter
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Text(
            _languagePreference.languageCode == 'en'
                ? 'Welcome'
                : 'Maayong pag-abot',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          Card(
            shadowColor: Colors.grey,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : const Color.fromARGB(255, 26, 26, 26),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _languagePreference.languageCode == 'en'
                        ? 'What is Cropsight?'
                        : 'Unsa nang Cropsight?',
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        FluentIcons.phone_checkmark_20_regular,
                        color: Color.fromRGBO(86, 144, 51, 1),
                        size: 38.sp,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          _languagePreference.languageCode == 'en'
                              ? 'Turn your mobile phone into a rice crop pest identifier.'
                              : 'Himua ang imong mobile phone nga usa ka tigpaila sa mga peste sa tanom nga humay.',
                          style: TextStyle(
                            overflow: TextOverflow.clip,
                            fontSize: 12.sp,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        FluentIcons.image_search_24_regular,
                        color: Color.fromRGBO(86, 144, 51, 1),
                        size: 38.sp,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          _languagePreference.languageCode == 'en'
                              ? 'With just one photo, CropSight diagnoses damage to rice crops and offers management options for any pest damage.'
                              : 'Pinaagi lang sa usa ka litrato, ang CropSight mopahibalo sa kadaot sa tanom nga humay ug maghatag og mga kapilian sa pagdumala sa kadaot nga hinungdan sa mga peste.',
                          style: TextStyle(
                            overflow: TextOverflow.clip,
                            fontSize: 12.sp,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        FluentIcons.book_search_24_regular,
                        color: Color.fromRGBO(86, 144, 51, 1),
                        size: 38.sp,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          _languagePreference.languageCode == 'en'
                              ? 'CropSight will give you a rice pest list page with information about different pest in rice crops'
                              : 'Ang CropSight maghatag kanimo og usa ka panid nga naglista sa mga peste sa humay, uban ang impormasyon kabahin sa lain-laing klase sa peste sa tanom nga humay.',
                          style: TextStyle(
                            overflow: TextOverflow.clip,
                            fontSize: 12.sp,
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
            height: 10,
          ),
          Text(
            'Scan Rice Pest Damage',
            style: TextStyle(
              fontSize: 20.sp,
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
                      color: const Color.fromARGB(50, 76, 175, 79),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(23),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Icon(
                              FluentIcons.camera_add_24_filled,
                              color: Colors.green,
                              size: 40.sp,
                            )),
                        Text(
                          'Camera',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20.sp,
                              color: Colors.green),
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
                      color: const Color.fromARGB(50, 33, 149, 243),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(23),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Icon(
                            FluentIcons.image_add_24_filled,
                            color: Colors.blue,
                            size: 40.sp,
                          ),
                        ),
                        Text(
                          'Upload',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20.sp,
                            color: Colors.blue,
                          ),
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
          compressionQuality: 100,
        );

        if (result != null && result.files.single.path != null) {
          setState(() {
            _image?.deleteSync(); // Delete the previous image file if it exists
            _image = File(result.files.single.path!);
          });
          var im = _image = File(result.files.single.path!);
          // Run TFLite model on the cropped image
          if (mounted) {
            showBottomModal(context);
          }
          Future.delayed(const Duration(seconds: 3), () async {
            await runModelOnImage(im);
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No image selected')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to pick image: $e')),
          );
        }
      }
    } else {
      // Handle the case when permission is denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied')),
        );
      }
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
    try {
      PermissionStatus cameraStatus = await Permission.camera.status;

      // Request camera permission if not granted
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }

      // For Android 13+, request media permission for photos only if needed
      if (Platform.isAndroid &&
          // ignore: unnecessary_null_comparison
          Platform.version.split('.')[0] != null &&
          int.parse(Platform.version.split('.')[0]) >= 33) {
        PermissionStatus mediaStatus = await Permission.photos.status;
        if (!mediaStatus.isGranted) {
          mediaStatus = await Permission.photos.request();
        }

        // Handle denial for Android 13+
        if (mediaStatus.isPermanentlyDenied) {
          return _showPermissionDialog(context);
        }

        if (!mediaStatus.isGranted) {
          _showSnackbar(
              context, 'Photo access permission is required for Android 13+');

          return;
        }
      }

      // Handle permanently denied permissions
      if (cameraStatus.isPermanentlyDenied) {
        return _showPermissionDialog(context);
      }

      // Check if camera permission is still denied
      if (!cameraStatus.isGranted) {
        _showSnackbar(context, 'Camera permission is required');
        return;
      }

      // Pick image from camera/gallery
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        setState(() {
          _image?.deleteSync(recursive: true);
          _image = File(pickedFile.path);
        });

        // Run TFLite model on the cropped image
        if (mounted) {
          showBottomModal(context);
        }
        Future.delayed(const Duration(seconds: 3), () async {
          await runModelOnImage(_image);
        });
      } else {
        _showSnackbar(context, 'No image selected');
      }
    } catch (e) {
      _showErrorDialog(context);
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Camera and storage permissions are required. Please grant permissions in app settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'An error occurred while picking the image. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
