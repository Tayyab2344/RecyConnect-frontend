import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/pakistan_locations.dart';

/// Reusable City & Area Selector Widget with Glassmorphism styling
/// Now includes searchable city dropdown
class CityAreaSelector extends StatefulWidget {
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
  State<CityAreaSelector> createState() => _CityAreaSelectorState();
}

class _CityAreaSelectorState extends State<CityAreaSelector> {
  String _citySearchQuery = '';
  String _areaSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        _buildCitySelector(isDark),
        const SizedBox(height: 16),
        _buildAreaSelector(isDark),
      ],
    );
  }

  Widget _buildCitySelector(bool isDark) {
    final labelColor = isDark 
        ? Colors.white.withValues(alpha: 0.8)
        : const Color(0xFF333333);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final hintColor = isDark 
        ? Colors.white.withValues(alpha: 0.4)
        : const Color(0xFF999999);
    final iconColor = isDark 
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF666666);
    final fillColor = isDark 
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF8F8F8);
    final borderColor = isDark 
        ? Colors.white.withValues(alpha: 0.15)
        : const Color(0xFFE0E0E0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabels)
          Text(
            'City${widget.isRequired ? " *" : ""}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: labelColor,
              letterSpacing: 0.5,
            ),
          ),
        if (widget.showLabels) const SizedBox(height: 8),
        
        // Searchable City Selector
        GestureDetector(
          onTap: () => _showCitySearchDialog(isDark),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.location_city_rounded, size: 20, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.selectedCity ?? 'Select city',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: widget.selectedCity != null ? FontWeight.w500 : FontWeight.w400,
                      color: widget.selectedCity != null ? textColor : hintColor,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: iconColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAreaSelector(bool isDark) {
    final areas = widget.selectedCity != null 
        ? PakistanLocations.getAreasForCity(widget.selectedCity!) 
        : <String>[];
    
    final isEnabled = widget.selectedCity != null;
    
    final labelColor = isDark 
        ? Colors.white.withValues(alpha: isEnabled ? 0.8 : 0.4)
        : Color(isEnabled ? 0xFF333333 : 0xFF999999);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final hintColor = isDark 
        ? Colors.white.withValues(alpha: 0.4)
        : const Color(0xFF999999);
    final iconColor = isDark 
        ? Colors.white.withValues(alpha: isEnabled ? 0.6 : 0.3)
        : Color(isEnabled ? 0xFF666666 : 0xFFAAAAAA);
    final fillColor = isDark 
        ? Colors.white.withValues(alpha: isEnabled ? 0.08 : 0.04)
        : Color(isEnabled ? 0xFFF8F8F8 : 0xFFF0F0F0);
    final borderColor = isDark 
        ? Colors.white.withValues(alpha: isEnabled ? 0.15 : 0.08)
        : Color(isEnabled ? 0xFFE0E0E0 : 0xFFEEEEEE);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabels)
          Text(
            'Area${widget.isRequired ? " *" : ""}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: labelColor,
              letterSpacing: 0.5,
            ),
          ),
        if (widget.showLabels) const SizedBox(height: 8),
        
        // Searchable Area Selector
        GestureDetector(
          onTap: isEnabled ? () => _showAreaSearchDialog(isDark, areas) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded, size: 20, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEnabled 
                        ? (widget.selectedArea ?? 'Select area')
                        : 'Select city first',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: widget.selectedArea != null ? FontWeight.w500 : FontWeight.w400,
                      color: widget.selectedArea != null ? textColor : hintColor,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: iconColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCitySearchDialog(bool isDark) {
    final cities = PakistanLocations.cities;
    setState(() => _citySearchQuery = '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredCities = cities
                .where((city) => city.toLowerCase().contains(_citySearchQuery.toLowerCase()))
                .toList();
            
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2A3A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(
                          'Select City',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        setModalState(() => _citySearchQuery = value);
                      },
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search city...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.grey.shade500,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.grey.shade600,
                        ),
                        filled: true,
                        fillColor: isDark 
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // City list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredCities.length,
                      itemBuilder: (context, index) {
                        final city = filteredCities[index];
                        final isSelected = city == widget.selectedCity;
                        
                        return ListTile(
                          onTap: () {
                            widget.onCityChanged(city);
                            Navigator.pop(context);
                          },
                          leading: Icon(
                            Icons.location_city_rounded,
                            color: isSelected 
                                ? (isDark ? const Color(0xFF00D9A5) : AppTheme.primaryGreen)
                                : (isDark ? Colors.white.withValues(alpha: 0.5) : Colors.grey.shade600),
                          ),
                          title: Text(
                            city,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: isDark ? const Color(0xFF00D9A5) : AppTheme.primaryGreen,
                                )
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          selectedTileColor: isDark 
                              ? const Color(0xFF00D9A5).withValues(alpha: 0.1)
                              : AppTheme.primaryGreen.withValues(alpha: 0.08),
                          selected: isSelected,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAreaSearchDialog(bool isDark, List<String> areas) {
    setState(() => _areaSearchQuery = '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredAreas = areas
                .where((area) => area.toLowerCase().contains(_areaSearchQuery.toLowerCase()))
                .toList();
            
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2A3A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Area',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              'in ${widget.selectedCity}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        setModalState(() => _areaSearchQuery = value);
                      },
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search area...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.grey.shade500,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.grey.shade600,
                        ),
                        filled: true,
                        fillColor: isDark 
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Area list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredAreas.length,
                      itemBuilder: (context, index) {
                        final area = filteredAreas[index];
                        final isSelected = area == widget.selectedArea;
                        
                        return ListTile(
                          onTap: () {
                            widget.onAreaChanged(area);
                            Navigator.pop(context);
                          },
                          leading: Icon(
                            Icons.location_on_rounded,
                            color: isSelected 
                                ? (isDark ? const Color(0xFF00D9A5) : AppTheme.primaryGreen)
                                : (isDark ? Colors.white.withValues(alpha: 0.5) : Colors.grey.shade600),
                          ),
                          title: Text(
                            area,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: isDark ? const Color(0xFF00D9A5) : AppTheme.primaryGreen,
                                )
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          selectedTileColor: isDark 
                              ? const Color(0xFF00D9A5).withValues(alpha: 0.1)
                              : AppTheme.primaryGreen.withValues(alpha: 0.08),
                          selected: isSelected,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
