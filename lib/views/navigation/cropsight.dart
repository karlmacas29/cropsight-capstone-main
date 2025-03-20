import 'package:cropsight/controller/db_controller.dart';
import 'package:cropsight/views/descript/information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CropsightTab extends StatefulWidget {
  const CropsightTab({super.key});

  @override
  State<CropsightTab> createState() => _CropsightTabState();
}

class _CropsightTabState extends State<CropsightTab> {
  List<Map<String, dynamic>> _allData = []; //read
  bool _isLoading = true;

  void _refreshData() async {
    final db = CropSightDatabase();
    final insects = await db.getAllInsects();
    setState(() {
      _allData = insects;
      _isLoading = false;
    });
  }

  //data read debugPrint
  Future<void> displayInsectData() async {
    final db = CropSightDatabase();

    try {
      // Get all insects
      final insects = await db.getAllInsects();
      for (var insect in insects) {
        debugPrint('Insect: ${insect['insectName']}');

        // Get management data for this insect
        final management = await db.getInsectManagement(insect['insectID']);
        if (management != null) {
          // Decode the JSON strings back into lists
          final decodedManagement = db.decodeManagementData(management);
          debugPrint(
              'Management methods: ${decodedManagement['cultureMn'].length}');
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    displayInsectData();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 10),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              itemCount: _allData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InfoPage(
                          id: _allData[index]['insectID'],
                        ),
                      ),
                    );
                  },
                  child: Ink(
                    child: GridTile(
                      footer: Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(171, 0, 0, 0),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text(
                            _allData[index]['insectName'],
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      child: Container(
                        height: null,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_allData[index]['insectPic']),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }
}
