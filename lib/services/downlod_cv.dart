// ignore_for_file: deprecated_member_use

import 'dart:html' as html;

void downloadCV() {
  final url = "assets/files/Jasir PK - Flutter Developer.pdf";
  // ignore: unused_local_variable
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'jasir_cv.pdf')
    ..click();
}
