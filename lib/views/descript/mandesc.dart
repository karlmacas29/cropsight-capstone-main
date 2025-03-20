import 'package:cropsight/controller/db_controller.dart';
import 'package:cropsight/widgets/imageview.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageDesc extends StatefulWidget {
  const ManageDesc({
    super.key,
    required this.id,
  });

  final String id;

  @override
  State<ManageDesc> createState() => _ManageDescState();
}

class _ManageDescState extends State<ManageDesc> {
  String? name, insectPic;
  bool _isLoading = true;
  List<String> cultureMn = [];
  List<String> biologicalMn = [];
  List<String> chemicalMn = [];

  void fetchInsectData(int insectId) async {
    final db = CropSightDatabase();
    final insectData = await db.getInsectManagement(insectId);
    if (insectData != null) {
      debugPrint('Insect Name: ${insectData['insectName']}');
      debugPrint('Insect Pic: ${insectData['insectPic']}');

      final decodedManagement = db.decodeManagementData(insectData);

      // debugPrint('cultureMN: ${decodedManagement['cultureMn'][1]}');
      setState(() {
        name = insectData['insectName'].toString();
        insectPic = insectData['insectPic'].toString();
        //
        cultureMn = List<String>.from(decodedManagement['cultureMn'] ?? []);
        biologicalMn =
            List<String>.from(decodedManagement['biologicalMn'] ?? []);
        chemicalMn = List<String>.from(decodedManagement['chemicalMn'] ?? []);

        _isLoading = false;
      });
    } else {
      debugPrint('No data found for insect ID $insectId');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInsectData(int.parse(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color.fromRGBO(244, 253, 255, 1)
          : const Color.fromRGBO(18, 18, 18, 1),
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? const Color.fromRGBO(244, 253, 255, 1)
            : const Color.fromRGBO(18, 18, 18, 1),
        automaticallyImplyLeading: true,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Material(
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color.fromRGBO(244, 253, 255, 1)
                  : const Color.fromRGBO(18, 18, 18, 1),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    children: [
                      const SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewFullImg(
                                      img: insectPic.toString(),
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  insectPic.toString(),
                                  height: 98.h,
                                  width: 98.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  name.toString(),
                                  textAlign: TextAlign.left,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Management',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.sp,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ExpansionTile(
                            iconColor: Colors.green,
                            leading: const Icon(
                                FluentIcons.book_question_mark_20_filled),
                            title: Text(
                              'Cultural',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                            children: [
                              ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: cultureMn.map((value) {
                                  return ListTile(
                                    title: Text(
                                      value,
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        height: 1.1,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            iconColor: Colors.green,
                            leading: const Icon(
                                FluentIcons.book_question_mark_20_filled),
                            title: Text(
                              'Biological',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15.sp),
                            ),
                            children: [
                              ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: biologicalMn.map((value) {
                                  return ListTile(
                                    title: Text(
                                      value,
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        height: 1.1,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            iconColor: Colors.green,
                            leading: const Icon(
                                FluentIcons.book_question_mark_20_filled),
                            title: Text(
                              'Chemical',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15.sp),
                            ),
                            children: [
                              ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: chemicalMn.map((value) {
                                  return ListTile(
                                    title: Text(
                                      value,
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        height: 1.1,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
