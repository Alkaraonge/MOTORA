import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/business_store.dart';
import 'cars_view.dart';
import 'home_shell.dart';

class OperationsView extends StatelessWidget {
  const OperationsView({
    required this.store,
    required this.selectedIndex,
    required this.onSelected,
    required this.onMessage,
    super.key,
  });

  final BusinessStore store;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<String> onMessage;

  static const _sections = <(String, IconData)>[
    ('المبيعات', Icons.sell_outlined),
    ('المشتريات', Icons.shopping_cart_outlined),
    ('الديون', Icons.receipt_long_outlined),
    ('العقود', Icons.description_outlined),
  ];

  Future<void> _openForm(
    BuildContext context, {
    required String collection,
    required Widget Function(Map<String, String>? initial) builder,
    Map<String, String>? current,
  }) async {
    final values = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => builder(current),
    );
    if (values == null) return;
    if (current == null) {
      await store.add(collection, values);
      onMessage('تم الحفظ بنجاح على الهاتف');
    } else {
      await store.update(collection, current['id']!, values);
      onMessage('تم تحديث السجل');
    }
  }

  Future<void> _remove(
    BuildContext context,
    String collection,
    Map<String, String> item,
    String title,
  ) async {
    if (!await confirmDelete(context, title)) return;
    await store.remove(collection, item['id']!);
    onMessage('تم حذف السجل');
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => ListView(
      key: const PageStorageKey<String>('operations'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: <Widget>[
        const AppSectionTitle(
          title: 'الحسابات والعمليات',
          subtitle: 'إضافة وتعديل وحذف وكشف لكل عملية',
        ),
        const SizedBox(height: 13),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List<Widget>.generate(
              _sections.length,
              (index) => Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  avatar: Icon(_sections[index].$2, size: 18),
                  label: Text(_sections[index].$1),
                  selected: selectedIndex == index,
                  onSelected: (_) => onSelected(index),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 17),
        switch (selectedIndex) {
          0 => _SalesSection(
            store: store,
            onAdd: () => _openForm(
              context,
              collection: 'sales',
              builder: (initial) => SaleForm(store: store, initial: initial),
            ),
            onEdit: (item) => _openForm(
              context,
              collection: 'sales',
              current: item,
              builder: (initial) => SaleForm(store: store, initial: initial),
            ),
            onDelete: (item) =>
                _remove(context, 'sales', item, item['car'] ?? 'عملية البيع'),
          ),
          1 => _PurchasesSection(
            store: store,
            onAdd: () => _openForm(
              context,
              collection: 'purchases',
              builder: (initial) => PurchaseForm(initial: initial),
            ),
            onEdit: (item) => _openForm(
              context,
              collection: 'purchases',
              current: item,
              builder: (initial) => PurchaseForm(initial: initial),
            ),
            onDelete: (item) => _remove(
              context,
              'purchases',
              item,
              '${item['maker'] ?? ''} ${item['model'] ?? ''}',
            ),
          ),
          2 => _DebtsSection(
            store: store,
            onAdd: () => _openForm(
              context,
              collection: 'debts',
              builder: (initial) => DebtForm(initial: initial),
            ),
            onEdit: (item) => _openForm(
              context,
              collection: 'debts',
              current: item,
              builder: (initial) => DebtForm(initial: initial),
            ),
            onDelete: (item) =>
                _remove(context, 'debts', item, item['person'] ?? 'الدين'),
            onPayment: (item) => _addPayment(context, item),
          ),
          _ => _ContractsSection(
            store: store,
            onAdd: () => _openForm(
              context,
              collection: 'contracts',
              builder: (initial) =>
                  ContractForm(store: store, initial: initial),
            ),
            onEdit: (item) => _openForm(
              context,
              collection: 'contracts',
              current: item,
              builder: (initial) =>
                  ContractForm(store: store, initial: initial),
            ),
            onDelete: (item) =>
                _remove(context, 'contracts', item, item['number'] ?? 'العقد'),
            onPreview: (item) => _previewContract(context, item),
          ),
        },
      ],
    ),
  );

  Future<void> _addPayment(
    BuildContext context,
    Map<String, String> debt,
  ) async {
    final controller = TextEditingController();
    final note = TextEditingController();
    final amount = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('دفعة ${debt['person'] ?? ''}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'مبلغ الدفعة'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: note,
              decoration: const InputDecoration(labelText: 'ملاحظة'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('تسجيل الدفعة'),
          ),
        ],
      ),
    );
    if (amount == null || BusinessStore.parseAmount(amount) <= 0) return;
    await store.addDebtPayment(debt['id']!, amount, note: note.text.trim());
    onMessage('تم تسجيل الدفعة وتحديث المتبقي');
    controller.dispose();
    note.dispose();
  }

  Future<void> _previewContract(
    BuildContext context,
    Map<String, String> item,
  ) async {
    final text = contractText(item, store.settings);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('العقد ${item['number'] ?? ''}'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: SelectableText(text)),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) Navigator.pop(context);
              onMessage('تم نسخ العقد؛ افتحه في Word أو تطبيق الطباعة');
            },
            icon: const Icon(Icons.copy_all_outlined),
            label: const Text('نسخ للطباعة'),
          ),
        ],
      ),
    );
  }
}

