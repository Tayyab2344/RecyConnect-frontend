import 'package:flutter/material.dart';
import '../../core/constants/city_data.dart';
import '../../core/theme/app_theme.dart';
import 'searchable_dropdown.dart';
import 'custom_text_field.dart';

class AddressInputSection extends StatefulWidget {
  final TextEditingController cityController;
  final TextEditingController areaController;
  final TextEditingController addressController;
  final bool isDark;
  final String? Function(String?)? cityValidator;
  final String? Function(String?)? areaValidator;
  final String? Function(String?)? addressValidator;

  const AddressInputSection({
    super.key,
    required this.cityController,
    required this.areaController,
    required this.addressController,
    required this.isDark,
    this.cityValidator,
    this.areaValidator,
    this.addressValidator,
  });

  @override
  State<AddressInputSection> createState() => _AddressInputSectionState();
}

class _AddressInputSectionState extends State<AddressInputSection> {
  List<String> _availableAreas = [];
  bool _showAreaDropdown = false;

  @override
  void initState() {
    super.initState();
    _updateAvailableAreas();
    widget.cityController.addListener(_onCityChanged);
  }

  @override
  void dispose() {
    widget.cityController.removeListener(_onCityChanged);
    super.dispose();
  }

  void _onCityChanged() {
    _updateAvailableAreas();
  }

  void _updateAvailableAreas() {
    setState(() {
      final city = widget.cityController.text;
      if (city.isNotEmpty) {
        _availableAreas = PakistanCities.getAreasForCity(city);
        _showAreaDropdown = _availableAreas.isNotEmpty;
        
        // Clear area if city changed and current area is not in new list
        if (!_availableAreas.contains(widget.areaController.text)) {
          widget.areaController.clear();
        }
      } else {
        _availableAreas = [];
        _showAreaDropdown = false;
        widget.areaController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark 
              ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
              : AppTheme.lightGray,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (widget.isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on,
                  color: widget.isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Address Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your complete business address',
            style: TextStyle(
              fontSize: 13,
              color: widget.isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 24),

          // City Searchable Dropdown
          SearchableDropdown(
            label: 'City',
            hint: 'Select your city',
            value: widget.cityController.text.isNotEmpty ? widget.cityController.text : null,
            items: PakistanCities.cities,
            prefixIcon: Icons.location_city,
            validator: widget.cityValidator ?? (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a city';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                widget.cityController.text = value ?? '';
              });
            },
          ),
          const SizedBox(height: 20),

          // Area - Show dropdown if city has predefined areas, otherwise show text field
          if (_showAreaDropdown) ...[
            SearchableDropdown(
              label: 'Area / Locality',
              hint: 'Select your area',
              value: widget.areaController.text.isNotEmpty ? widget.areaController.text : null,
              items: _availableAreas,
              prefixIcon: Icons.map,
              validator: widget.areaValidator ?? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an area';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  widget.areaController.text = value ?? '';
                });
              },
            ),
          ] else ...[
            CustomTextField(
              controller: widget.areaController,
              label: 'Area / Locality',
              hint: 'Enter your area or locality',
              icon: Icons.map,
              validator: widget.areaValidator ?? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your area';
                }
                if (value.trim().length < 3) {
                  return 'Area must be at least 3 characters';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 20),

          // Detailed Address
          CustomTextField(
            controller: widget.addressController,
            label: 'Street Address',
            hint: 'House/Plot number, Street name, Building',
            icon: Icons.home,
            maxLines: 3,
            keyboardType: TextInputType.streetAddress,
            validator: widget.addressValidator ?? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your street address';
              }
              if (value.trim().length < 10) {
                return 'Address must be at least 10 characters';
              }
              if (value.trim().length > 200) {
                return 'Address must not exceed 200 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),
          
          // Helper Text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.infoBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.infoBlue.withOpacity(0.1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppTheme.infoBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Provide accurate address for delivery and pickup services',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.infoBlue,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
