import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class AdvancedAutomationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Otomatik görev oluşturma
  Future<void> createAutomatedTask({
    required String title,
    required String description,
    required String assignedTo,
    required TaskPriority priority,
    required TaskType type,
    required DateTime dueDate,
    String? customerId,
    String? applicationId,
  }) async {
    try {
      // TaskModel imzasında olmayan alanları kaldır (attachments, notes) ve zorunlu alanları sağla
      final task = TaskModel(
        id: '',
        title: title,
        description: description,
        assignedTo: assignedTo,
        priority: priority,
        status: TaskStatus.beklemede,
        type: type,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        customerId: customerId,
        applicationId: applicationId,
        tags: const [],
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('tasks').add(task.toFirestore());
    } catch (e) {
      print('Otomatik görev oluşturma hatası: $e');
    }
  }

  // İş akışı otomasyonu çalıştırma
  Future<void> executeWorkflowAutomation({
    required String workflowId,
    required Map<String, dynamic> triggerData,
  }) async {
    try {
      // İş akışı adımlarını çalıştır
      await _executeCreateTaskStep(workflowId, triggerData);
      await _executeSendEmailStep(workflowId, triggerData);
      await _executeSendSmsStep(workflowId, triggerData);
      await _executeUpdateStatusStep(workflowId, triggerData);
      await _executeCreateApprovalStep(workflowId, triggerData);
      await _executeWaitStep(workflowId, triggerData);

      // İş akışı logunu kaydet
      await _logWorkflowStep(workflowId, 'completed', triggerData);
    } catch (e) {
      print('İş akışı otomasyonu hatası: $e');
      await _logWorkflowStep(workflowId, 'error', triggerData, error: e.toString());
    }
  }

  Future<void> _executeCreateTaskStep(String workflowId, Map<String, dynamic> data) async {
    // Görev oluşturma adımı
    print('Görev oluşturma adımı çalıştırılıyor...');
  }

  Future<void> _executeSendEmailStep(String workflowId, Map<String, dynamic> data) async {
    // E-posta gönderme adımı
    print('E-posta gönderme adımı çalıştırılıyor...');
  }

  Future<void> _executeSendSmsStep(String workflowId, Map<String, dynamic> data) async {
    // SMS gönderme adımı
    print('SMS gönderme adımı çalıştırılıyor...');
  }

  Future<void> _executeUpdateStatusStep(String workflowId, Map<String, dynamic> data) async {
    // Durum güncelleme adımı
    print('Durum güncelleme adımı çalıştırılıyor...');
  }

  Future<void> _executeCreateApprovalStep(String workflowId, Map<String, dynamic> data) async {
    // Onay oluşturma adımı
    print('Onay oluşturma adımı çalıştırılıyor...');
  }

  Future<void> _executeWaitStep(String workflowId, Map<String, dynamic> data) async {
    // Bekleme adımı
    print('Bekleme adımı çalıştırılıyor...');
  }

  Future<void> _logWorkflowStep(String workflowId, String status, Map<String, dynamic> data, {String? error}) async {
    await _firestore.collection('workflow_logs').add({
      'workflowId': workflowId,
      'status': status,
      'data': data,
      'error': error,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Zamanlayıcı otomasyonları çalıştırma
  Future<void> executeScheduledAutomations() async {
    try {
      final snapshot = await _firestore
          .collection('scheduled_automations')
          .where('nextRun', isLessThanOrEqualTo: DateTime.now())
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        await _executeScheduledAutomation(doc.id, data);
        
        // Sonraki çalışma zamanını hesapla
        final nextRun = _calculateNextRun(data);
        await doc.reference.update({'nextRun': nextRun});
      }
    } catch (e) {
      print('Zamanlayıcı otomasyon hatası: $e');
    }
  }

  Future<void> _executeScheduledAutomation(String automationId, Map<String, dynamic> data) async {
    print('Zamanlayıcı otomasyon çalıştırılıyor: $automationId');
    // Otomasyon mantığı burada
  }

  DateTime _calculateNextRun(Map<String, dynamic> data) {
    final frequency = data['frequency'] ?? 'daily';
    final lastRun = (data['lastRun'] as Timestamp?)?.toDate() ?? DateTime.now();
    
    switch (frequency) {
      case 'hourly':
        return lastRun.add(Duration(hours: 1));
      case 'daily':
        return lastRun.add(Duration(days: 1));
      case 'weekly':
        return lastRun.add(Duration(days: 7));
      case 'monthly':
        return DateTime(lastRun.year, lastRun.month + 1, lastRun.day);
      default:
        return lastRun.add(Duration(days: 1));
    }
  }

  // Koşullu otomasyon çalıştırma
  Future<void> executeConditionalAutomation({
    required String automationId,
    required Map<String, dynamic> conditionData,
  }) async {
    try {
      final doc = await _firestore.collection('conditional_automations').doc(automationId).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final conditions = data['conditions'] as List<dynamic>;
      
      bool allConditionsMet = true;
      for (var condition in conditions) {
        if (!_evaluateCondition(condition, conditionData)) {
          allConditionsMet = false;
          break;
        }
      }

      if (allConditionsMet) {
        await _executeConditionalAction(data['actions'], conditionData);
      }
    } catch (e) {
      print('Koşullu otomasyon hatası: $e');
    }
  }

  bool _evaluateCondition(Map<String, dynamic> condition, Map<String, dynamic> data) {
    final type = condition['type'];
    final field = condition['field'];
    final value = condition['value'];
    
    switch (type) {
      case 'field_equals':
        return data[field] == value;
      case 'field_contains':
        return data[field]?.toString().contains(value.toString()) ?? false;
      case 'field_greater_than':
        return (data[field] ?? 0) > value;
      case 'field_less_than':
        return (data[field] ?? 0) < value;
      case 'date_between':
        final date = data[field];
        if (date is DateTime) {
          final start = DateTime.parse(condition['startDate']);
          final end = DateTime.parse(condition['endDate']);
          return date.isAfter(start) && date.isBefore(end);
        }
        return false;
      case 'user_role':
        return data['userRole'] == value;
      case 'custom_query':
        // Özel sorgu mantığı
        return true;
      default:
        return false;
    }
  }

  Future<void> _executeConditionalAction(List<dynamic> actions, Map<String, dynamic> data) async {
    for (var action in actions) {
      final type = action['type'];
      
      switch (type) {
        case 'create_task':
          await createAutomatedTask(
            title: _processTemplate(action['title'], data),
            description: _processTemplate(action['description'], data),
            assignedTo: action['assignedTo'],
            priority: TaskPriority.values.firstWhere((e) => e.name == action['priority']),
            // Bazı konfigurasyonlarda 'taskType' anahtarı kullanılabiliyor; geriye dönük uyumluluk
            type: TaskType.values.firstWhere((e) => e.name == (action['taskType'] ?? action['type'])),
            dueDate: DateTime.parse(action['dueDate']),
            customerId: data['customerId'],
            applicationId: data['applicationId'],
          );
          break;
        case 'send_email':
          // E-posta gönderme
          break;
        case 'send_sms':
          // SMS gönderme
          break;
        case 'update_status':
          // Durum güncelleme
          break;
      }
    }
  }

  String _processTemplate(String template, Map<String, dynamic> data) {
    String result = template;
    data.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value.toString());
    });
    return result;
  }
}