class _SalesSection extends StatelessWidget {
  const _SalesSection({
    required this.store,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });
  final BusinessStore store;
  final VoidCallback onAdd;
  final ValueChanged<Map<String, String>> onEdit;
  final ValueChanged<Map<String, String>> onDelete;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      SummaryCard(
        icon: Icons.trending_up_rounded,
        title: 'إجمالي المبيعات',
        amount: BusinessStore.formatAmount(store.salesTotal),
        caption:
            '${store.sales.length} عملية • المقبوض ${BusinessStore.formatAmount(store.salesReceived)}',
      ),
      const SizedBox(height: 12),
      if (store.sales.isEmpty)
        const EmptyState(message: 'لا توجد مبيعات. سجّل أول عملية بيع.')
      else
        ...store.sales.map(
          (item) => OperationRecordCard(
            icon: Icons.sell_outlined,
            title: item['car'] ?? 'سيارة',
            subtitle: 'المشتري: ${item['customer'] ?? '-'}',
            amount: BusinessStore.formatAmount(
              BusinessStore.parseAmount(item['price']),
            ),
            detail:
                'المقبوض ${BusinessStore.formatAmount(BusinessStore.parseAmount(item['received']))}',
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item),
          ),
        ),
      const SizedBox(height: 5),
      FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add_rounded),
        label: const Text('تسجيل بيع سيارة'),
      ),
    ],
  );
}

class _PurchasesSection extends StatelessWidget {
  const _PurchasesSection({
    required this.store,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });
  final BusinessStore store;
  final VoidCallback onAdd;
  final ValueChanged<Map<String, String>> onEdit;
  final ValueChanged<Map<String, String>> onDelete;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      SummaryCard(
        icon: Icons.inventory_2_outlined,
        title: 'قيمة المشتريات',
        amount: BusinessStore.formatAmount(store.purchasesTotal),
        caption: '${store.purchases.length} عملية شراء',
      ),
      const SizedBox(height: 12),
      if (store.purchases.isEmpty)
        const EmptyState(
          message: 'لا توجد مشتريات. السيارة المشتراة تضاف للمخزون تلقائياً.',
        )
      else
        ...store.purchases.map(
          (item) => OperationRecordCard(
            icon: Icons.shopping_cart_outlined,
            title: '${item['maker'] ?? ''} ${item['model'] ?? ''}'.trim(),
            subtitle: 'المورد: ${item['supplier'] ?? '-'}',
            amount: BusinessStore.formatAmount(
              BusinessStore.parseAmount(item['price']),
            ),
            detail:
                'VIN: ${item['chassis']?.isNotEmpty == true ? item['chassis'] : '-'}',
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item),
          ),
        ),
      const SizedBox(height: 5),
      FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('تسجيل شراء سيارة'),
      ),
    ],
  );
}

