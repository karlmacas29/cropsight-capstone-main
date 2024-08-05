import 'package:cropsight/models/imageview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class InfoPage extends StatefulWidget {
  const InfoPage(
      {super.key,
      required this.id,
      required this.name,
      required this.image,
      required this.desc,
      required this.inWhere,
      required this.inDamage});
  final String name, image, desc, inWhere, inDamage;
  final int id;

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  SizedBox sbx = const SizedBox(
    height: 10,
  );
  String imageString = "";
  String imageString1 = "";
  @override
  void initState() {
    super.initState();
    if (widget.id == 1) {
      setState(() {
        imageString =
            "assets/images/greenleafhopper/factsheet-green-leafhopper-1.jpg";
        imageString1 = "assets/images/greenleafhopper/medium.jpg";
      });
    } else if (widget.id == 2) {
      setState(() {
        imageString = "assets/images/riceleaffolder/factsheet-leaffolder-1.jpg";
        imageString1 = "assets/images/riceleaffolder/leaf-folder-moth.jpg";
      });
    } else if (widget.id == 3) {
      setState(() {
        imageString = "assets/images/ricebug/unnamed.jpg";
        imageString1 = "assets/images/ricebug/sss.png";
      });
    } else if (widget.id == 4) {
      setState(() {
        imageString = "assets/images/stemborer/2s.jpg";
        imageString1 = "assets/images/stemborer/3s.jpg";
      });
    } else {
      setState(() {
        imageString = "";
        imageString1 = "";
      });
    }
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.name,
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)),
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
                                  builder: (context) =>
                                      ViewFullImg(img: widget.image)));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            widget.image,
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
                                  builder: (context) =>
                                      ViewFullImg(img: imageString1)));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            imageString1,
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
                                  builder: (context) =>
                                      ViewFullImg(img: imageString)));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            imageString,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                  options: CarouselOptions(
                      showIndicator: true,
                      slideIndicator: const CircularSlideIndicator())),
              const SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    textAlign: TextAlign.justify,
                  ),
                  sbx,
                  Text(
                    widget.desc,
                    textAlign: TextAlign.justify,
                  ),
                  sbx,
                  const Text(
                    'Where to find',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    textAlign: TextAlign.justify,
                  ),
                  sbx,
                  Text(
                    widget.inWhere,
                    textAlign: TextAlign.justify,
                  ),
                  sbx,
                  const Text(
                    'Damage',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    textAlign: TextAlign.justify,
                  ),
                  sbx,
                  Text(
                    widget.inDamage,
                    textAlign: TextAlign.justify,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
