import 'dart:io';

import 'package:cropsight/controller/db_controller.dart';
import 'package:cropsight/views/descript/mandesc.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
      print("No image file to save.");
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

      print("Image saved at: ${savedImage.path}");
      return savedImage.path;
    } catch (e) {
      print("Error saving image: $e");
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
    }
  }

  String imgInsectPath = 'assets/images/stemborer/2s.jpg';
  String insectName = 'Unknown';
  String insectDesc = 'This image is unknown';
  String idNum = '0';
  String percent = '0';

  @override
  void initState() {
    super.initState();
    someMethod();
    conditionStatus();
    print('path load to: ${widget.imageSc}');
  }

  void conditionStatus() {
    setState(() {
      percent = (widget.output![0]['confidence'] * 100).toStringAsFixed(2);
    });
    //
    if (widget.output![0]['label'].toString() == "Tungro") {
      setState(() {
        imgInsectPath = 'assets/images/greenleafhopper/1s.jpg';
        insectName = 'Green Leafhopper';
        insectDesc =
            'Adults and nymphs cause direct damage to the rice plant by sucking the sap from leaf sheaths and leaf blades. GLH also cause indirect damage by injecting toxic chemicals and transmitting viruses (tungro, dwarf, transitory yellowing, and yellow- orange leaf) and a mycoplasma disease (yellow dwarf). They mostly confine themselves and feed on the leaf and leaf sheath of rice. Mild infestations reduce plant vigor and number of productive tillers. Heavy infestations cause withering and complete drying of the crop.';
        idNum = '1';
      });
    } else if (widget.output![0]['label'].toString() == "Rice Dead Heart") {
      setState(() {
        imgInsectPath = 'assets/images/stemborer/2s.jpg';
        insectName = 'Stem Borer';
        insectDesc =
            'Rice stem borers (RSB) can be present in all rice growing areas. During tillering, the typical damage symptom is deadheart, while in flowering stage, it causes whitehead. The larvae also produce tiny holes on the stem and deposit faces within it, which is seen when the stem is cut open.';
        idNum = '2';
      });
    } else if (widget.output![0]['label'].toString() == "Healthy") {
    } else {}
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
                Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      widget.imageSc!,
                      height: 300,
                      width: 400,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      color: Colors.black,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back)),
                ]),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: double.parse(percent) >= 100.00
                              ? Colors.green
                              : double.parse(percent) >= 80.00
                                  ? Colors.orange
                                  : double.parse(percent) >= 50.00
                                      ? Colors.red
                                      : Colors.black,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        'Confidence: $percent %',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Text(
                      "Disease: ${widget.output![0]['label']}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
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
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            insectName,
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: 400,
                        child: Text(
                          textAlign: TextAlign.justify,
                          insectDesc,
                        ),
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
    print('Inserted row id: $id');
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
      print('error: $e');
    }
  }
}
