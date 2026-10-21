import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/business_store.dart';
import 'home_shell.dart';

class ManagementView extends StatelessWidget {
  const ManagementView({
    required this.store,
    required this.onThemesPressed,
    required this.onMessage,
    super.key,
  });

  final BusinessStore store;
  final VoidCallback onThemesPressed;
  final ValueChanged<String> onMessage;

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _editShowroom(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => SimpleRecordDialog(
        title: 'بيانات المعرض',
        fields: const <FormFieldSpec>[
          FormFieldSpec('showroomName', 'اسم المعرض', required: true),
          FormFieldSpec(
            'showroomPhone',
            'رقم الهاتف',
            keyboard: TextInputType.phone,
          ),
          FormFieldSpec('showroomAddress', 'العنوان'),
        ],
        initial: store.settings,
      ),
    );
    if (result == null) return;
    await store.updateSettings(result);
    onMessage('تم حفظ بيانات المعرض');
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => ListView(
      key: const PageStorageKey<String>('management'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/branding/logo.jpg',
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        store.settings['showroomName'] ?? 'زيد لتجارة السيارات',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        store.settings['showroomPhone']?.isNotEmpty == true
                            ? store.settings['showroomPhone']!
                            : 'أضف رقم الهاتف والعنوان',
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => _editShowroom(context),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const AppSectionTitle(
          title: 'وحدات إدارة المعرض',
          subtitle: 'كل وحدة تفتح سجلات قابلة للإضافة والتعديل والحذف',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 10.0;
            final width = (constraints.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: <Widget>[
                ModuleTile(
                  width: width,
                  icon: Icons.groups_2_outlined,
                  title: 'العملاء',
                  count: store.customers.length,
                  onTap: () => _open(
                    context,
                    ContactPage(
                      store: store,
                      collection: 'customers',
                      title: 'العملاء',
                    ),
                  ),
                ),
                ModuleTile(
                  width: width,
                  icon: Icons.local_shipping_outlined,
                  title: 'الموردون',
                  count: store.suppliers.length,
                  onTap: () => _open(
                    context,
                    ContactPage(
                      store: store,
                      collection: 'suppliers',
                      title: 'الموردون',
                    ),
                  ),
                ),
                ModuleTile(
                  width: width,
                  icon: Icons.payments_outlined,
                  title: 'الدفعات والأقساط',
                  count: store.payments.length,
                  onTap: () => _open(context, PaymentsPage(store: store)),
                ),
                ModuleTile(
                  width: width,
                  icon: Icons.request_quote_outlined,
                  title: 'المصاريف',
                  count: store.expenses.length,
                  onTap: () => _open(
                    context,
                    EntityPage(store: store, config: EntityConfig.expenses),
                  ),
                ),
                ModuleTile(
                  width: width,
                  icon: Icons.account_balance_outlined,
                  title: 'الصندوق',
                  count: store.cashEntries.length,
                  onTap: () => _open(
                    context,
                    EntityPage(store: store, config: EntityConfig.cash),
                  ),
                ),
                ModuleTile(
                  width: width,
                  icon: Icons.query_stats_rounded,
                  title: 'الأرباح',
                  onTap: () => _open(
                    context,
                    ReportsPage(store: store, profitOnly: true),
                  ),
                ),
                ModuleTile(
                  width: width,
                  icon: Icons.task_alt_rounded,
                  title: 'المهام',
                  count: store.tasks.length,
                  onTap: () => _open(
                    context,
                    EntityPage(store: store, config: EntityConfig.tasks),
                  ),
                ),
                ModuleTile(
                  width: width,
                  icon: Icons.badge_outlined,
                  title: 'الموظفون',
                  count: store.employees.length,
                  onTap: () => _open(
                    context,
                    EntityPage(store: store, config: EntityConfig.employees),
                  ),
                ),
                ModuleTile(
                  width: width,
                  icon: Icons.bar_chart_rounded,
                  title: 'التقارير',
                  onTap: () => _open(context, ReportsPage(store: store)),
                ),
                ModuleTile(
                  width: width,
                  icon: Icons.currency_exchange_rounded,
                  title: 'تحويل العملة',
                  onTap: () => _open(context, const CurrencyPage()),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 21),
        const AppSectionTitle(
          title: 'الإعدادات والبيانات',
          subtitle: 'التخصيص والنسخ الاحتياطي والتصدير',
        ),
        const SizedBox(height: 12),
        SettingsTile(
          icon: Icons.palette_outlined,
          title: 'مظهر التطبيق',
          subtitle: 'اختر من ١٠ ثيمات عربية',
          onTap: onThemesPressed,
        ),
        SettingsTile(
          icon: Icons.storefront_outlined,
          title: 'بيانات المعرض',
          subtitle: 'الاسم والعنوان ورقم الاتصال',
          onTap: () => _editShowroom(context),
        ),
        SwitchListTile.adaptive(
          value: store.settings['notifications'] == 'true',
          onChanged: (value) =>
              store.updateSettings(<String, String>{'notifications': '$value'}),
          secondary: Icon(
            Icons.notifications_none_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text(
            'تنبيهات الاستحقاق',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: const Text('حفظ تفضيل تنبيهات الديون والمهام'),
        ),
        SettingsTile(
          icon: Icons.backup_outlined,
          title: 'النسخ الاحتياطي والاستعادة',
          subtitle: 'انسخ كل البيانات أو استعدها من نص JSON',
          onTap: () => _open(context, BackupPage(store: store)),
        ),
        SettingsTile(
          icon: Icons.table_view_outlined,
          title: 'تصدير Excel / CSV',
          subtitle: 'ينسخ جدول المبيعات والمشتريات والديون',
          onTap: () => _open(context, ExportPage(store: store)),
        ),
        SettingsTile(
          icon: Icons.lock_outline_rounded,
          title: 'الخصوصية والأمان',
          subtitle: 'البيانات محلية ولا تُرسل إلى الإنترنت',
          onTap: () => _open(context, PrivacyPage(store: store)),
        ),
        const SizedBox(height: 15),
        Center(
          child: Column(
            children: <Widget>[
              Text(
                'زيد للسيارات',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Text(
                'الإصدار 1.0.37 (Build 2037)',
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class ModuleTile extends StatelessWidget {
  const ModuleTile({
    required this.width,
    required this.icon,
    required this.title,
    required this.onTap,
    this.count,
    super.key,
  });
  final double width;
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: 90,
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 25,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    if (count != null)
                      Text(
                        '$count سجل',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 15),
      ),
    ),
  );
}

class ContactPage extends StatelessWidget {
  const ContactPage({
    required this.store,
    required this.collection,
    required this.title,
    super.key,
  });
  final BusinessStore store;
  final String collection;
  final String title;

  Future<void> _edit(BuildContext context, [Map<String, String>? item]) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => SimpleRecordDialog(
        title: item == null ? 'إضافة $title' : 'تعديل البيانات',
        initial: item,
        fields: const <FormFieldSpec>[
          FormFieldSpec('name', 'الاسم', required: true),
          FormFieldSpec('phone', 'رقم الهاتف', keyboard: TextInputType.phone),
          FormFieldSpec('address', 'العنوان'),
          FormFieldSpec('notes', 'ملاحظات', lines: 2),
        ],
      ),
    );
    if (result == null) return;
    if (item == null) {
      await store.add(collection, result);
    } else {
      await store.update(collection, item['id']!, result);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) {
      final records = store.collection(collection);
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة'),
        ),
        body: records.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(18),
                child: EmptyState(message: 'لا توجد سجلات بعد.'),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
                itemCount: records.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = records[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text((item['name'] ?? '؟').characters.first),
                      ),
                      title: Text(
                        item['name'] ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${item['phone'] ?? ''}\n${item['address'] ?? ''}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') return _edit(context, item);
                          if (await confirmDelete(
                            context,
                            item['name'] ?? 'السجل',
                          )) {
                            await store.remove(collection, item['id']!);
                          }
                        },
                        itemBuilder: (_) => const <PopupMenuEntry<String>>[
                          PopupMenuItem(value: 'edit', child: Text('تعديل')),
                          PopupMenuItem(value: 'delete', child: Text('حذف')),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );
    },
  );
}

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({required this.store, super.key});
  final BusinessStore store;

  Future<void> _add(BuildContext context) async {
    if (store.debts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف ديناً أولاً من الحسابات')),
      );
      return;
    }
    String debtId = store.debts.first['id']!;
    final amount = TextEditingController();
    final note = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تسجيل دفعة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField<String>(
                initialValue: debtId,
                decoration: const InputDecoration(labelText: 'حساب الدين'),
                items: store.debts
                    .map(
                      (item) => DropdownMenuItem(
                        value: item['id'],
                        child: Text(item['person'] ?? '-'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => debtId = value ?? debtId),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المبلغ'),
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
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
    if (saved == true && BusinessStore.parseAmount(amount.text) > 0) {
      await store.addDebtPayment(debtId, amount.text, note: note.text);
    }
    amount.dispose();
    note.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('الدفعات والأقساط')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('دفعة'),
      ),
      body: store.payments.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(18),
              child: EmptyState(message: 'لا توجد دفعات مسجلة بعد.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
              itemCount: store.payments.length,
              itemBuilder: (context, index) {
                final item = store.payments[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: Text(item['person'] ?? '-'),
                    subtitle: Text(
                      '${item['note'] ?? ''}\n${item['date'] ?? ''}',
                    ),
                    trailing: Text(
                      BusinessStore.formatAmount(
                        BusinessStore.parseAmount(item['amount']),
                      ),
                    ),
                  ),
                );
              },
            ),
    ),
  );
}

class EntityConfig {
  const EntityConfig({
    required this.collection,
    required this.title,
    required this.icon,
    required this.fields,
    required this.titleField,
    required this.subtitleField,
    this.amountField,
  });
  final String collection;
  final String title;
  final IconData icon;
  final List<FormFieldSpec> fields;
  final String titleField;
  final String subtitleField;
  final String? amountField;

  static const expenses = EntityConfig(
    collection: 'expenses',
    title: 'المصاريف',
    icon: Icons.request_quote_outlined,
    titleField: 'title',
    subtitleField: 'category',
    amountField: 'amount',
    fields: <FormFieldSpec>[
      FormFieldSpec('title', 'وصف المصروف', required: true),
      FormFieldSpec('category', 'التصنيف'),
      FormFieldSpec(
        'amount',
        'المبلغ',
        required: true,
        keyboard: TextInputType.number,
      ),
      FormFieldSpec('date', 'التاريخ'),
      FormFieldSpec('notes', 'ملاحظات', lines: 2),
    ],
  );
  static const cash = EntityConfig(
    collection: 'cashEntries',
    title: 'حركات الصندوق',
    icon: Icons.account_balance_outlined,
    titleField: 'title',
    subtitleField: 'type',
    amountField: 'amount',
    fields: <FormFieldSpec>[
      FormFieldSpec('title', 'البيان', required: true),
      FormFieldSpec('type', 'النوع: وارد أو صادر', required: true),
      FormFieldSpec(
        'amount',
        'المبلغ',
        required: true,
        keyboard: TextInputType.number,
      ),
      FormFieldSpec('date', 'التاريخ'),
      FormFieldSpec('notes', 'ملاحظات', lines: 2),
    ],
  );
  static const tasks = EntityConfig(
    collection: 'tasks',
    title: 'المهام',
    icon: Icons.task_alt_rounded,
    titleField: 'title',
    subtitleField: 'due',
    fields: <FormFieldSpec>[
      FormFieldSpec('title', 'المهمة', required: true),
      FormFieldSpec('due', 'موعد المتابعة'),
      FormFieldSpec('status', 'الحالة: مفتوحة أو مكتملة'),
      FormFieldSpec('notes', 'التفاصيل', lines: 2),
    ],
  );
  static const employees = EntityConfig(
    collection: 'employees',
    title: 'الموظفون والرواتب',
    icon: Icons.badge_outlined,
    titleField: 'name',
    subtitleField: 'role',
    amountField: 'salary',
    fields: <FormFieldSpec>[
      FormFieldSpec('name', 'اسم الموظف', required: true),
      FormFieldSpec('role', 'الوظيفة'),
      FormFieldSpec('phone', 'رقم الهاتف', keyboard: TextInputType.phone),
      FormFieldSpec('salary', 'الراتب', keyboard: TextInputType.number),
      FormFieldSpec('notes', 'ملاحظات', lines: 2),
    ],
  );
}

class EntityPage extends StatelessWidget {
  const EntityPage({required this.store, required this.config, super.key});
  final BusinessStore store;
  final EntityConfig config;

  Future<void> _edit(BuildContext context, [Map<String, String>? item]) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => SimpleRecordDialog(
        title: item == null ? 'إضافة ${config.title}' : 'تعديل السجل',
        fields: config.fields,
        initial: item,
      ),
    );
    if (result == null) return;
    if (config.collection == 'cashEntries') {
      final type = result['type']?.trim();
      if (type != 'وارد' && type != 'صادر') result['type'] = 'صادر';
    }
    if (config.collection == 'tasks' && (result['status'] ?? '').isEmpty) {
      result['status'] = 'مفتوحة';
    }
    if (item == null) {
      await store.add(config.collection, result);
    } else {
      await store.update(config.collection, item['id']!, result);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) {
      final records = store.collection(config.collection);
      return Scaffold(
        appBar: AppBar(title: Text(config.title)),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة'),
        ),
        body: records.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(18),
                child: EmptyState(message: 'لا توجد سجلات بعد.'),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final item = records[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        config.icon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        item[config.titleField] ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${item[config.subtitleField] ?? ''}\n${item['notes'] ?? ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (config.amountField != null)
                            Text(
                              BusinessStore.formatAmount(
                                BusinessStore.parseAmount(
                                  item[config.amountField],
                                ),
                              ),
                            ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') return _edit(context, item);
                              if (value == 'toggle') {
                                await store.update(
                                  config.collection,
                                  item['id']!,
                                  <String, String>{
                                    'status': item['status'] == 'مكتملة'
                                        ? 'مفتوحة'
                                        : 'مكتملة',
                                  },
                                );
                                return;
                              }
                              if (await confirmDelete(
                                context,
                                item[config.titleField] ?? 'السجل',
                              )) {
                                await store.remove(
                                  config.collection,
                                  item['id']!,
                                );
                              }
                            },
                            itemBuilder: (_) => <PopupMenuEntry<String>>[
                              if (config.collection == 'tasks')
                                const PopupMenuItem(
                                  value: 'toggle',
                                  child: Text('تبديل حالة الإنجاز'),
                                ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('تعديل'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('حذف'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );
    },
  );
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({required this.store, this.profitOnly = false, super.key});
  final BusinessStore store;
  final bool profitOnly;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: Text(profitOnly ? 'الأرباح' : 'التقارير')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          SummaryCard(
            icon: Icons.trending_up_rounded,
            title: 'إجمالي المبيعات',
            amount: BusinessStore.formatAmount(store.salesTotal),
            caption: '${store.sales.length} عملية',
          ),
          const SizedBox(height: 10),
          SummaryCard(
            icon: Icons.shopping_cart_outlined,
            title: 'إجمالي المشتريات',
            amount: BusinessStore.formatAmount(store.purchasesTotal),
            caption: '${store.purchases.length} عملية',
          ),
          const SizedBox(height: 10),
          SummaryCard(
            icon: Icons.request_quote_outlined,
            title: 'إجمالي المصاريف',
            amount: BusinessStore.formatAmount(store.expensesTotal),
            caption: '${store.expenses.length} مصروف',
          ),
          const SizedBox(height: 10),
          SummaryCard(
            icon: Icons.query_stats_rounded,
            title: 'الربح التقديري',
            amount: BusinessStore.formatAmount(store.estimatedProfit),
            caption: 'المبيعات ناقص المشتريات والمصاريف',
          ),
          if (!profitOnly) ...<Widget>[
            const SizedBox(height: 10),
            SummaryCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'الديون المتبقية',
              amount: BusinessStore.formatAmount(store.debtsRemaining),
              caption: '${store.debts.length} حساب',
            ),
            const SizedBox(height: 10),
            SummaryCard(
              icon: Icons.account_balance_outlined,
              title: 'رصيد الصندوق',
              amount: BusinessStore.formatAmount(store.cashBalance),
              caption: 'رصيد تقديري من جميع الحركات',
            ),
            const SizedBox(height: 18),
            Text('المخزون', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            MiniStat(
              label: 'متاحة',
              value:
                  '${store.vehicles.where((v) => v['status'] == 'متاحة').length}',
              icon: Icons.directions_car_outlined,
            ),
            MiniStat(
              label: 'محجوزة',
              value:
                  '${store.vehicles.where((v) => v['status'] == 'محجوزة').length}',
              icon: Icons.event_available_outlined,
            ),
            MiniStat(
              label: 'مباعة',
              value:
                  '${store.vehicles.where((v) => v['status'] == 'مباعة').length}',
              icon: Icons.sell_outlined,
            ),
          ],
        ],
      ),
    ),
  );
}

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});
  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  final amount = TextEditingController();
  final rate = TextEditingController(text: '1320');
  bool dollarToDinar = true;

  @override
  void dispose() {
    amount.dispose();
    rate.dispose();
    super.dispose();
  }

  double get result {
    final value = double.tryParse(amount.text.replaceAll(',', '')) ?? 0;
    final exchange = double.tryParse(rate.text.replaceAll(',', '')) ?? 0;
    if (exchange == 0) return 0;
    return dollarToDinar ? value * exchange : value / exchange;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تحويل العملة')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: <Widget>[
        SegmentedButton<bool>(
          segments: const <ButtonSegment<bool>>[
            ButtonSegment(value: true, label: Text('دولار ← دينار')),
            ButtonSegment(value: false, label: Text('دينار ← دولار')),
          ],
          selected: <bool>{dollarToDinar},
          onSelectionChanged: (value) =>
              setState(() => dollarToDinar = value.first),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: amount,
          onChanged: (_) => setState(() {}),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: dollarToDinar ? 'المبلغ بالدولار' : 'المبلغ بالدينار',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: rate,
          onChanged: (_) => setState(() {}),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'سعر الدولار بالدينار'),
        ),
        const SizedBox(height: 18),
        SummaryCard(
          icon: Icons.currency_exchange_rounded,
          title: 'النتيجة',
          amount: dollarToDinar
              ? '${result.toStringAsFixed(0)} د.ع'
              : '${result.toStringAsFixed(2)} USD',
          caption: 'يمكنك تغيير سعر الصرف حسب السوق',
        ),
      ],
    ),
  );
}

