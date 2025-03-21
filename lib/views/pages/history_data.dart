import 'dart:io';

import 'package:cropsight/controller/db_controller.dart';
import 'package:cropsight/views/descript/information.dart';
import 'package:cropsight/views/descript/mandesc.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryDataScreen extends StatefulWidget {
  const HistoryDataScreen({
    super.key,
    required this.id,
    required this.insectId,
    required this.insectName,
    required this.insectDamage,
    required this.insectPic,
    required this.insectPercent,
    required this.location,
    required this.month,
    required this.year,
  });
  final String? id,
      insectId,
      insectName,
      insectDamage,
      insectPercent,
      location,
      month,
      year;

  final File? insectPic;
  @override
  State<HistoryDataScreen> createState() => _HistoryDataScreenState();
}

class _HistoryDataScreenState extends State<HistoryDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color.fromRGBO(244, 253, 255, 1)
          : const Color.fromARGB(255, 41, 41, 41),
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? const Color.fromRGBO(244, 253, 255, 1)
            : const Color.fromARGB(255, 41, 41, 41),
        title: Text(
          widget.insectName.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22.sp,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          // IconButton(
          //     onPressed: () => handleDelete(int.parse(widget.id.toString())),
          //     icon: const Icon(
          //       FluentIcons.delete_16_regular,
          //       color: Colors.redAccent,
          //     ))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Insect Image
              Center(
                child: Container(
                  width: 240.w,
                  height: 240.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      widget.insectPic!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.bug_report,
                          size: 100,
                          color: Colors.grey[400],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Damage Information
              Card(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color.fromRGBO(244, 253, 255, 1)
                    : const Color.fromARGB(255, 41, 41, 41),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 2,
                    children: [
                      Text(
                        'Result:',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.insectDamage.toString(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Details Card
              Card(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color.fromRGBO(244, 253, 255, 1)
                    : const Color.fromARGB(255, 41, 41, 41),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Confidence Percentage',
                        widget.insectPercent.toString(),
                        isPercentage: true,
                        isColor: double.parse(
                                    widget.insectPercent.toString()) >=
                                76.00
                            ? Colors.green
                            : double.parse(widget.insectPercent.toString()) >=
                                    51.00
                                ? Colors.orange
                                : double.parse(
                                            widget.insectPercent.toString()) >=
                                        26.00
                                    ? Colors.red
                                    : Colors.red,
                      ),
                      const Divider(),
                      _buildDetailRow(
                        'Barangay',
                        '${widget.location.toString()}, Panabo City',
                      ),
                      const Divider(),
                      _buildDetailRow(
                        'Scan Date',
                        '${widget.month} ${widget.year}',
                      ),
                    ],
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InfoPage(
                              id: int.parse(widget.insectId!),
                            ),
                          ),
                        );
                      },
                      child: const Text('Description'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
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
                              id: widget.insectId.toString(),
                            ),
                          ),
                        );
                      },
                      child: const Text('Solution'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap a button to close
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? const Color.fromRGBO(244, 253, 255, 1)
              : const Color.fromARGB(255, 41, 41, 41),
          title: const Text('Confirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this item?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when cancelled
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when confirmed
              },
            ),
          ],
        );
      },
    );
  }

  // Usage in a method
  void handleDelete(int id1) async {
    bool? confirmDelete = await showDeleteConfirmationDialog(context);
    if (confirmDelete == true) {
      // Perform actual deletion
      try {
        CropSightDatabase().deleteScanningHistoryEntry(id1).then((_) {
          if (mounted) {
            // Optional: Show a success dialog or snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Entry deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Optional: Refresh the list or update UI
          // For example, you might call a state update method
          setState(() {
            // Refresh your list of scanning history entries
          });
        }).catchError((error) {
          // Show error dialog or snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to delete entry: $error'),
              backgroundColor: Colors.red,
            ));
          }
        });
        if (mounted) {
          Navigator.pop(context, 'deleted');
        }
      } catch (e) {
        // Handle any unexpected errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('An unexpected error occurred'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  Widget _buildDetailRow(String label, String value,
      {bool isPercentage = false, Color? isColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromRGBO(244, 253, 255, 1)
                  : const Color.fromARGB(255, 41, 41, 41),
            ),
          ),
          isPercentage
              ? Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: double.parse(value) >= 76.00
                        ? Color.fromARGB(35, 76, 175, 79) // green
                        : double.parse(value) >= 51.00
                            ? Color.fromARGB(35, 255, 153, 0) //orange
                            : double.parse(value) >= 26.00
                                ? Color.fromARGB(35, 255, 0, 0)
                                : Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$value %",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: isPercentage
                          ? (isColor ?? Colors.green)
                          : Colors.green,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        isPercentage ? (isColor ?? Colors.green) : Colors.green,
                  ),
                ),
        ],
      ),
    );
  }
}
