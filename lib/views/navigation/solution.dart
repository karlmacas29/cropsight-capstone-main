import 'package:cropsight/services/insectjson.dart';
import 'package:cropsight/services/readjson.dart';
import 'package:cropsight/views/descript/manDesc.dart';
import 'package:flutter/material.dart';

class SolutionTab extends StatefulWidget {
  const SolutionTab({super.key});

  @override
  State<SolutionTab> createState() => _SolutionTabState();
}

class _SolutionTabState extends State<SolutionTab> {
  final RemoteJson remoteJson = RemoteJson();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'For Pests',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(
            height: 20,
          ),
          FutureBuilder<Insects>(
            future: remoteJson.allData(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snap.hasError) {
                return Center(
                  child: Text('${snap.error}'),
                );
              } else if (snap.hasData) {
                Insects insList = snap.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: insList.cropsightData.insectManage.length,
                  itemBuilder: (ctx, i) {
                    InsectManage manageDt =
                        insList.cropsightData.insectManage[i];
                    return Material(
                      elevation: 1,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageDesc(
                                  img: manageDt.insectPic,
                                  name: manageDt.insectName,
                                  culturalMn: manageDt.cultureMn,
                                  biologicalMn: manageDt.biologicalMn,
                                  chemicalMn: manageDt.chemicalMn,
                                ),
                              ));
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : const Color.fromARGB(255, 26, 26, 26),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20))),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      child: Image.asset(
                                        manageDt.insectPic,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                                Text(
                                  manageDt.insectName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 200,
                  ),
                );
              } else {
                return const Center(
                  child: Text('There is no Data Found'),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
