import 'package:cropsight/models/imageview.dart';
import 'package:flutter/material.dart';

class ManageDesc extends StatefulWidget {
  const ManageDesc(
      {super.key,
      required this.name,
      required this.img,
      required this.culturalMn,
      required this.biologicalMn,
      required this.chemicalMn});

  final String name, img;
  final List<String> culturalMn, biologicalMn, chemicalMn;

  @override
  State<ManageDesc> createState() => _ManageDescState();
}

class _ManageDescState extends State<ManageDesc> {
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
      body: Material(
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
                                  builder: (context) =>
                                      ViewFullImg(img: widget.img)));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            widget.img,
                            height: 100,
                            width: 100,
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
                          Text(widget.name,
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
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
                    const Text(
                      'Management',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Cultural',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    ...widget.culturalMn.map((method) => ListTile(
                          title: Text(
                            method,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(height: 1.1),
                          ),
                        )),
                    const Text(
                      'Biological',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    ...widget.biologicalMn.map((method) => ListTile(
                          title: Text(
                            method,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(height: 1.1),
                          ),
                        )),
                    const Text(
                      'Chemical',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    ...widget.chemicalMn.map((method) => ListTile(
                          title: Text(
                            method,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(height: 1.1),
                          ),
                        ))
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