class _DebtsSection extends StatelessWidget {
  const _DebtsSection({
    required this.store,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onPayment,
  });
  final BusinessStore store;
  final VoidCallback onAdd;
  final ValueChanged<Map<String, String>> onEdit;
  final ValueChanged<Map<String, String>> onDelete;
  final ValueChanged<Map<String, String>> onPayment;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      SummaryCard(
        icon: Icons.account_balance_wallet_outlined,
        title: 'الديون المتبقية',
        amount: BusinessStore.formatAmount(store.debtsRemaining),
        caption: '${store.debts.length} حساب • ${store.payments.length} دفعة',
      ),
      const SizedBox(height: 12),
      if (store.debts.isEmpty)
        const EmptyState(
          message: 'لا توجد ديون. البيع الآجل ينشئ ديناً تلقائياً.',
        )
      else
        ...store.debts.map((item) {
          final remaining =
              (BusinessStore.parseAmount(item['total']) -
                      BusinessStore.parseAmount(item['paid']))
                  .clamp(0, 1 << 62);
          return OperationRecordCard(
            icon: Icons.person_outline_rounded,
            title: item['person'] ?? 'حساب دين',
            subtitle:
                '${item['type'] ?? ''} • استحقاق ${item['due']?.isNotEmpty == true ? item['due'] : '-'}',
            amount: BusinessStore.formatAmount(remaining),
            detail:
                'المدفوع ${BusinessStore.formatAmount(BusinessStore.parseAmount(item['paid']))}',
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item),
            action: remaining > 0 ? () => onPayment(item) : null,
            actionLabel: 'دفعة',
          );
        }),
      const SizedBox(height: 5),
      FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.post_add_rounded),
        label: const Text('إضافة دين أو دفعة'),
      ),
    ],
  );
}

class _ContractsSection extends StatelessWidget {
  const _ContractsSection({
    required this.store,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onPreview,
  });
  final BusinessStore store;
  final VoidCallback onAdd;
  final ValueChanged<Map<String, String>> onEdit;
  final ValueChanged<Map<String, String>> onDelete;
  final ValueChanged<Map<String, String>> onPreview;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      SummaryCard(
        icon: Icons.description_outlined,
        title: 'عقود البيع',
        amount: '${store.contracts.length} عقد',
        caption: 'حقول المالك والبائع والمشتري والسيارة والمبلغ',
      ),
      const SizedBox(height: 12),
      if (store.contracts.isEmpty)
        const EmptyState(message: 'لا توجد عقود محفوظة بعد.')
      else
        ...store.contracts.map(
          (item) => OperationRecordCard(
            icon: Icons.description_rounded,
            title: item['number'] ?? 'عقد',
            subtitle:
                'المشتري: ${item['buyerName'] ?? '-'} • ${item['car'] ?? '-'}',
            amount: BusinessStore.formatAmount(
              BusinessStore.parseAmount(item['total']),
            ),
            detail: item['date'] ?? '',
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item),
            action: () => onPreview(item),
            actionLabel: 'معاينة',
          ),
        ),
      const SizedBox(height: 5),
      FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('إنشاء عقد بيع جديد'),
      ),
    ],
  );
}

