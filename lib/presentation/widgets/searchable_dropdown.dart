import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SearchableDropdown extends StatefulWidget {
  final String label;
  final String? hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final bool enabled;

  const SearchableDropdown({
    super.key,
    required this.label,
    this.hint,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _showSearchDialog() async {
    _searchController.clear();
    _filteredItems = widget.items;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          widget.prefixIcon ?? Icons.location_city,
                          color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Select ${widget.label}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search Field
                    TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search ${widget.label.toLowerCase()}...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _filterItems('');
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark 
                                ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                                : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark 
                            ? AppTheme.darkCardSurface 
                            : Colors.grey.shade50,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filterItems(value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Items Count
                    if (_filteredItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No results found',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${_filteredItems.length} ${widget.label.toLowerCase()}${_filteredItems.length != 1 ? 's' : ''} found',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                          ),
                        ),
                      ),

                    // Items List
                    if (_filteredItems.isNotEmpty)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark 
                                  ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _filteredItems.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: isDark 
                                  ? AppTheme.darkSecondaryGreen.withOpacity(0.2)
                                  : Colors.grey.shade200,
                            ),
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              final isSelected = item == widget.value;

                              return ListTile(
                                title: Text(
                                  item,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                                        : (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                                  ),
                                ),
                                leading: Icon(
                                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                                  color: isSelected
                                      ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                                      : Colors.grey.shade400,
                                ),
                                selected: isSelected,
                                selectedTileColor: isDark 
                                    ? AppTheme.darkPrimaryGreen.withOpacity(0.1)
                                    : AppTheme.primaryGreen.withOpacity(0.05),
                                onTap: () {
                                  widget.onChanged(item);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasError = widget.validator != null && widget.validator!(widget.value) != null;

    return FormField<String>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: widget.enabled ? _showSearchDialog : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? (isDark ? AppTheme.darkCardSurface : Colors.white)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: field.hasError
                        ? AppTheme.errorRed
                        : widget.value != null && widget.value!.isNotEmpty
                            ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                            : (isDark 
                                ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                                : Colors.grey.shade300),
                    width: field.hasError ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (widget.prefixIcon != null) ...[
                      Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: widget.value != null && widget.value!.isNotEmpty
                            ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                            : (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: field.hasError
                                  ? AppTheme.errorRed
                                  : (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.value ?? widget.hint ?? 'Select ${widget.label.toLowerCase()}',
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.value != null
                                  ? (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark)
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: widget.enabled
                          ? (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight)
                          : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: AppTheme.errorRed,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
