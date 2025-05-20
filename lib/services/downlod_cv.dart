import 'dart:html' as html;

void downloadCV() {
  final url = "assets/files/Jasir PK - Flutter Developer.pdf";
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'jasir_cv.pdf')
    ..click();
}
