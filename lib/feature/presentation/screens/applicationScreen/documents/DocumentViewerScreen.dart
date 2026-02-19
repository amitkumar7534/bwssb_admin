import 'package:bwssb/components/appLoader.dart';
import 'package:bwssb/components/styles/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:bwssb/components/coreComponents/TextView.dart';
import 'package:bwssb/components/styles/appColors.dart';
import 'dart:typed_data';

import '../../../../../utils/appUtils.dart';


class DocumentViewerScreen extends StatelessWidget {
  final String? url;
  final String mimeType;
  final String originalFileName;
  final Uint8List imageBytes;

  const DocumentViewerScreen({
    super.key,
    this.url,
    required this.imageBytes,
    required this.mimeType,
    required this.originalFileName,
  });

  Future<void> _downloadFile(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$originalFileName');

      if (url != null && url!.isNotEmpty) {
        final response = await http.get(Uri.parse(url!));
        if (response.statusCode != 200) throw Exception("Failed to load from URL");
        await file.writeAsBytes(response.bodyBytes);
      } else {
        await file.writeAsBytes(imageBytes);
      }

      await OpenFile.open(file.path);
    } catch (e) {
      AppUtils.toastError("Download failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPDF = mimeType.toLowerCase().contains("pdf");
    final isFromUrl = url != null && url!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: TextView(
          text: originalFileName,
          style: 18.txtBoldBlack,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: AppColors.btnColor),
            onPressed: () => _downloadFile(context),
          ),
        ],
      ),
      body: isPDF
          ? FutureBuilder<File>(
        future: isFromUrl ? _loadFileFromUrl() : _loadFileFromBase64(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: AppLoader.loaderWidget());
          if (!snapshot.hasData || snapshot.hasError)
            return Center(child: Text("Error loading PDF"));
          return PDFView(filePath: snapshot.data!.path);
        },
      )
          : Center(
        child: imageBytes.isNotEmpty
            ? Image.memory(imageBytes)
            : Text("No content to display"),
      ),
    );
  }

  Future<File> _loadFileFromUrl() async {
    final response = await http.get(Uri.parse(url!));
    if (response.statusCode != 200) throw Exception("Failed to load");
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$originalFileName');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<File> _loadFileFromBase64() async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$originalFileName';
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    return file;
  }
}