class OperationRecordCard extends StatelessWidget {
  const OperationRecordCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.detail,
    required this.onEdit,
    required this.onDelete,
    this.action,
    this.actionLabel,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final String detail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, color: colors.primary, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          detail,
                          style: TextStyle(color: colors.primary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    amount,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (action != null)
                    TextButton.icon(
                      onPressed: action,
                      icon: const Icon(Icons.open_in_new_rounded, size: 17),
                      label: Text(actionLabel ?? 'فتح'),
                    ),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    label: const Text('تعديل'),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: 'حذف',
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormScaffold extends StatelessWidget {
  const _FormScaffold({
    required this.formKey,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.onSave,
  });
  final GlobalKey<FormState> formKey;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 15),
              for (final child in children) ...<Widget>[
                child,
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              FilledButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save_outlined),
                label: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? requiredField(String? value) =>
    value == null || value.trim().isEmpty ? 'هذا الحقل مطلوب' : null;

class SaleForm extends StatefulWidget {
  const SaleForm({required this.store, this.initial, super.key});
  final BusinessStore store;
  final Map<String, String>? initial;

  @override
  State<SaleForm> createState() => _SaleFormState();
}

class _SaleFormState extends State<SaleForm> {
  final _key = GlobalKey<FormState>();
  late final Map<String, TextEditingController> c;
  String? vehicleId;
  String method = 'نقداً';

  @override
  void initState() {
    super.initState();
    final item = widget.initial ?? const <String, String>{};
    c = _makeControllers(item, <String>[
      'car',
      'customer',
      'phone',
      'price',
      'received',
      'due',
      'notes',
    ]);
    vehicleId = item['vehicleId'];
    method = item['method'] ?? 'نقداً';
  }

  @override
  void dispose() {
    _disposeControllers(c);
    super.dispose();
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    final selected = widget.store.vehicles
        .where((item) => item['id'] == vehicleId)
        .firstOrNull;
    Navigator.pop(context, <String, String>{
      for (final entry in c.entries) entry.key: entry.value.text.trim(),
      'vehicleId': vehicleId ?? '',
      'car': selected == null ? c['car']!.text.trim() : vehicleName(selected),
      'method': method,
      'currency': 'دينار عراقي',
      'date': widget.initial?['date'] ?? DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final available = widget.store.vehicles
        .where((item) => item['status'] != 'مباعة')
        .toList();
    return _FormScaffold(
      formKey: _key,
      title: widget.initial == null ? 'تسجيل عملية بيع' : 'تعديل عملية البيع',
      subtitle: 'المشتري والمبلغ المقبوض والمتبقي والاستحقاق',
      onSave: _save,
      children: <Widget>[
        if (available.isNotEmpty)
          DropdownButtonFormField<String>(
            initialValue: available.any((item) => item['id'] == vehicleId)
                ? vehicleId
                : null,
            validator: (value) => value == null ? 'اختر السيارة' : null,
            decoration: const InputDecoration(
              labelText: 'السيارة من المخزون *',
            ),
            items: available
                .map(
                  (item) => DropdownMenuItem(
                    value: item['id'],
                    child: Text(vehicleName(item)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => vehicleId = value),
          )
        else
          TextFormField(
            controller: c['car'],
            validator: requiredField,
            decoration: const InputDecoration(
              labelText: 'اسم السيارة *',
              helperText: 'المخزون فارغ؛ يمكنك كتابة السيارة يدوياً',
            ),
          ),
        TextFormField(
          controller: c['customer'],
          validator: requiredField,
          decoration: const InputDecoration(labelText: 'اسم المشتري *'),
        ),
        TextFormField(
          controller: c['phone'],
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'هاتف المشتري'),
        ),
        TextFormField(
          controller: c['price'],
          validator: requiredField,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'سعر البيع *'),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller: c['received'],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المبلغ المقبوض'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: c['due'],
                decoration: const InputDecoration(labelText: 'الاستحقاق'),
              ),
            ),
          ],
        ),
        DropdownButtonFormField<String>(
          initialValue: method,
          decoration: const InputDecoration(labelText: 'طريقة الدفع'),
          items: <String>['نقداً', 'أجل', 'نقداً وأجل']
              .map(
                (value) => DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: (value) => setState(() => method = value ?? method),
        ),
        TextFormField(
          controller: c['notes'],
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'ملاحظات'),
        ),
      ],
    );
  }
}

class PurchaseForm extends StatefulWidget {
  const PurchaseForm({this.initial, super.key});
  final Map<String, String>? initial;

  @override
  State<PurchaseForm> createState() => _PurchaseFormState();
}

class _PurchaseFormState extends State<PurchaseForm> {
  final _key = GlobalKey<FormState>();
  late final Map<String, TextEditingController> c;

  @override
  void initState() {
    super.initState();
    c = _makeControllers(widget.initial ?? const <String, String>{}, <String>[
      'maker',
      'model',
      'year',
      'color',
      'chassis',
      'engine',
      'plate',
      'supplier',
      'phone',
      'price',
      'salePrice',
      'notes',
    ]);
  }

