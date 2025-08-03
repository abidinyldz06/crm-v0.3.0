import 'package:flutter/material.dart';
import '../models/automation_rule_model.dart';
import '../services/automation_service.dart';
import '../services/sms_automation_service.dart';

// AppTheme sınıfını tanımlıyorum
class AppTheme {
  static const Color primaryColor = Color(0xFF0D47A1);
}

class AutomationManagementScreen extends StatefulWidget {
  const AutomationManagementScreen({Key? key}) : super(key: key);

  @override
  State<AutomationManagementScreen> createState() => _AutomationManagementScreenState();
}

class _AutomationManagementScreenState extends State<AutomationManagementScreen> {
  final AutomationService _automationService = AutomationService();
  final SmsAutomationService _smsAutomationService = SmsAutomationService();
  List<AutomationRule> _emailRules = [];
  List<AutomationRule> _smsRules = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAutomationRules();
  }

  Future<void> _loadAutomationRules() async {
    setState(() => _isLoading = true);
    try {
      final emailRules = await _automationService.getAutomationRules();
      final smsRules = await _smsAutomationService.getSmsAutomationRules();
      setState(() {
        _emailRules = emailRules;
        _smsRules = smsRules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Otomasyon kuralları yüklenirken hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Otomasyon Yönetimi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRuleDialog(context, _selectedTabIndex == 0),
            tooltip: 'Yeni Kural Ekle',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(child: _buildTabContent()),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          const Text(
            'Otomasyon Yönetimi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${_emailRules.length + _smsRules.length} toplam kural',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              index: 0,
              icon: Icons.email,
              label: 'E-posta',
              count: _emailRules.length,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              index: 1,
              icon: Icons.sms,
              label: 'SMS',
              count: _smsRules.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
    required int count,
  }) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$count kural',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildEmailRulesList();
      case 1:
        return _buildSmsRulesList();
      default:
        return _buildEmailRulesList();
    }
  }

  Widget _buildEmailRulesList() {
    if (_emailRules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.email_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Henüz e-posta otomasyon kuralı yok',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Yeni kural ekleyerek otomatik e-posta gönderimi başlatın',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _emailRules.length,
      itemBuilder: (context, index) {
        final rule = _emailRules[index];
        return _buildRuleCard(rule, isEmail: true);
      },
    );
  }

  Widget _buildSmsRulesList() {
    if (_smsRules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sms_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Henüz SMS otomasyon kuralı yok',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Yeni kural ekleyerek otomatik SMS gönderimi başlatın',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _smsRules.length,
      itemBuilder: (context, index) {
        final rule = _smsRules[index];
        return _buildRuleCard(rule, isEmail: false);
      },
    );
  }

  Widget _buildRuleCard(AutomationRule rule, {required bool isEmail}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rule.isActive ? Colors.green.shade100 : Colors.grey.shade100,
          child: Icon(
            isEmail ? Icons.email : Icons.sms,
            color: rule.isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          rule.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: rule.isActive ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rule.description,
              style: TextStyle(
                color: rule.isActive ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: rule.isActive ? Colors.green.shade100 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rule.isActive ? 'Aktif' : 'Pasif',
                    style: TextStyle(
                      fontSize: 12,
                      color: rule.isActive ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  rule.triggerType.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleRuleAction(value, rule, isEmail),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    rule.isActive ? Icons.pause : Icons.play_arrow,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(rule.isActive ? 'Duraklat' : 'Etkinleştir'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: const Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showRuleDetails(rule, isEmail),
      ),
    );
  }

  void _handleRuleAction(String action, AutomationRule rule, bool isEmail) {
    switch (action) {
      case 'edit':
        _showEditRuleDialog(context, rule, isEmail);
        break;
      case 'toggle':
        _toggleRule(rule, isEmail);
        break;
      case 'delete':
        _deleteRule(rule, isEmail);
        break;
    }
  }

  Future<void> _toggleRule(AutomationRule rule, bool isEmail) async {
    try {
      final updatedRule = rule.copyWith(isActive: !rule.isActive);
      
      if (isEmail) {
        await _automationService.updateAutomationRule(updatedRule);
      } else {
        await _smsAutomationService.updateSmsAutomationRule(updatedRule);
      }
      
      await _loadAutomationRules();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kural ${updatedRule.isActive ? 'etkinleştirildi' : 'duraklatıldı'}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _deleteRule(AutomationRule rule, bool isEmail) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kuralı Sil'),
        content: Text('"${rule.name}" kuralını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (isEmail) {
          await _automationService.deleteAutomationRule(rule.id);
        } else {
          await _smsAutomationService.deleteSmsAutomationRule(rule.id);
        }
        
        await _loadAutomationRules();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kural silindi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      }
    }
  }

  void _showAddRuleDialog(BuildContext context, bool isEmail) {
    showDialog(
      context: context,
      builder: (context) => AddAutomationRuleDialog(isEmail: isEmail),
    ).then((_) => _loadAutomationRules());
  }

  void _showEditRuleDialog(BuildContext context, AutomationRule rule, bool isEmail) {
    showDialog(
      context: context,
      builder: (context) => EditAutomationRuleDialog(rule: rule, isEmail: isEmail),
    ).then((_) => _loadAutomationRules());
  }

  void _showRuleDetails(AutomationRule rule, bool isEmail) {
    showDialog(
      context: context,
      builder: (context) => AutomationRuleDetailsDialog(rule: rule, isEmail: isEmail),
    );
  }
}

// Yeni kural ekleme dialog'u
class AddAutomationRuleDialog extends StatefulWidget {
  final bool isEmail;
  
  const AddAutomationRuleDialog({Key? key, required this.isEmail}) : super(key: key);

  @override
  State<AddAutomationRuleDialog> createState() => _AddAutomationRuleDialogState();
}

class _AddAutomationRuleDialogState extends State<AddAutomationRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  
  AutomationTriggerType _selectedTrigger = AutomationTriggerType.basvuruOlusturuldu;
  bool _isActive = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEmail ? 'Yeni E-posta Otomasyonu' : 'Yeni SMS Otomasyonu'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Kural Adı',
                  hintText: 'Örn: Hoş Geldin E-postası',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kural adı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Kuralın ne yaptığını açıklayın',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AutomationTriggerType>(
                value: _selectedTrigger,
                decoration: const InputDecoration(
                  labelText: 'Tetikleyici',
                ),
                items: AutomationTriggerType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTrigger = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (widget.isEmail) TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'E-posta Konusu',
                  hintText: 'Örn: Hoş Geldiniz!',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-posta konusu gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: widget.isEmail ? 'E-posta İçeriği' : 'SMS İçeriği',
                  hintText: widget.isEmail ? 'E-posta içeriğini yazın...' : 'SMS içeriğini yazın...',
                  alignLabelWithHint: true,
                ),
                maxLines: widget.isEmail ? 4 : 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return widget.isEmail ? 'E-posta içeriği gerekli' : 'SMS içeriği gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Aktif'),
                subtitle: const Text('Kuralı hemen etkinleştir'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveRule,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }

  Future<void> _saveRule() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final rule = AutomationRule(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        triggerType: _selectedTrigger,
        emailSubject: widget.isEmail ? _subjectController.text : '',
        emailBody: _bodyController.text,
        isActive: _isActive,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.isEmail) {
        await AutomationService().createAutomationRule(rule);
      } else {
        await SmsAutomationService().createSmsAutomationRule(rule);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Otomasyon kuralı oluşturuldu')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}

// Kural düzenleme dialog'u
class EditAutomationRuleDialog extends StatefulWidget {
  final AutomationRule rule;
  final bool isEmail;

  const EditAutomationRuleDialog({Key? key, required this.rule, required this.isEmail}) : super(key: key);

  @override
  State<EditAutomationRuleDialog> createState() => _EditAutomationRuleDialogState();
}

class _EditAutomationRuleDialogState extends State<EditAutomationRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _subjectController;
  late final TextEditingController _bodyController;
  
  late AutomationTriggerType _selectedTrigger;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rule.name);
    _descriptionController = TextEditingController(text: widget.rule.description);
    _subjectController = TextEditingController(text: widget.rule.emailSubject);
    _bodyController = TextEditingController(text: widget.rule.emailBody);
    _selectedTrigger = widget.rule.triggerType;
    _isActive = widget.rule.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Otomasyon Kuralını Düzenle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Kural Adı',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kural adı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AutomationTriggerType>(
                value: _selectedTrigger,
                decoration: const InputDecoration(
                  labelText: 'Tetikleyici',
                ),
                items: AutomationTriggerType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTrigger = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (widget.isEmail) TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'E-posta Konusu',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-posta konusu gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: widget.isEmail ? 'E-posta İçeriği' : 'SMS İçeriği',
                  alignLabelWithHint: true,
                ),
                maxLines: widget.isEmail ? 4 : 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return widget.isEmail ? 'E-posta içeriği gerekli' : 'SMS içeriği gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Aktif'),
                subtitle: const Text('Kuralı etkinleştir'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _updateRule,
          child: const Text('Güncelle'),
        ),
      ],
    );
  }

  Future<void> _updateRule() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final updatedRule = widget.rule.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        triggerType: _selectedTrigger,
        emailSubject: widget.isEmail ? _subjectController.text : widget.rule.emailSubject,
        emailBody: _bodyController.text,
        isActive: _isActive,
        updatedAt: DateTime.now(),
      );

      if (widget.isEmail) {
        await AutomationService().updateAutomationRule(updatedRule);
      } else {
        await SmsAutomationService().updateSmsAutomationRule(updatedRule);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Otomasyon kuralı güncellendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}

// Kural detayları dialog'u
class AutomationRuleDetailsDialog extends StatelessWidget {
  final AutomationRule rule;
  final bool isEmail;

  const AutomationRuleDetailsDialog({Key? key, required this.rule, required this.isEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(rule.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Açıklama', rule.description),
            _buildDetailRow('Tetikleyici', rule.triggerType.displayName),
            _buildDetailRow('Durum', rule.isActive ? 'Aktif' : 'Pasif'),
            if (isEmail) _buildDetailRow('E-posta Konusu', rule.emailSubject),
            _buildDetailRow(isEmail ? 'E-posta İçeriği' : 'SMS İçeriği', rule.emailBody),
            _buildDetailRow('Oluşturulma', _formatDate(rule.createdAt)),
            _buildDetailRow('Güncellenme', _formatDate(rule.updatedAt)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
