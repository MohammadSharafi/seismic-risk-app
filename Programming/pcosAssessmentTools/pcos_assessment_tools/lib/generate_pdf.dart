import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pcos_assessment_tools/march_style/march_icons.dart';
import 'package:pcos_assessment_tools/req_model_class.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'dart:html' as html;

Map<String,String> questionTitle={
  '669380aa4884c6fe47c63b31':'Average Length of Menstrual Cycle',
  '669388884884c6fe47c64b9f':'Hair Growth',
  '669388e04884c6fe47c64c53':'Acne',
  '6693893c4884c6fe47c64d25':'Height, Weight & BMI	',
  '669389724884c6fe47c64d89':'Family History of PCOS',
};

pw.Text buildSimpleText({
  required String title,
  required double font,
  required PdfColor color,
  required pw.FontWeight fontWeight,
}) {
  final style = pw.TextStyle(fontWeight: fontWeight,fontSize: font,color: color);
  return pw.Text(title, style: style);
}

String questionAnswer(String id, dynamic answer) {
  switch (id) {
    case '669380aa4884c6fe47c63b31':  // Menstrual cycle type
      if (answer is Map<String, dynamic>) {
        switch( answer['menstrualCycleType']?.toString())
        {
          case 'BETWEEN_25_TO_35_DAYS':
            return 'Between 25 to 35 day';
          case 'BETWEEN_36_TO_45_DAYS':
            return 'Between 36 to 45 days';
          case 'MORE_THAN_45_DAYS':
            return 'More than 45 days';
          default:
            return 'Not answered';
        }
      }
      return '-';

    case '669388884884c6fe47c64b9f':  // Symptoms with severity (List of Maps)
      if (answer is List) {
        // Format each symptom with area and severity
        return answer.map((item) {
          if (item is Map) {
            String area = item['area'] ?? 'Unknown Area';
            String severity = item['severity'] != null
                ? 'Severity: ${item['severity']}'
                : 'No severity provided';
            return '$area ($severity)';
          }
          return 'Invalid symptom format';
        }).join(', ') ?? 'No symptoms listed';
      }
      return 'Invalid format for symptoms';

    case '669388e04884c6fe47c64c53':  // Pimples status
      if (answer is Map<String, dynamic>) {


        switch(answer['pimplesStatus']?.toString() ?? '')
        {
          case 'FOUR_OR_LESS_PIMPLES':
            return '4 or less pimples';
          case 'FIVE_OR_MORE_PIMPLES':
            return '5 or more pimples';
          default:
            return 'Not answered';
        }
      }
      return 'Invalid format for pimples status';

    case '6693893c4884c6fe47c64d25':  // Weight, Height, and BMI
      if (answer is Map<String, dynamic>) {
        String weight = answer['weight']?.toString() ?? 'Not answered';
        String height = answer['height']?.toString() ?? 'Not answered';
        String bmi = answer['bmi']?.toString() ?? 'Not answered';
        return 'Weight: $weight kg, Height: $height cm, BMI: $bmi';
      }
      return 'Invalid format for weight, height, and BMI';

    case '669389724884c6fe47c64d89':
      if (answer is String) {
        String ans = answer ?? '-';
        return ans;
      }
      return '-';

    default:
      return '_';
  }
}



Future<void> generatePdf(ChallengeModel challengeModel,String status,String color, String mean,String score) async {
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
          pw.Image(image2, width: 40, height: 40),

          // Title
          pw.SizedBox(height: 10),
          pw.Text('Challenge Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),

          // Email and Challenge Info
          pw.SizedBox(height: 8),
          pw.Text('Email: ${challengeModel.email}', style: pw.TextStyle(fontSize: 13)),
          pw.SizedBox(height: 8),

          pw.Text('Challenge ID: ${challengeModel.challengeId}', style: pw.TextStyle(fontSize: 13)),

          // Questions Table
          pw.SizedBox(height: 10),
          pw.Container(
              height: 18,
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
                      fontSize: 14,
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
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Question', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Answer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                      padding: const pw.EdgeInsets.all(2),
                      child: pw.Text(questionTitle[question.id]??'', style: pw.TextStyle(fontSize: 12)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(2),
                      child: pw.Text(questionAnswer(question.id,question.answer), style: pw.TextStyle(fontSize: 12)),
                    ),
                  ],
                );
              }).toList(),

            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                buildSimpleText(
                  title: 'Your Score:'+'${score}',
                  font: 14,
                  color: PdfColors.black, fontWeight: pw.FontWeight.bold,

                ),
              ]
          ),
          pw.SizedBox(height: 8),

          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Container(
                  width: 450,
                  child:buildSimpleText(
                    title: status.substring(2),
                    font: 12,
                    color: PdfColor.fromHex(color), fontWeight: pw.FontWeight.normal,
                  ),),

              ]
          ),

          pw.SizedBox(height: 8),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                buildSimpleText(
                  title: 'What Does This Mean?',
                  font: 14,
                  color: PdfColors.black, fontWeight: pw.FontWeight.bold,
                ),
              ]
          ),

          pw.SizedBox(height: 8),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Container(
                  width: 450,
                  child:buildSimpleText(
                    title: mean,
                    font: 12,
                    color: PdfColors.black, fontWeight: pw.FontWeight.normal,
                  ),),

              ]
          ),
          pw.SizedBox(height: 10),




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