  @override
  void dispose() {
    _disposeControllers(c);
    super.dispose();
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    Navigator.pop(context, <String, String>{
      for (final entry in c.entries) entry.key: entry.value.text.trim(),
      'currency': 'دينار عراقي',
      'date': widget.initial?['date'] ?? DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) => _FormScaffold(
    formKey: _key,
    title: widget.initial == null ? 'تسجيل شراء سيارة' : 'تعديل عملية الشراء',
    subtitle: 'حفظ الشراء الجديد يضيف السيارة إلى المخزون تلقائياً',
    onSave: _save,
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: c['maker'],
              validator: requiredField,
              decoration: const InputDecoration(labelText: 'الماركة *'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: c['model'],
              validator: requiredField,
              decoration: const InputDecoration(labelText: 'الطراز *'),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: c['year'],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'السنة'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: c['color'],
              decoration: const InputDecoration(labelText: 'اللون'),
            ),
          ),
        ],
      ),
      TextFormField(
        controller: c['chassis'],
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(labelText: 'رقم الشاصي VIN'),
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: c['engine'],
              decoration: const InputDecoration(labelText: 'رقم المحرك'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: c['plate'],
              decoration: const InputDecoration(labelText: 'رقم السيارة'),
            ),
          ),
        ],
      ),
      TextFormField(
        controller: c['supplier'],
        validator: requiredField,
        decoration: const InputDecoration(labelText: 'اسم المورد / البائع *'),
      ),
      TextFormField(
        controller: c['phone'],
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'هاتف المورد'),
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: c['price'],
              validator: requiredField,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'سعر الشراء *'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: c['salePrice'],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'سعر البيع المطلوب'),
            ),
          ),
        ],
      ),
      TextFormField(
        controller: c['notes'],
        maxLines: 2,
        decoration: const InputDecoration(labelText: 'ملاحظات'),
      ),
    ],
  );
}

class DebtForm extends StatefulWidget {
  const DebtForm({this.initial, super.key});
  final Map<String, String>? initial;

  @override
  State<DebtForm> createState() => _DebtFormState();
}

class _DebtFormState extends State<DebtForm> {
  final _key = GlobalKey<FormState>();
  late final Map<String, TextEditingController> c;
  String type = 'عميل';

  @override
  void initState() {
    super.initState();
    c = _makeControllers(widget.initial ?? const <String, String>{}, <String>[
      'person',
      'phone',
      'total',
      'paid',
      'due',
      'notes',
    ]);
    type = widget.initial?['type'] ?? 'عميل';
  }

  @override
  void dispose() {
    _disposeControllers(c);
    super.dispose();
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    Navigator.pop(context, <String, String>{
      for (final entry in c.entries) entry.key: entry.value.text.trim(),
      'type': type,
      'date': widget.initial?['date'] ?? DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) => _FormScaffold(
    formKey: _key,
    title: widget.initial == null ? 'إضافة دين' : 'تعديل الدين',
    subtitle: 'سجّل المبلغ والمدفوع ثم أضف الدفعات من كشف الدين',
    onSave: _save,
    children: <Widget>[
      DropdownButtonFormField<String>(
        initialValue: type,
        decoration: const InputDecoration(labelText: 'نوع الحساب'),
        items: <String>['عميل', 'مورد', 'دين شخصي']
            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
            .toList(),
        onChanged: (value) => setState(() => type = value ?? type),
      ),
      TextFormField(
        controller: c['person'],
        validator: requiredField,
        decoration: const InputDecoration(labelText: 'اسم صاحب الدين *'),
      ),
      TextFormField(
        controller: c['phone'],
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'رقم الهاتف'),
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: c['total'],
              validator: requiredField,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ الكلي *'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: c['paid'],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المدفوع'),
            ),
          ),
        ],
      ),
      TextFormField(
        controller: c['due'],
        decoration: const InputDecoration(labelText: 'تاريخ الاستحقاق'),
      ),
      TextFormField(
        controller: c['notes'],
        maxLines: 2,
        decoration: const InputDecoration(labelText: 'السبب أو الملاحظات'),
      ),
    ],
  );
}

