import 'dart:io';

import 'package:cropsight/controller/db_controller.dart';
import 'package:cropsight/views/descript/mandesc.dart';
import 'package:cropsight/views/pages/settings.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({
    super.key,
    required this.imageSc,
    required this.output,
    required this.location,
  });
  final File? imageSc;
  final List? output;
  final String? location;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  //loadimage
  String? saveImgFile;
  Future<String?> saveImageWithUniqueName(File? imageSc) async {
    if (imageSc == null) {
      debugPrint("No image file to save.");
      return null; // Changed from 'pathError' to null for clarity
    }

    try {
      // Generate a unique UUID-based image name
      final uuid = Uuid();
      String uniqueFileName = '${uuid.v4()}.png';

      // Get the application's document directory
      final appDocDir = await getApplicationDocumentsDirectory();
      String newImagePath = path.join(appDocDir.path, uniqueFileName);

      // Save (copy) the image with the new unique name
      File savedImage = await imageSc.copy(newImagePath);

      // Retrieve existing image paths list from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      List<String> savedPaths = prefs.getStringList('saved_image_paths') ?? [];

      // Add the new image path to the list
      savedPaths.add(savedImage.path);
      await prefs.setStringList('saved_image_paths', savedPaths);

      setState(() {
        _savedData(int.parse(idNum), savedImage.path);
      });

      debugPrint("Image saved at: ${savedImage.path}");
      return savedImage.path;
    } catch (e) {
      debugPrint("Error saving image: $e");
      return null; // Changed from 'pathErro' to null
    }
  }

  void someMethod() async {
    if (widget.imageSc != null) {
      String? savedPath = await saveImageWithUniqueName(widget.imageSc);
      if (savedPath != null) {
        setState(() {
          saveImgFile = savedPath;
        });
      }
    } else {
      debugPrint('unknown cannot added');
    }
  }

  String getConfidencePercentage(dynamic output) {
    try {
      // Ensure output is not null and has at least one element
      if (output != null && output.isNotEmpty) {
        // Clamp the confidence between 0 and 1 to prevent unexpected values
        double confidence = (output[0]['confidence'] as double).clamp(0.0, 1.0);

        // Multiply by 100 and format to two decimal places
        return (confidence * 100).toStringAsFixed(2);
      }
      return 'N/A';
    } catch (e) {
      debugPrint('Error calculating confidence: $e');
      return 'Error';
    }
  }

  String imgInsectPath = 'assets/images/question-mark-909830_640.png';
  String insectName = 'Unknown';
  String insectDesc = 'This image is unknown';
  String idNum = '0';
  String percent = '0';
  bool isUnknown = true;

  final LanguagePreference _languagePreference = LanguagePreference();

  @override
  void initState() {
    super.initState();
    conditionStatus();
    isUnknown ? someMethod() : debugPrint('this image is unknown');
    debugPrint('path load to: ${widget.imageSc}');
  }

  void conditionStatus() {
    setState(() {
      percent = getConfidencePercentage(widget.output);
    });
    //
    if (_languagePreference.languageCode == 'en') {
      if (widget.output![0]['label'].toString() == "Tungro") {
        setState(() {
          imgInsectPath = 'assets/images/greenleafhopper/1s.jpg';
          insectName = 'Green Leafhopper';
          insectDesc =
              'Adults and nymphs cause direct damage to the rice plant by sucking the sap from leaf sheaths and leaf blades. GLH also cause indirect damage by injecting toxic chemicals and transmitting viruses (tungro, dwarf, transitory yellowing, and yellow- orange leaf) and a mycoplasma disease (yellow dwarf). They mostly confine themselves and feed on the leaf and leaf sheath of rice. Mild infestations reduce plant vigor and number of productive tillers. Heavy infestations cause withering and complete drying of the crop.';
          idNum = '1';
        });
      } else if (widget.output![0]['label'].toString() == "Rice Bugs") {
        setState(() {
          imgInsectPath = 'assets/images/ricebug/factsheet-ricebug-2.jpg';
          insectName = 'Rice Bugs';
          insectDesc =
              'Rice bugs damage rice by sucking out the contents of developing grains from pre-flowering spikelets to soft dough stage, therefore causing unfilled or empty grains and discoloration. Immature and adult rice bugs both feed on rice grains.';
          idNum = '3';
        });
      } else if (widget.output![0]['label'].toString() == "Rice Dead Heart") {
        setState(() {
          imgInsectPath = 'assets/images/stemborer/2s.jpg';
          insectName = 'Stem Borer';
          insectDesc =
              'Rice stem borers (RSB) can be present in all rice growing areas. During tillering, the typical damage symptom is deadheart, while in flowering stage, it causes whitehead. The larvae also produce tiny holes on the stem and deposit faces within it, which is seen when the stem is cut open.';
          idNum = '4';
        });
      } else if (widget.output![0]['label'].toString() == "Healthy") {
        imgInsectPath = 'assets/images/11_organicrice.jpg';
        insectName = 'No Insect';
        insectDesc = 'This is healthy rice';
        idNum = '0';
        setState(() {
          isUnknown = false;
        });
      } else if (widget.output![0]['label'].toString() == "Leaf Folder") {
        imgInsectPath =
            'assets/images/riceleaffolder/factsheet-leaffolder-1.jpg';
        insectName = 'Rice Leaffolder';
        insectDesc =
            'Leaffolder caterpillars fold a rice leaf around themselves and attach the leaf margins together with silk strands. They feed inside the folded leaf creating longitudinal white and transparent streaks on the blade.';
        idNum = '2';
      } else {
        insectName = 'Unknown';
        insectDesc = 'This image capture is invalid';
        setState(() {
          isUnknown = false;
        });
      }
    } else {
      //ceb
      if (widget.output![0]['label'].toString() == "Tungro") {
        setState(() {
          imgInsectPath = 'assets/images/greenleafhopper/1s.jpg';
          insectName = 'Green Leafhopper';
          insectDesc =
              'Ang mga hamtong ug mga nimpa makadaot direkta sa tanom nga humay pinaagi sa pagsuyup sa dagta gikan sa mga uwang sa dahon ug mga sulab sa dahon. Ang GLH usab makapahinungdan og dili direkta nga kadaot pinaagi sa pagpaila og makahilo nga mga kemikal ug pagpasa sa mga virus (tungro, dwarf, transitory yellowing, ug yellow-orange leaf) ug usa ka sakit nga mycoplasma (yellow dwarf). Kasagaran, nagpabilin sila ug mikaon sa dahon ug uwang sa dahon sa humay. Ang hinay nga pagpanghitabo makapaminus sa kusog sa tanom ug sa gidaghanon sa mamungang tukog. Ang grabe nga pagpanghitabo makapahinungdan sa pagkalaya ug hingpit nga pagkalaya sa tanom.';
          idNum = '1';
        });
      } else if (widget.output![0]['label'].toString() == "Rice Bugs") {
        setState(() {
          imgInsectPath = 'assets/images/ricebug/factsheet-ricebug-2.jpg';
          insectName = 'Rice Bugs';
          insectDesc =
              'Ang mga ulod sa humay makadaot sa tanom pinaagi sa pagsuyup sa sulod sa nagapadayon nga pagtubo sa mga lugas, sukad sa wala pa mamulak nga mga spikelet hangtod sa yugto nga mura’g malumo nga masa. Tungod niini, mobalik sa pagkawalay sulod o mahimong bus-ok ang mga lugas ug mahimong madanihon. Ang mga bata pa ug hamtong nga ulod sa humay pareho nga mikaon sa mga lugas sa humay.';
          idNum = '3';
        });
      } else if (widget.output![0]['label'].toString() == "Rice Dead Heart") {
        setState(() {
          imgInsectPath = 'assets/images/stemborer/2s.jpg';
          insectName = 'Stem Borer';
          insectDesc =
              'Ang mga ulod sa tangbo sa humay (Rice Stem Borer) makita sa tanang dapit nga nagtanom og humay. Atol sa yugto sa pagtubo sa tukog, ang kasagarang timailhan sa kadaot mao ang "deadheart," samtang sa yugto sa pagpamulak, kini makapahinungdan og "whitehead." Ang mga ulod usab moporma og gagmay nga lungag sa tangbo ug magbilin og hugaw sulod niini, nga makita kung putlon ang tangbo.';
          idNum = '4';
        });
      } else if (widget.output![0]['label'].toString() == "Healthy") {
        imgInsectPath = 'assets/images/11_organicrice.jpg';
        insectName = 'No Insect';
        insectDesc = 'kini maayo nga humay';
        idNum = '0';
        setState(() {
          isUnknown = false;
        });
      } else if (widget.output![0]['label'].toString() == "Leaf Folder") {
        imgInsectPath =
            'assets/images/riceleaffolder/factsheet-leaffolder-1.jpg';
        insectName = 'Rice Leaffolder';
        insectDesc =
            'Ang mga ulod sa leaffolder mopilo sa dahon sa humay palibot sa ilang kaugalingon ug ipapilit ang mga kilid sa dahon gamit ang mga pisi sa lana. Mikaon sila sulod sa gipilo nga dahon, nga moporma og taas nga puti ug transparent nga mga guhit sa dahon.';
        idNum = '2';
      } else {
        insectName = 'Unknown';
        insectDesc = 'Kini nga larawan dili makita';
        setState(() {
          isUnknown = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: true,
      //   title: const Text('Results'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          widget.imageSc!,
                          height: 290.h,
                          width: 390.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                      IconButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.green),
                        ),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  spacing: 2,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // based on chatgpt level confidence color
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: double.parse(percent) >= 76.00
                            ? Color.fromARGB(35, 76, 175, 79) // green
                            : double.parse(percent) >= 51.00
                                ? Color.fromARGB(35, 255, 153, 0) //orange
                                : double.parse(percent) >= 26.00
                                    ? Color.fromARGB(35, 255, 0, 0)
                                    : Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Confidence: $percent %',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: double.parse(percent) >= 76.00
                              ? Colors.green
                              : double.parse(percent) >= 51.00
                                  ? Colors.orange
                                  : double.parse(percent) >= 26.00
                                      ? Colors.red
                                      : Colors.red,
                        ),
                      ),
                    ),
                    Text(
                      "Result: ${widget.output![0]['label']}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FluentIcons.location_16_filled,
                          size: 20.sp,
                        ),
                        Text(
                          'Barangay ${widget.location.toString()}, Panabo City',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              imgInsectPath,
                              width: 95.w,
                              height: 95.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            insectName,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 400.w,
                        child: Text(
                          textAlign: TextAlign.justify,
                          insectDesc,
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      idNum == '0'
                          ? const Text('')
                          : Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ManageDesc(
                                        id: idNum,
                                      ),
                                    ),
                                  );
                                },
                                style: const ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll(Colors.green)),
                                child: const Text(
                                  'Solution',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  //add
  void addScanData({
    required int insectId,
    required String insectName,
    required String insectDamage,
    required String insectPic,
    required String insectPercent,
    required String location,
    required String month,
    required String year,
  }) async {
    final dbHelper = CropSightDatabase(); // Create instance of database class

    Map<String, dynamic> newRow = {
      'insectId': insectId,
      'insectName': insectName,
      'insectDamage': insectDamage,
      'insectPic': insectPic,
      'insectPercent': insectPercent,
      'location': location,
      'month': month,
      'year': year,
    };

    int id = await dbHelper.insertScanningHistory(newRow);
    debugPrint('Inserted row id: $id');

    // Trigger sync after inserting new data
    await SyncService().syncData();
  }

  //save all data
  void _savedData(int idNum, saveImgFile) {
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;
    String currntMnt =
        DateFormat.MMMM().format(DateTime(currentYear, currentMonth));
    String crntYr =
        (int.parse(DateFormat('y').format(DateTime.now()))).toString();

    try {
      addScanData(
        insectId: idNum,
        insectName: insectName,
        insectDamage: widget.output![0]['label'].toString(),
        insectPercent: percent,
        insectPic: saveImgFile,
        location: widget.location.toString(),
        month: currntMnt,
        year: crntYr,
      );
    } catch (e) {
      debugPrint('error: $e');
    }
  }
}