class BackupPage extends StatefulWidget {
  const BackupPage({required this.store, super.key});
  final BusinessStore store;
  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final restore = TextEditingController();

  @override
  void dispose() {
    restore.dispose();
    super.dispose();
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('النسخ الاحتياطي والاستعادة')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: <Widget>[
        const EmptyState(
          message: 'النسخة الاحتياطية تشمل السيارات والمبيعات والمشتريات والديون والعقود وكل الوحدات.',
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: widget.store.exportJson()),
            );
            _message(
              'تم نسخ النسخة الاحتياطية. احفظ النص في ملف أو رسالة خاصة.',
            );
          },
          icon: const Icon(Icons.copy_all_outlined),
          label: const Text('نسخ النسخة الاحتياطية'),
        ),
        const SizedBox(height: 22),
        Text('استعادة نسخة', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        TextField(
          controller: restore,
          minLines: 5,
          maxLines: 10,
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(labelText: 'الصق نص JSON هنا'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () async {
            try {
              await widget.store.restoreJson(restore.text.trim());
              _message('تمت استعادة جميع البيانات بنجاح');
            } on Object {
              _message('تعذر الاستعادة: النص غير صحيح أو غير مكتمل');
            }
          },
          icon: const Icon(Icons.restore_rounded),
          label: const Text('استعادة البيانات'),
        ),
      ],
    ),
  );
}

