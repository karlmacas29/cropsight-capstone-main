import 'dart:io';

import 'package:flutter/material.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, required this.imageSc, required this.output});
  final File? imageSc;
  final List? output;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: true,
      //   title: const Text('Results'),
      // ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(children: [
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
                widget.output != null
                    ? Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              'Confidence: ${(widget.output![0]['confidence'] * 100).toStringAsFixed(2) + '%'}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Text(
                            "Disease: ${widget.output![0]['label']}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      )
                    : const Text('Not a Rice', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                widget.output![0]['label'].toString() == "Rice Dead Heart"
                    ? Padding(
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
                                    'assets/images/stemborer/2s.jpg',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                const Text(
                                  'Stem Borer',
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: 400,
                              child: const Text(
                                textAlign: TextAlign.justify,
                                'Rice stem borers (RSB) can be present in all rice growing areas. During tillering, the typical damage symptom is deadheart, while in flowering stage, it causes whitehead. The larvae also produce tiny holes on the stem and deposit faeces within it, which is seen when the stem is cut open.',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text(
                                'Solution',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Colors.green)),
                            )
                          ],
                        ),
                      )
                    : widget.output![0]['label'].toString() == "Tungro"
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        'assets/images/greenleafhopper/1s.jpg',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    const Text(
                                      'Green Leafhopper',
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: 400,
                                  child: const Text(
                                    textAlign: TextAlign.justify,
                                    'Adults and nymphs cause direct damage to the rice plant by sucking the sap from leaf sheaths and leaf blades. GLH also cause indirect damage by injecting toxic chemicals and transmitting viruses (tungro, dwarf, transitory yellowing, and yellow- orange leaf) and a mycoplasma disease (yellow dwarf). They mostly confine themselves and feed on the leaf and leaf sheath of rice. Mild infestations reduce plant vigor and number of productive tillers. Heavy infestations cause withering and complete drying of the crop.',
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Solution',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStatePropertyAll(Colors.green)),
                                )
                              ],
                            ),
                          )
                        : const Text('No Insect'),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
