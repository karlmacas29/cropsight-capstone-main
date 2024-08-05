import 'package:cropsight/services/insectjson.dart';
import 'package:cropsight/services/readjson.dart';
import 'package:cropsight/views/descript/information.dart';
import 'package:flutter/material.dart';

class CropsightTab extends StatefulWidget {
  const CropsightTab({super.key});

  @override
  State<CropsightTab> createState() => _CropsightTabState();
}

class _CropsightTabState extends State<CropsightTab> {
  final RemoteJson remoteJson = RemoteJson();

  late List<Insects> filteredItems;
  String searchQuery = '';

  // @override
  // void initState() {
  //   super.initState();
  //   filteredItems = insects;
  // }

  // void _filterItems(String query) {
  //   setState(() {
  //     searchQuery = query;
  //     if (searchQuery.isEmpty) {
  //       filteredItems = insects;
  //     } else {
  //       final startsWithQuery = insects
  //           .where((insect) => insect.insectName
  //               .toLowerCase()
  //               .startsWith(searchQuery.toLowerCase()))
  //           .toList();
  //       final containsQuery = insects
  //           .where((insect) =>
  //               insect.insectName
  //                   .toLowerCase()
  //                   .contains(searchQuery.toLowerCase()) &&
  //               !insect.insectName
  //                   .toLowerCase()
  //                   .startsWith(searchQuery.toLowerCase()))
  //           .toList();
  //       filteredItems = [...startsWithQuery, ...containsQuery];
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBar(
            elevation: const WidgetStatePropertyAll(1),
            // onChanged: _filterItems,
            padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 20)),
            backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : const Color.fromARGB(255, 26, 26, 26)),
            hintText: 'Search...',
            keyboardType: TextInputType.text,
            trailing: const [Icon(Icons.search_rounded)],
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Rice Pest Lists',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: FutureBuilder<Insects>(
              future: remoteJson.allData(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snap.hasError) {
                  return Center(
                    child: Text('${snap.error}'),
                  );
                } else if (snap.hasData) {
                  Insects insList = snap.data!;
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: insList.cropsightData.insectList.length,
                    physics: const BouncingScrollPhysics(
                        decelerationRate: ScrollDecelerationRate.fast),
                    shrinkWrap: true,
                    itemBuilder: ((context, index) {
                      InsectList insectdt =
                          insList.cropsightData.insectList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          elevation: 1,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color.fromRGBO(244, 253, 255, 1)
                                  : const Color.fromARGB(255, 41, 41, 41),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            tileColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : const Color.fromARGB(255, 26, 26, 26),
                            selectedTileColor: Colors.green,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => InfoPage(
                                            id: insectdt.insectId,
                                            image: insectdt.insectPic,
                                            name: insectdt.insectName,
                                            desc: insectdt.insectDesc,
                                            inWhere: insectdt.insectWhere,
                                            inDamage: insectdt.insectDamage,
                                          )));
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                width: 50,
                                height: 50,
                                insectdt.insectPic,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(insectdt.insectName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              insectdt.insectDesc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                } else {
                  return const Center(
                    child: Text('There is no Data Found'),
                  );
                }
              },
            ),
          ) //
        ],
      ),
    );
  }
}
