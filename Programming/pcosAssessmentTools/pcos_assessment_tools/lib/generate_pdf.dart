import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pcos_assessment_tools/march_style/march_icons.dart';
import 'package:pcos_assessment_tools/req_model_class.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'dart:html' as html;

Future<void> generatePdf(ChallengeModel challengeModel) async {
  final pdf = pw.Document();


  // Load QR code image (optional, use your actual QR code image path)
  final ByteData data2 = await rootBundle.load(MarchIcons.pcos_icon_qr); // Replace with actual QR image path
  final image2 = pw.MemoryImage(data2.buffer.asUint8List());

  // Add a page to the document
  pdf.addPage(pw.Page(
    build: (pw.Context context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Logo Image
          pw.Image(image2, width: 100, height: 100),

          // Title
          pw.SizedBox(height: 20),
          pw.Text('Challenge Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),

          // Email and Challenge Info
          pw.SizedBox(height: 10),
          pw.Text('Email: ${challengeModel.email}', style: pw.TextStyle(fontSize: 13)),
          pw.SizedBox(height: 8),

          pw.Text('Challenge ID: ${challengeModel.challengeId}', style: pw.TextStyle(fontSize: 13)),

          // Questions Table
          pw.SizedBox(height: 20),
          pw.Container(
              height: 20,
              width: double.infinity,
              decoration: pw.BoxDecoration(
                  border: pw.TableBorder.all(color: PdfColors.blue, width: 1),
                  color: PdfColors.blue,
                  borderRadius: const pw.BorderRadius.only(
                      topRight: pw.Radius.circular(8),
                      topLeft: pw.Radius.circular(8))),
              child: pw.Center(
                child: pw.Text(
                  'Questions',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 15,
                      color: PdfColors.white),
                ),
              )),
          // Create Table for Questions
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.blue, width: 1),
            children: [
              pw.TableRow(

                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Question ID', style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 13)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Answer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 13)),
                  ),
                ],
              ),
              // Loop through the challenge questions
              ...challengeModel.challengeQuestions.map((question) {
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: challengeModel.challengeQuestions.indexOf(question) % 2 == 1
                          ? PdfColors.blue300
                          : PdfColors.blue50),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(question.id, style: pw.TextStyle(fontSize: 12)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('${question.answer}', style: pw.TextStyle(fontSize: 12)),
                    ),
                  ],
                );
              }).toList(),

            ],
          ),
          pw.Spacer(),
          pw.Row(
              children: [
                pw.Spacer(),
                pw.Text('${DateTime.now().toLocal().toString().split(' ')[0]}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),

              ]
          ),
        ],
      );
    },
  ));

  // Save the PDF to a Uint8List
  final pdfBytes = await pdf.save();

  // Trigger the file download using html package (works for web)
  final blob = html.Blob([Uint8List.fromList(pdfBytes)]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..target = 'blank'
    ..download = 'challenge_report.pdf';

  anchor.click();
  html.Url.revokeObjectUrl(url);
}