class ContractForm extends StatefulWidget {
  const ContractForm({required this.store, this.initial, super.key});
  final BusinessStore store;
  final Map<String, String>? initial;

  @override
  State<ContractForm> createState() => _ContractFormState();
}

class _ContractFormState extends State<ContractForm> {
  final _key = GlobalKey<FormState>();
  late final Map<String, TextEditingController> c;
  String? vehicleId;

  @override
  void initState() {
    super.initState();
    final item = widget.initial ?? const <String, String>{};
    c = _makeControllers(item, <String>[
      'number',
      'date',
      'legalOwner',
      'legalOwnerAddress',
      'sellerName',
      'sellerId',
      'sellerJob',
      'sellerContact',
      'buyerName',
      'buyerId',
      'buyerJob',
      'buyerContact',
      'car',
      'plate',
      'usage',
      'model',
      'color',
      'chassis',
      'total',
      'received',
      'remaining',
      'notes',
    ]);
    vehicleId = item['vehicleId'];
    if (c['number']!.text.isEmpty) {
      c['number']!.text =
          'ZC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }
    if (c['date']!.text.isEmpty) c['date']!.text = _shortDate(DateTime.now());
  }

  @override
  void dispose() {
    _disposeControllers(c);
    super.dispose();
  }

  void _selectVehicle(String? id) {
    setState(() => vehicleId = id);
    final vehicle = widget.store.vehicles
        .where((item) => item['id'] == id)
        .firstOrNull;
    if (vehicle == null) return;
    c['car']!.text = vehicleName(vehicle);
    c['plate']!.text = vehicle['plate'] ?? '';
    c['model']!.text = vehicle['year'] ?? '';
    c['color']!.text = vehicle['color'] ?? '';
    c['chassis']!.text = vehicle['chassis'] ?? '';
    c['total']!.text = vehicle['salePrice'] ?? '';
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    Navigator.pop(context, <String, String>{
      for (final entry in c.entries) entry.key: entry.value.text.trim(),
      'vehicleId': vehicleId ?? '',
    });
  }

  @override
  Widget build(BuildContext context) => _FormScaffold(
    formKey: _key,
    title: widget.initial == null ? 'عقد بيع جديد' : 'تعديل عقد البيع',
    subtitle: 'حقول العقد الأصلية كاملة ومحفوظة محلياً',
    onSave: _save,
    children: <Widget>[
      const _FormHeading('بيانات العقد'),
      Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: c['number'],
              validator: requiredField,
              decoration: const InputDecoration(labelText: 'رقم العقد *'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: c['date'],
              decoration: const InputDecoration(labelText: 'التاريخ'),
            ),
          ),
        ],
      ),
      TextFormField(
        controller: c['legalOwner'],
        decoration: const InputDecoration(labelText: 'اسم المالك الشرعي'),
      ),
      TextFormField(
        controller: c['legalOwnerAddress'],
        decoration: const InputDecoration(labelText: 'سكن المالك الشرعي'),
      ),
      const _FormHeading('الطرف الأول • البائع'),
      TextFormField(
        controller: c['sellerName'],
        validator: requiredField,
        decoration: const InputDecoration(labelText: 'اسم البائع *'),
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: c['sellerId'],
              decoration: const InputDecoration(labelText: 'رقم الهوية'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: c['sellerJob'],
              decoration: const InputDecoration(labelText: 'المهنة'),
            ),
          ),
        ],
      ),
      TextFormField(
        controller: c['sellerContact'],
        decoration: const InputDecoration(
          labelText: 'عنوان البائع ورقم الهاتف',
        ),
      ),
      const _FormHeading('الطرف الثاني • المشتري'),
      TextFormField(
        controller: c['buyerName'],
        validator: requiredField,
        decoration: const InputDecoration(labelText: 'اسم المشتري *'),
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: c['buyerId'],
              decoration: const InputDecoration(labelText: 'رقم الهوية'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: c['buyerJob'],
              decoration: const InputDecoration(labelText: 'المهنة'),
            ),
          ),
        ],
      ),
      TextFormField(
        controller: c['buyerContact'],
        decoration: const InputDecoration(
          labelText: 'عنوان المشتري ورقم الهاتف',
        ),
      ),
      const _FormHeading('بيانات السيارة'),
      if (widget.store.vehicles.isNotEmpty)
        DropdownButtonFormField<String>(
          initialValue:
              widget.store.vehicles.any((item) => item['id'] == vehicleId)
              ? vehicleId
              : null,
          decoration: const InputDecoration(labelText: 'اختيار من المخزون'),
          items: widget.store.vehicles
              .map(
                (item) => DropdownMenuItem(
                  value: item['id'],
                  child: Text(vehicleName(item)),
                ),
              )
              .toList(),
          onChanged: _selectVehicle,
        ),
      TextFormField(
        controller: c['car'],
        validator: requiredField,
        decoration: const InputDecoration(labelText: 'السيارة *'),
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: c['plate'],
              decoration: const InputDecoration(labelText: 'رقم السيارة'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: c['usage'],
              decoration: const InputDecoration(labelText: 'النوع / الاستخدام'),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: c['model'],
              decoration: const InputDecoration(labelText: 'الموديل'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: c['color'],
              decoration: const InputDecoration(labelText: 'اللون'),
            ),
          ),
        ],
      ),
      TextFormField(
        controller: c['chassis'],
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(labelText: 'رقم الشاصي VIN'),
      ),
      const _FormHeading('المبلغ بالدينار العراقي'),
      TextFormField(
        controller: c['total'],
        validator: requiredField,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'بدل البيع الإجمالي *'),
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: c['received'],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ المقبوض'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: c['remaining'],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ المتبقي'),
            ),
          ),
        ],
      ),
      TextFormField(
        controller: c['notes'],
        maxLines: 3,
        decoration: const InputDecoration(labelText: 'الشروط والملاحظات'),
      ),
    ],
  );
}