class ExportPage extends StatelessWidget {
  const ExportPage({required this.store, super.key});
  final BusinessStore store;

  @override
  Widget build(BuildContext context) {
    final csv = store.exportCsv();
    return Scaffold(
      appBar: AppBar(title: const Text('تصدير Excel / CSV')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          const EmptyState(
            message: 'انسخ الجدول ثم الصقه في Excel أو Google Sheets. الترميز يدعم العربية.',
            icon: Icons.table_view_outlined,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: csv));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ جدول CSV')),
                );
              }
            },
            icon: const Icon(Icons.copy_all_outlined),
            label: const Text('نسخ جدول CSV'),
          ),
          const SizedBox(height: 14),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(csv, maxLines: 16, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({required this.store, super.key});
  final BusinessStore store;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('الخصوصية والأمان')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          const EmptyState(
            message: 'كل بيانات المعرض محفوظة داخل الهاتف باستخدام التخزين المحلي، ولا يرسل التطبيق بيانات العملاء إلى خادم خارجي.',
            icon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: store.settings['appLock'] == 'true',
            onChanged: (value) =>
                store.updateSettings(<String, String>{'appLock': '$value'}),
            title: const Text('طلب قفل الجهاز عند فتح البيانات'),
            subtitle: const Text(
              'يحفظ التفضيل استعداداً لربط البصمة في تحديث لاحق',
            ),
          ),
          const SizedBox(height: 25),
          OutlinedButton.icon(
            onPressed: () async {
              if (!await confirmDelete(context, 'جميع بيانات التطبيق')) return;
              await store.clearAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم مسح جميع السجلات')),
                );
              }
            },
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('مسح جميع السجلات'),
          ),
        ],
      ),
    ),
  );
}

