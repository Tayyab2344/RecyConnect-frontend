import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/pakistan_locations.dart';

/// Reusable City & Area Selector Widget
/// 
/// Usage:
/// ```dart
/// String? selectedCity;
/// String? selectedArea;
/// 
/// CityAreaSelector(
///   selectedCity: selectedCity,
///   selectedArea: selectedArea,
///   onCityChanged: (city) {
///     setState(() {
///       selectedCity = city;
///       selectedArea = null; // Reset area when city changes
///     });
///   },
///   onAreaChanged: (area) {
///     setState(() {
///       selectedArea = area;
///     });
///   },
/// )
/// ```
class CityAreaSelector extends StatelessWidget {
  final String? selectedCity;
  final String? selectedArea;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String?> onAreaChanged;
  final bool showLabels;
  final bool isRequired;
  final String? cityValidator;
  final String? areaValidator;

  const CityAreaSelector({
    Key? key,
    required this.selectedCity,
    required this.selectedArea,
    required this.onCityChanged,
    required this.onAreaChanged,
    this.showLabels = true,
    this.isRequired = true,
    this.cityValidator,
    this.areaValidator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCityDropdown(),
        const SizedBox(height: 16),
        _buildAreaDropdown(),
      ],
    );
  }

  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabels)
          Text(
            'City${isRequired ? " *" : ""}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ),
        if (showLabels) const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedCity == null ? Colors.transparent : AppTheme.primaryGreen,
              width: selectedCity == null ? 0 : 2,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedCity,
            decoration: InputDecoration(
              hintText: 'Select your city',
              prefixIcon: Icon(Icons.location_city, color: AppTheme.primaryGreen),
              filled: true,
              fillColor: AppTheme.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryGreen),
            items: PakistanLocations.cities.map((String city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: onCityChanged,
            validator: (value) {
              if (cityValidator != null) return cityValidator;
              if (isRequired && (value == null || value.isEmpty)) {
                return 'Please select your city';
              }
              return null;
            },
            menuMaxHeight: 300, // Limit dropdown height for scrolling
          ),
        ),
      ],
    );
  }

  Widget _buildAreaDropdown() {
    final areas = selectedCity != null 
        ? PakistanLocations.getAreasForCity(selectedCity!) 
        : <String>[];
    
    final isEnabled = selectedCity != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabels)
          Text(
            'Area${isRequired ? " *" : ""}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isEnabled ? AppTheme.textDark : AppTheme.textLight,
            ),
          ),
        if (showLabels) const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isEnabled ? AppTheme.backgroundLight : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedArea == null ? Colors.transparent : AppTheme.primaryGreen,
              width: selectedArea == null ? 0 : 2,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedArea,
            decoration: InputDecoration(
              hintText: isEnabled ? 'Select your area' : 'Select city first',
              hintStyle: TextStyle(
                color: isEnabled ? AppTheme.textLight : Colors.grey.shade500,
              ),
              prefixIcon: Icon(
                Icons.location_on, 
                color: isEnabled ? AppTheme.primaryGreen : Colors.grey.shade400,
              ),
              filled: true,
              fillColor: isEnabled ? AppTheme.backgroundLight : Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            isExpanded: true,
            icon: Icon(
              Icons.arrow_drop_down, 
              color: isEnabled ? AppTheme.primaryGreen : Colors.grey.shade400,
            ),
            items: isEnabled
                ? areas.map((String area) {
                    return DropdownMenuItem<String>(
                      value: area,
                      child: Text(area, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList()
                : null,
            onChanged: isEnabled ? onAreaChanged : null,
            validator: (value) {
              if (areaValidator != null) return areaValidator;
              if (isRequired && (value == null || value.isEmpty)) {
                return 'Please select your area';
              }
              return null;
            },
            menuMaxHeight: 300, // Limit dropdown height for scrolling
          ),
        ),
        if (!isEnabled)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              'Please select a city first',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
