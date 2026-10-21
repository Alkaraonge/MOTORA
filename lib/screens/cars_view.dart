import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/business_store.dart';
import 'home_shell.dart';

class CarsView extends StatefulWidget {
  const CarsView({required this.store, required this.onMessage, super.key});

  final BusinessStore store;
  final ValueChanged<String> onMessage;

  @override
  State<CarsView> createState() => _CarsViewState();
}

class _CarsViewState extends State<CarsView> {
  String _filter = 'الكل';
  String _query = '';

  Future<void> _edit([Map<String, String>? current]) async {
    final values = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => VehicleForm(initial: current),
    );
    if (values == null) return;
    if (current == null) {
      await widget.store.add('vehicles', values);
      widget.onMessage('تمت إضافة السيارة وحفظها على الهاتف');
    } else {
      await widget.store.update('vehicles', current['id']!, values);
      widget.onMessage('تم تحديث بيانات السيارة');
    }
  }

  Future<void> _delete(Map<String, String> vehicle) async {
    final name = vehicleName(vehicle);
    if (!await confirmDelete(context, name)) return;
    await widget.store.remove('vehicles', vehicle['id']!);
    widget.onMessage('تم حذف $name');
  }

  Future<void> _copy(Map<String, String> vehicle) async {
    final text = <String>[
      vehicleName(vehicle),
      'السنة: ${vehicle['year'] ?? '-'}',
      'اللون: ${vehicle['color'] ?? '-'}',
      'الشاصي: ${vehicle['chassis'] ?? '-'}',
      'رقم السيارة: ${vehicle['plate'] ?? '-'}',
      'السعر: ${vehicle['salePrice'] ?? '-'} د.ع',
      'الحالة: ${vehicle['status'] ?? '-'}',
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    widget.onMessage('تم نسخ بيانات السيارة ويمكن لصقها في أي تطبيق');
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) {
      final items = widget.store.vehicles.where((vehicle) {
        final filterMatches = _filter == 'الكل' || vehicle['status'] == _filter;
        final haystack = vehicle.values.join(' ').toLowerCase();
        return filterMatches && haystack.contains(_query.toLowerCase());
      }).toList();
      return ListView(
        key: const PageStorageKey<String>('cars'),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: <Widget>[
          AppSectionTitle(
            title: 'مخزون السيارات',
            subtitle: '${widget.store.vehicles.length} سيارة محفوظة محلياً',
            action: 'إضافة',
            onAction: _edit,
          ),
          const SizedBox(height: 13),
          TextField(
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: const InputDecoration(
              labelText: 'بحث بالاسم أو الشاصي أو الرقم',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 11),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <String>['الكل', 'متاحة', 'محجوزة', 'مباعة']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            EmptyState(
              message: widget.store.vehicles.isEmpty
                  ? 'لا توجد سيارات بعد. اضغط إضافة وسجّل أول سيارة.'
                  : 'لا توجد نتائج مطابقة للبحث والفلتر.',
              icon: Icons.directions_car_outlined,
            )
          else
            ...items.map(
              (vehicle) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: VehicleCard(
                  vehicle: vehicle,
                  onEdit: () => _edit(vehicle),
                  onDelete: () => _delete(vehicle),
                  onCopy: () => _copy(vehicle),
                ),
              ),
            ),
        ],
      );
    },
  );
}

String vehicleName(Map<String, String> vehicle) {
  final name = '${vehicle['maker'] ?? ''} ${vehicle['model'] ?? ''}'.trim();
  return name.isEmpty ? 'سيارة بدون اسم' : name;
}

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
    required this.onCopy,
    super.key,
  });

  final Map<String, String> vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 105,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: <Color>[
                    colors.primary.withValues(alpha: .20),
                    colors.secondary.withValues(alpha: .05),
                  ],
                ),
              ),
              child: Icon(
                Icons.directions_car_filled_rounded,
                size: 76,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 13),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        vehicleName(vehicle),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${vehicle['year'] ?? '-'} • ${vehicle['color'] ?? '-'} • ${vehicle['plate'] ?? 'بدون رقم'}',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Chip(label: Text(vehicle['status'] ?? 'متاحة')),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              '${vehicle['salePrice']?.isNotEmpty == true ? vehicle['salePrice'] : 'السعر غير محدد'} د.ع',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (vehicle['chassis']?.isNotEmpty == true)
              Text(
                'VIN: ${vehicle['chassis']}',
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('تعديل'),
                  ),
                ),
                const SizedBox(width: 7),
                IconButton.filledTonal(
                  onPressed: onCopy,
                  tooltip: 'نسخ البيانات',
                  icon: const Icon(Icons.copy_all_outlined),
                ),
                const SizedBox(width: 7),
                IconButton.filledTonal(
                  onPressed: onDelete,
                  tooltip: 'حذف',
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VehicleForm extends StatefulWidget {
  const VehicleForm({this.initial, super.key});
  final Map<String, String>? initial;

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _key = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late String _status;

  @override
  void initState() {
    super.initState();
    final item = widget.initial ?? const <String, String>{};
    _controllers = <String, TextEditingController>{
      for (final field in <String>[
        'maker',
        'model',
        'year',
        'color',
        'chassis',
        'engine',
        'plate',
        'purchasePrice',
        'salePrice',
        'notes',
      ])
        field: TextEditingController(text: item[field] ?? ''),
    };
    _status = item['status'] ?? 'متاحة';
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'هذا الحقل مطلوب' : null;

  void _save() {
    if (!_key.currentState!.validate()) return;
    Navigator.pop(context, <String, String>{
      for (final entry in _controllers.entries)
        entry.key: entry.value.text.trim(),
      'status': _status,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                widget.initial == null ? 'إضافة سيارة' : 'تعديل السيارة',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _controllers['maker'],
                      validator: _required,
                      decoration: const InputDecoration(
                        labelText: 'الشركة / الماركة *',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _controllers['model'],
                      validator: _required,
                      decoration: const InputDecoration(labelText: 'الطراز *'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _controllers['year'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'السنة'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _controllers['color'],
                      decoration: const InputDecoration(labelText: 'اللون'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllers['chassis'],
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(labelText: 'رقم الشاصي VIN'),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _controllers['engine'],
                      decoration: const InputDecoration(
                        labelText: 'رقم المحرك',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _controllers['plate'],
                      decoration: const InputDecoration(
                        labelText: 'رقم السيارة',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _controllers['purchasePrice'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'سعر الشراء',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _controllers['salePrice'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'سعر البيع'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'الحالة'),
                items: <String>['متاحة', 'محجوزة', 'مباعة']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _status = value ?? _status),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllers['notes'],
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
              ),
              const SizedBox(height: 17),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('حفظ السيارة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
