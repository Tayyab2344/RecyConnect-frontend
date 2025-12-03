import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

class ImagePickerWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final dynamic image; // Can be File or Uint8List
  final Function(dynamic) onImageSelected;

  const ImagePickerWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.image,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textLight,
            ),
          ),
        ],
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGray),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb && image is Uint8List
                        ? Image.memory(
                            image as Uint8List,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: AppTheme.lightGray,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 40,
                                    color: AppTheme.primaryGreen,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Image Selected',
                                    style: TextStyle(
                                      color: AppTheme.primaryGreen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: AppTheme.textLight,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap to select image',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        onImageSelected(bytes);
      } else {
        // For mobile platforms, you would use File
        onImageSelected(pickedFile.path);
      }
    }
  }
}