class _FormHeading extends StatelessWidget {
  const _FormHeading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleMedium);
}

Map<String, TextEditingController> _makeControllers(
  Map<String, String> source,
  List<String> fields,
) => <String, TextEditingController>{
  for (final field in fields)
    field: TextEditingController(text: source[field] ?? ''),
};

void _disposeControllers(Map<String, TextEditingController> controllers) {
  for (final controller in controllers.values) {
    controller.dispose();
  }
}

String _shortDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String contractText(Map<String, String> item, Map<String, String> settings) =>
    '''
${settings['showroomName'] ?? 'زيد لتجارة السيارات'}
عقد بيع سيارة رقم: ${item['number'] ?? ''}
التاريخ: ${item['date'] ?? ''}

المالك الشرعي: ${item['legalOwner'] ?? ''}
سكن المالك: ${item['legalOwnerAddress'] ?? ''}

الطرف الأول (البائع): ${item['sellerName'] ?? ''}
الهوية: ${item['sellerId'] ?? ''}    المهنة: ${item['sellerJob'] ?? ''}
العنوان والهاتف: ${item['sellerContact'] ?? ''}

الطرف الثاني (المشتري): ${item['buyerName'] ?? ''}
الهوية: ${item['buyerId'] ?? ''}    المهنة: ${item['buyerJob'] ?? ''}
العنوان والهاتف: ${item['buyerContact'] ?? ''}

السيارة: ${item['car'] ?? ''}
رقم السيارة: ${item['plate'] ?? ''}    الاستخدام: ${item['usage'] ?? ''}
الموديل: ${item['model'] ?? ''}    اللون: ${item['color'] ?? ''}
رقم الشاصي: ${item['chassis'] ?? ''}

بدل البيع: ${item['total'] ?? ''} دينار عراقي
المقبوض: ${item['received'] ?? ''} دينار عراقي
المتبقي: ${item['remaining'] ?? ''} دينار عراقي

الشروط والملاحظات:
${item['notes'] ?? ''}

توقيع البائع: ____________________
توقيع المشتري: ____________________
''';