class FormFieldSpec {
  const FormFieldSpec(
    this.keyName,
    this.label, {
    this.required = false,
    this.keyboard,
    this.lines = 1,
  });
  final String keyName;
  final String label;
  final bool required;
  final TextInputType? keyboard;
  final int lines;
}

class SimpleRecordDialog extends StatefulWidget {
  const SimpleRecordDialog({
    required this.title,
    required this.fields,
    this.initial,
    super.key,
  });
  final String title;
  final List<FormFieldSpec> fields;
  final Map<String, String>? initial;

  @override
  State<SimpleRecordDialog> createState() => _SimpleRecordDialogState();
}

class _SimpleRecordDialogState extends State<SimpleRecordDialog> {
  final key = GlobalKey<FormState>();
  late final Map<String, TextEditingController> controllers =
      <String, TextEditingController>{
        for (final field in widget.fields)
          field.keyName: TextEditingController(
            text: widget.initial?[field.keyName] ?? '',
          ),
      };

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: double.maxFinite,
      child: Form(
        key: key,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.fields
                .map(
                  (field) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      controller: controllers[field.keyName],
                      keyboardType: field.keyboard,
                      minLines: field.lines,
                      maxLines: field.lines,
                      validator: field.required
                          ? (value) => value == null || value.trim().isEmpty
                                ? 'هذا الحقل مطلوب'
                                : null
                          : null,
                      decoration: InputDecoration(
                        labelText:
                            '${field.label}${field.required ? ' *' : ''}',
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(
        onPressed: () {
          if (!key.currentState!.validate()) return;
          Navigator.pop(context, <String, String>{
            for (final entry in controllers.entries)
              entry.key: entry.value.text.trim(),
          });
        },
        child: const Text('حفظ'),
      ),
    ],
  );
}
