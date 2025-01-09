import 'package:cropsight/controller/db_controller.dart';
import 'package:cropsight/views/descript/mandesc.dart';
import 'package:cropsight/widgets/imageview.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({
    super.key,
    required this.id,
  });

  final int id;

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  String? name, insectPic, desc, descWhere, descDamage;
  bool _isLoading = true;
  String? pic2, pic3;
  //

  void fetchInsectData(int insectId) async {
    final db = CropSightDatabase();
    final insectData = await db.getInsectID(insectId);
    if (insectData != null) {
      print('Insect Name: ${insectData['insectName']}');
      print('Insect Pic: ${insectData['insectPic']}');

      setState(() {
        name = insectData['insectName'].toString();
        insectPic = insectData['insectPic'].toString();
        desc = insectData['insectDesc'].toString();
        descWhere = insectData['insectWhere'].toString();
        descDamage = insectData['insectDamage'].toString();
        _isLoading = false;
      });

      if (insectData['insectName'] == 'Green LeafHopper') {
        setState(() {
          pic2 = 'assets/images/greenleafhopper/a.png';
          pic3 = 'assets/images/greenleafhopper/tungro.png';
        });
      } else if (insectData['insectName'] == 'Rice Leaffolder') {
        setState(() {
          pic2 = 'assets/images/riceleaffolder/photo_3.jpg';
          pic3 = 'assets/images/riceleaffolder/factsheet-leaffolder-1.jpg';
        });
      } else if (insectData['insectName'] == 'Rice Bug') {
        setState(() {
          pic2 = 'assets/images/ricebug/sss.png';
          pic3 = 'assets/images/ricebug/unnamed.jpg';
        });
      } else if (insectData['insectName'] == 'Stem Borer') {
        setState(() {
          pic2 = 'assets/images/stemborer/3s.jpg';
          pic3 = 'assets/images/stemborer/4s.jpg';
        });
      } else {
        setState(() {
          pic2 = 'assets/images/greenleafhopper/a.png';
          pic3 = 'assets/images/greenleafhopper/tungro.png';
        });
      }
    } else {
      print('No data found for insect ID $insectId');
    }
  }

  SizedBox sbx = const SizedBox(
    height: 10,
  );

  @override
  void initState() {
    super.initState();
    fetchInsectData(widget.id);
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
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name.toString(),
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ExpandableCarousel(
                      items: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: InkWell(
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
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewFullImg(
                                    img: pic2.toString(),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                pic2.toString(),
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewFullImg(
                                    img: pic3.toString(),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                pic3.toString(),
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                      options: ExpandableCarouselOptions(
                        showIndicator: true,
                        slideIndicator: CircularSlideIndicator(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                          textAlign: TextAlign.justify,
                        ),
                        sbx,
                        Text(
                          desc.toString(),
                          textAlign: TextAlign.justify,
                        ),
                        sbx,
                        ExpansionTile(
                          iconColor: Colors.green,
                          leading:
                              const Icon(FluentIcons.question_circle_12_filled),
                          title: const Text(
                            'Where to find',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                            textAlign: TextAlign.justify,
                          ),
                          children: [
                            Text(
                              descWhere.toString(),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                        sbx,
                        ExpansionTile(
                          iconColor: Colors.green,
                          leading: const Icon(
                              FluentIcons.book_question_mark_20_filled),
                          title: const Text(
                            'Damage',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                            textAlign: TextAlign.justify,
                          ),
                          children: [
                            Text(
                              descDamage.toString(),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManageDesc(
                                id: widget.id.toString(),
                              ),
                            ),
                          );
                        },
                        child: const Text('Solution'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
