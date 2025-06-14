// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:js' as js;
import 'package:web_portfolio/constants/colors.dart';
import 'package:web_portfolio/constants/links.dart';
import 'package:web_portfolio/services/extension_converter.dart';
import 'package:web_portfolio/services/file_icon.dart';
import 'package:web_portfolio/widgets/custom_textfield.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  List<String> attachments = [];
  bool isHtml = false;
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    subjectController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (kIsWeb) {
        // Web implementation using mailto
        await _sendEmailWeb();
      } else {
        // Mobile implementation using flutter_email_sender
        await _sendEmailMobile();
      }
    } catch (error) {
      _showSnackBar('Error: ${error.toString()}', isError: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendEmailWeb() async {
    final String subject = Uri.encodeComponent(subjectController.text);
    final String body = Uri.encodeComponent(bodyController.text);
    final String email = emailController.text;

    // Create mailto URL
    final String mailtoUrl = 'mailto:$email?subject=$subject&body=$body';

    try {
      if (await canLaunchUrl(Uri.parse(mailtoUrl))) {
        await launchUrl(Uri.parse(mailtoUrl));

        // Handle attachments separately for web
        if (attachments.isNotEmpty) {
          await _handleWebAttachments();
          _showSnackBar(
              'Email client opened! Attachments prepared for download.');
        } else {
          _showSnackBar('Email client opened successfully!');
        }
        _clearForm();
      } else {
        // Fallback: copy to clipboard with attachment info
        await _copyEmailToClipboard();
      }
    } catch (e) {
      await _copyEmailToClipboard();
    }
  }

  Future<void> _handleWebAttachments() async {
    if (attachments.isEmpty) return;

    try {
      // Show attachment options dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            backgroundColor: CustomColor.bgLight1,
            title: Row(
              children: [
                Icon(Icons.attachment, color: CustomColor.yellowSecondary),
                const SizedBox(width: 8),
                const Text(
                  'Attachments Ready',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your attachments are ready for download:',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ...attachments.asMap().entries.map((entry) {
                  String path = entry.value;
                  String fileName = path.split('/').last;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          getFileIcon(fileName),
                          color: CustomColor.yellowSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            fileName,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _downloadAttachment(path, fileName),
                          child: const Text(
                            'Download',
                            style:
                                TextStyle(color: CustomColor.yellowSecondary),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                const Text(
                  'Note: Download these files and manually attach them to your email.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: CustomColor.yellowSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _downloadAllAttachments();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.yellowSecondary,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Download All'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Could not prepare attachments: $e', isError: true);
    }
  }

  Future<void> _copyEmailToClipboard() async {
    String clipboardText = 'To: ${emailController.text}\n'
        'Subject: ${subjectController.text}\n\n'
        '${bodyController.text}';

    if (attachments.isNotEmpty) {
      clipboardText += '\n\nAttachments:\n';
      for (String path in attachments) {
        clipboardText += '- ${path.split('/').last}\n';
      }
      clipboardText += '\n(Note: Attachments need to be downloaded separately)';
    }

    await Clipboard.setData(ClipboardData(text: clipboardText));

    if (attachments.isNotEmpty) {
      _showSnackBar('Email details copied! Check attachments dialog.');
      await _handleWebAttachments();
    } else {
      _showSnackBar('Email details copied to clipboard!');
    }
  }

  Future<void> _downloadAttachment(String path, String fileName) async {
    try {
      if (kIsWeb) {
        // Check if it's a web attachment with stored data
        if (_webAttachmentData.containsKey(path)) {
          final data = _webAttachmentData[path]!;
          _triggerWebDownload(data['bytes'], data['name']);
        } else {
          // Handle created files
          if (fileName.contains('sample_file')) {
            final content = "Sample text file created from app\n"
                "Created at: ${DateTime.now()}\n"
                "This is a demo attachment.";
            final bytes = utf8.encode(content);
            _triggerWebDownload(bytes, fileName);
          } else {
            _showSnackBar('File not found: $fileName', isError: true);
          }
        }
      } else {
        // For mobile, files should exist on device
        final file = File(path);
        if (await file.exists()) {
          _showSnackBar('File ready: $fileName');
        } else {
          _showSnackBar('File not found: $fileName', isError: true);
        }
      }
    } catch (e) {
      _showSnackBar('Failed to download $fileName: $e', isError: true);
    }
  }

  void _triggerWebDownload(List<int> bytes, String fileName) {
    try {
      // Convert bytes to base64
      final base64String = base64Encode(bytes);
      final mimeType = getMimeType(fileName);

      // Create download URL
      final dataUrl = 'data:$mimeType;base64,$base64String';

      // Trigger download using JavaScript
      js.context.callMethod('eval', [
        '''
        (function() {
          var link = document.createElement('a');
          link.href = '$dataUrl';
          link.download = '$fileName';
          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);
        })()
      '''
      ]);

      _showSnackBar('$fileName downloaded successfully!');
    } catch (e) {
      _showSnackBar('Failed to download $fileName: $e', isError: true);
    }
  }

  Future<void> _downloadAllAttachments() async {
    for (int i = 0; i < attachments.length; i++) {
      final path = attachments[i];
      final fileName = path.split('/').last;
      await _downloadAttachment(path, fileName);

      // Add small delay between downloads
      if (i < attachments.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  Future<void> _sendEmailMobile() async {
    final Email email = Email(
      body: bodyController.text,
      subject: subjectController.text,
      recipients: [emailController.text],
      attachmentPaths: attachments,
      isHTML: isHtml,
    );

    await FlutterEmailSender.send(email);
    _showSnackBar('Email sent successfully!');
    _clearForm();
  }

  void _clearForm() {
    emailController.clear();
    subjectController.clear();
    bodyController.clear();
    setState(() {
      attachments.clear();
      isHtml = false;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CustomColor.bgLight1,
            CustomColor.bgLight1.withOpacity(0.8),
          ],
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Title with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail_outline,
                  color: CustomColor.whitePrimary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Get in touch",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: CustomColor.whitePrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              kIsWeb
                  ? "Fill out the form below to send an email"
                  : "Send us a message directly",
              style: TextStyle(
                fontSize: 16,
                color: CustomColor.whitePrimary.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Email and Subject fields
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: _buildEmailSubjectFields(),
            ),
            const SizedBox(height: 20),

            // Message field
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: CustomTextField(
                controller: bodyController,
                hintText: "Your message",
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),

            // HTML checkbox (only for mobile)
            if (!kIsWeb) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Card(
                  color: Colors.white.withOpacity(0.1),
                  child: CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    title: const Text(
                      'Send as HTML',
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (bool? value) {
                      setState(() {
                        isHtml = value ?? false;
                      });
                    },
                    value: isHtml,
                    activeColor: CustomColor.yellowSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Attachments section (show for all platforms with different behavior)
            _buildAttachmentsSection(),

            // Send button
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : send,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(isLoading ? 'Sending...' : 'Send Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.yellowSecondary,
                    foregroundColor: Colors.black,
                    elevation: 8,
                    shadowColor: CustomColor.yellowSecondary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Divider
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Divider(
                color: CustomColor.whitePrimary.withOpacity(0.3),
                thickness: 1,
              ),
            ),
            const SizedBox(height: 20),

            // Social media links
            _buildSocialMediaLinks(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSubjectFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: emailController,
                  hintText: "Your Email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: subjectController,
                  hintText: "Subject",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a subject';
                    }
                    return null;
                  },
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              CustomTextField(
                controller: emailController,
                hintText: "Your Email",
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: subjectController,
                hintText: "Subject",
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildAttachmentsSection() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Card(
        color: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.attachment,
                    color: CustomColor.whitePrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Attachments',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (kIsWeb) ...[
                    const SizedBox(width: 8),
                    Tooltip(
                      message:
                          'On web, attachments will be prepared for manual download',
                      child: Icon(
                        Icons.info_outline,
                        color: CustomColor.yellowSecondary,
                        size: 16,
                      ),
                    ),
                  ],
                ],
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 8),
                Text(
                  'Note: Attachments will be prepared for download and manual attachment',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Attachment list
              if (attachments.isNotEmpty) ...[
                ...attachments.asMap().entries.map((entry) {
                  int index = entry.key;
                  String path = entry.value;
                  String fileName = path.split('/').last;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          getFileIcon(fileName),
                          color: CustomColor.yellowSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (kIsWeb)
                                Text(
                                  'Ready for download',
                                  style: TextStyle(
                                    color: CustomColor.yellowSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => removeAttachment(index),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
              ],

              // Attachment buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: kIsWeb ? openImagePickerWeb : openImagePicker,
                      icon: const Icon(Icons.image),
                      label: const Text('Image'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: attachFileFromAppDocumentDirectory,
                      icon: const Icon(Icons.text_snippet),
                      label: const Text('Text File'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaLinks() {
    return Column(
      children: [
        const Text(
          'Connect with me',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _buildSocialIcon(
              "assets/images/github.png",
              SnsLinks.github,
              'GitHub',
            ),
            _buildSocialIcon(
              "assets/images/linkedin.png",
              SnsLinks.linkedIn,
              'LinkedIn',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(String assetPath, String url, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          if (kIsWeb) {
            js.context.callMethod('open', [url]);
          } else {
            launchUrl(Uri.parse(url));
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Image.asset(
            assetPath,
            width: 28,
            height: 28,
          ),
        ),
      ),
    );
  }

  void openImagePicker() async {
    try {
      final picker = ImagePicker();
      final pick = await picker.pickImage(source: ImageSource.gallery);
      if (pick != null) {
        setState(() {
          attachments.add(pick.path);
        });
        _showSnackBar('Image attached successfully!');
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e', isError: true);
    }
  }

  void openImagePickerWeb() async {
    try {
      final picker = ImagePicker();
      final pick = await picker.pickImage(source: ImageSource.gallery);
      if (pick != null) {
        // For web, we'll store the file data differently
        final bytes = await pick.readAsBytes();
        final fileName = pick.name;

        // Create a temporary reference for web
        final webPath = 'web_attachment_$fileName';
        setState(() {
          attachments.add(webPath);
        });

        // Store the file data for later download
        _webAttachmentData[webPath] = {
          'bytes': bytes,
          'name': fileName,
          'mimeType': getMimeType(fileName),
        };

        _showSnackBar('Image ready for attachment!');
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e', isError: true);
    }
  }

  // Add this field to store web attachment data
  final Map<String, Map<String, dynamic>> _webAttachmentData = {};

  void removeAttachment(int index) {
    setState(() {
      attachments.removeAt(index);
    });
    _showSnackBar('Attachment removed');
  }

  Future<void> attachFileFromAppDocumentDirectory() async {
    try {
      if (kIsWeb) {
        // For web, create the file content and store it
        final content = "Sample text file created from app\n"
            "Created at: ${DateTime.now()}\n"
            "This is a demo attachment.";
        final fileName =
            'sample_file_${DateTime.now().millisecondsSinceEpoch}.txt';
        final webPath = 'web_text_$fileName';

        setState(() {
          attachments.add(webPath);
        });

        // Store the file data for later download
        _webAttachmentData[webPath] = {
          'bytes': utf8.encode(content),
          'name': fileName,
          'mimeType': 'text/plain',
        };

        _showSnackBar('Text file ready for attachment!');
      } else {
        // Mobile implementation
        final appDocumentDir = await getApplicationCacheDirectory();
        final filePath =
            '${appDocumentDir.path}/sample_file_${DateTime.now().millisecondsSinceEpoch}.txt';
        final file = File(filePath);
        await file.writeAsString("Sample text file created from app\n"
            "Created at: ${DateTime.now()}\n"
            "This is a demo attachment.");
        setState(() {
          attachments.add(filePath);
        });
        _showSnackBar('Text file created and attached!');
      }
    } catch (e) {
      _showSnackBar('Failed to create file: $e', isError: true);
    }
  }
}
