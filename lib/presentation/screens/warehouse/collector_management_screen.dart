import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/services/collector_service.dart';
import '../../../core/theme/app_theme.dart';

class CollectorManagementScreen extends StatefulWidget {
  const CollectorManagementScreen({super.key});

  @override
  State<CollectorManagementScreen> createState() => _CollectorManagementScreenState();
}

class _CollectorManagementScreenState extends State<CollectorManagementScreen> {
  final CollectorService _collectorService = CollectorService();
  late Future<List<dynamic>> _collectorsFuture;

  @override
  void initState() {
    super.initState();
    _loadCollectors();
  }

  void _loadCollectors() {
    setState(() {
      _collectorsFuture = _collectorService.getCollectors();
    });
  }

  void _showAddCollectorDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCollectorDialog(),
    ).then((added) {
      if (added == true) {
        _loadCollectors();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collector Management'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCollectorDialog,
        label: const Text('Add Collector'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _collectorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final collectors = snapshot.data ?? [];

          if (collectors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No collectors found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text('Add a collector to start managing pickups'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: collectors.length,
            itemBuilder: (context, index) {
              final collector = collectors[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: collector['profileImage'] != null
                            ? NetworkImage(collector['profileImage'])
                            : null,
                        child: collector['profileImage'] == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              collector['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${collector['collectorId']}',
                              style: TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Contact: ${collector['contactNo']}'),
                            const SizedBox(height: 4),
                            if (collector['plainPassword'] != null)
                              Text(
                                'Pass: ${collector['plainPassword']}',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => DispatchTaskDialog(collector: collector),
                          ).then((dispatched) {
                            if (dispatched == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Task dispatched successfully!")),
                              );
                            }
                          });
                        },
                        icon: const Icon(Icons.send_rounded),
                        color: AppTheme.primaryGreen,
                        tooltip: "Dispatch Task",
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AddCollectorDialog extends StatefulWidget {
  const AddCollectorDialog({super.key});

  @override
  State<AddCollectorDialog> createState() => _AddCollectorDialogState();
}

class _AddCollectorDialogState extends State<AddCollectorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final CollectorService _collectorService = CollectorService();
  
  XFile? _profileImage;
  XFile? _cnicImage;
  bool _isLoading = false;

  Future<void> _pickImage(bool isProfile) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isProfile) {
          _profileImage = image;
        } else {
          _cnicImage = image;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profileImage == null || _cnicImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both Profile Image and CNIC')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _collectorService.addCollector(
        name: _nameController.text,
        address: _addressController.text,
        contactNo: _contactController.text,
        profileImage: _profileImage,
        cnicImage: _cnicImage,
      );

      if (mounted) {
        Navigator.pop(context, true);
        // Show credentials dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Collector Created'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please save these credentials securely:'),
                const SizedBox(height: 16),
                SelectableText('Collector ID: ${result['data']['collectorId']}'),
                const SizedBox(height: 8),
                SelectableText('Password: ${result['data']['password']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Collector',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Profile Image Upload
                Center(
                  child: GestureDetector(
                    onTap: () => _pickImage(true),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!),
                        image: _profileImage != null
                            ? DecorationImage(
                                image: FileImage(File(_profileImage!.path)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profileImage == null
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(child: Text('Tap to add photo', style: TextStyle(fontSize: 12, color: Colors.grey))),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // CNIC Upload
                InkWell(
                  onTap: () => _pickImage(false),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.upload_file, color: _cnicImage != null ? AppTheme.primaryGreen : Colors.grey),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _cnicImage != null ? 'CNIC Selected' : 'Upload CNIC Image',
                            style: TextStyle(
                              color: _cnicImage != null ? AppTheme.primaryGreen : Colors.grey[600],
                              fontWeight: _cnicImage != null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (_cnicImage != null) const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Collector'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DispatchTaskDialog extends StatefulWidget {
  final Map<String, dynamic> collector;
  const DispatchTaskDialog({super.key, required this.collector});

  @override
  State<DispatchTaskDialog> createState() => _DispatchTaskDialogState();
}

class _DispatchTaskDialogState extends State<DispatchTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final CollectorService _collectorService = CollectorService();
  bool _isLoading = false;

  String _taskType = 'SELLER_TO_WAREHOUSE';
  String _sourceType = 'individual';
  final _sourceNameController = TextEditingController();
  final _sourceAddressController = TextEditingController();
  final _sourceContactController = TextEditingController();

  String _destinationType = 'warehouse';
  final _destinationNameController = TextEditingController();
  final _destinationAddressController = TextEditingController();
  final _destinationContactController = TextEditingController();

  final _categoryController = TextEditingController(text: 'Plastic');
  final _materialTypeController = TextEditingController(text: 'PET Bottles');
  final _weightController = TextEditingController(text: '15');
  final _priceController = TextEditingController(text: '45');
  final _instructionsController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = widget.collector['user'] as Map<String, dynamic>? ?? widget.collector;
      final int collectorId = user['id'] as int;

      await _collectorService.assignTask(
        collectorId: collectorId,
        taskType: _taskType,
        sourceType: _sourceType,
        sourceAddress: _sourceAddressController.text.trim(),
        sourceName: _sourceNameController.text.trim(),
        sourceContact: _sourceContactController.text.trim(),
        destinationType: _destinationType,
        destinationAddress: _destinationAddressController.text.trim(),
        destinationName: _destinationNameController.text.trim(),
        destinationContact: _destinationContactController.text.trim(),
        materialCategory: _categoryController.text.trim(),
        estimatedWeight: double.parse(_weightController.text.trim()),
        materialType: _materialTypeController.text.trim(),
        pricePerUnit: double.tryParse(_priceController.text.trim()),
        instructions: _instructionsController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to dispatch task: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dispatch Task',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                Text(
                  'Assigning to: ${widget.collector['name']}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),

                // Task Type Dropdown
                DropdownButtonFormField<String>(
                  value: _taskType,
                  decoration: const InputDecoration(labelText: 'Task Type', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'SELLER_TO_WAREHOUSE', child: Text('Seller to Warehouse')),
                    DropdownMenuItem(value: 'SELLER_TO_BUYER', child: Text('Seller to Buyer')),
                    DropdownMenuItem(value: 'WAREHOUSE_TO_BUYER', child: Text('Warehouse to Buyer')),
                    DropdownMenuItem(value: 'BUYER_REQUESTED_PICKUP', child: Text('Buyer Requested Pickup')),
                  ],
                  onChanged: (v) => setState(() => _taskType = v!),
                ),
                const SizedBox(height: 16),

                // Source Info Section
                Text('Pickup Source', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sourceNameController,
                  decoration: const InputDecoration(labelText: 'Source Name (e.g. Seller Name)', border: OutlineInputBorder()),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sourceAddressController,
                  decoration: const InputDecoration(labelText: 'Pickup Address', border: OutlineInputBorder()),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sourceContactController,
                  decoration: const InputDecoration(labelText: 'Source Contact', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                // Destination Info Section
                Text('Delivery Destination', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _destinationNameController,
                  decoration: const InputDecoration(labelText: 'Destination Name', border: OutlineInputBorder()),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _destinationAddressController,
                  decoration: const InputDecoration(labelText: 'Dropoff Address', border: OutlineInputBorder()),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _destinationContactController,
                  decoration: const InputDecoration(labelText: 'Destination Contact', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                // Material Info Section
                Text('Material Details', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _materialTypeController,
                        decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(labelText: 'Est. Weight (kg)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price / kg', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(labelText: 'Instructions / Notes', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Dispatch Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
