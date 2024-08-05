import 'package:flutter/material.dart';

class ViewFullImg extends StatefulWidget {
  const ViewFullImg({super.key, required this.img});
  final String img;

  @override
  State<ViewFullImg> createState() => _ViewFullImgState();
}

class _ViewFullImgState extends State<ViewFullImg> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          clipBehavior: Clip.antiAlias,
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 0.1,
          maxScale: 3.5,
          child: Image.asset(
            widget.img,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
