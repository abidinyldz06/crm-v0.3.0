import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Tüm görevleri getir
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Görevleri getirme hatası: $e');
      return [];
    }
  }

  // Kullanıcının görevlerini getir
  Future<List<TaskModel>> getUserTasks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('assignedTo', isEqualTo: userId)
          .orderBy('dueDate')
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Kullanıcı görevlerini getirme hatası: $e');
      return [];
    }
  }

  // Müşteriye ait görevleri getir
  Future<List<TaskModel>> getCustomerTasks(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('customerId', isEqualTo: customerId)
          .orderBy('dueDate')
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Müşteri görevlerini getirme hatası: $e');
      return [];
    }
  }

  // Başvuruya ait görevleri getir
  Future<List<TaskModel>> getApplicationTasks(String applicationId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('applicationId', isEqualTo: applicationId)
          .orderBy('dueDate')
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Başvuru görevlerini getirme hatası: $e');
      return [];
    }
  }

  // Duruma göre görevleri getir
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('status', isEqualTo: status.name)
          .orderBy('dueDate')
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Durum görevlerini getirme hatası: $e');
      return [];
    }
  }

  // Önceliğe göre görevleri getir
  Future<List<TaskModel>> getTasksByPriority(TaskPriority priority) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('priority', isEqualTo: priority.name)
          .orderBy('dueDate')
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Öncelik görevlerini getirme hatası: $e');
      return [];
    }
  }

  // Geciken görevleri getir
  Future<List<TaskModel>> getOverdueTasks() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('tasks')
          .where('dueDate', isLessThan: Timestamp.fromDate(now))
          .where('status', whereIn: ['beklemede', 'devamEdiyor'])
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Geciken görevleri getirme hatası: $e');
      return [];
    }
  }

  // Bugün yapılacak görevleri getir
  Future<List<TaskModel>> getTodayTasks() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('tasks')
          .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dueDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Bugünkü görevleri getirme hatası: $e');
      return [];
    }
  }

  // Yaklaşan görevleri getir (3 gün içinde)
  Future<List<TaskModel>> getUpcomingTasks() async {
    try {
      final now = DateTime.now();
      final threeDaysLater = now.add(const Duration(days: 3));

      final snapshot = await _firestore
          .collection('tasks')
          .where('dueDate', isGreaterThan: Timestamp.fromDate(now))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(threeDaysLater))
          .where('status', whereIn: ['beklemede', 'devamEdiyor'])
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Yaklaşan görevleri getirme hatası: $e');
      return [];
    }
  }

  // Yeni görev oluştur
  Future<void> createTask(TaskModel task) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final taskWithUser = task.copyWith(
        assignedBy: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('tasks').add(taskWithUser.toFirestore());
      print('Görev oluşturuldu: ${task.title}');
    } catch (e) {
      print('Görev oluşturma hatası: $e');
      rethrow;
    }
  }

  // Görev güncelle
  Future<void> updateTask(TaskModel task) async {
    try {
      final updatedTask = task.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('tasks')
          .doc(task.id)
          .update(updatedTask.toFirestore());

      print('Görev güncellendi: ${task.title}');
    } catch (e) {
      print('Görev güncelleme hatası: $e');
      rethrow;
    }
  }

  // Görev durumunu güncelle
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .update({
        'status': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('Görev durumu güncellendi: $taskId -> ${status.displayName}');
    } catch (e) {
      print('Görev durumu güncelleme hatası: $e');
      rethrow;
    }
  }

  // Görev sil
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      print('Görev silindi: $taskId');
    } catch (e) {
      print('Görev silme hatası: $e');
      rethrow;
    }
  }

  // Görev istatistiklerini getir
  Future<Map<String, dynamic>> getTaskStats() async {
    try {
      final snapshot = await _firestore.collection('tasks').get();
      final tasks = snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();

      final totalTasks = tasks.length;
      final completedTasks = tasks.where((task) => task.status == TaskStatus.tamamlandi).length;
      final pendingTasks = tasks.where((task) => task.status == TaskStatus.beklemede).length;
      final inProgressTasks = tasks.where((task) => task.status == TaskStatus.devamEdiyor).length;
      final overdueTasks = tasks.where((task) => task.isOverdue).length;
      final todayTasks = tasks.where((task) => task.isDueToday).length;

      // Öncelik dağılımı
      final highPriorityTasks = tasks.where((task) => task.priority == TaskPriority.yuksek || task.priority == TaskPriority.kritik).length;
      final automatedTasks = tasks.where((task) => task.isAutomated).length;

      return {
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'pendingTasks': pendingTasks,
        'inProgressTasks': inProgressTasks,
        'overdueTasks': overdueTasks,
        'todayTasks': todayTasks,
        'highPriorityTasks': highPriorityTasks,
        'automatedTasks': automatedTasks,
        'completionRate': totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0,
      };
    } catch (e) {
      print('Görev istatistikleri getirme hatası: $e');
      return {
        'totalTasks': 0,
        'completedTasks': 0,
        'pendingTasks': 0,
        'inProgressTasks': 0,
        'overdueTasks': 0,
        'todayTasks': 0,
        'highPriorityTasks': 0,
        'automatedTasks': 0,
        'completionRate': 0,
      };
    }
  }

  // Kullanıcı görev istatistiklerini getir
  Future<Map<String, dynamic>> getUserTaskStats(String userId) async {
    try {
      final userTasks = await getUserTasks(userId);
      
      final totalTasks = userTasks.length;
      final completedTasks = userTasks.where((task) => task.status == TaskStatus.tamamlandi).length;
      final pendingTasks = userTasks.where((task) => task.status == TaskStatus.beklemede).length;
      final inProgressTasks = userTasks.where((task) => task.status == TaskStatus.devamEdiyor).length;
      final overdueTasks = userTasks.where((task) => task.isOverdue).length;
      final todayTasks = userTasks.where((task) => task.isDueToday).length;

      return {
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'pendingTasks': pendingTasks,
        'inProgressTasks': inProgressTasks,
        'overdueTasks': overdueTasks,
        'todayTasks': todayTasks,
        'completionRate': totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0,
      };
    } catch (e) {
      print('Kullanıcı görev istatistikleri getirme hatası: $e');
      return {
        'totalTasks': 0,
        'completedTasks': 0,
        'pendingTasks': 0,
        'inProgressTasks': 0,
        'overdueTasks': 0,
        'todayTasks': 0,
        'completionRate': 0,
      };
    }
  }

  // Görev arama
  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .orderBy('title')
          .get();

      final tasks = snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
      
      return tasks.where((task) {
        final searchQuery = query.toLowerCase();
        return task.title.toLowerCase().contains(searchQuery) ||
               task.description.toLowerCase().contains(searchQuery) ||
               task.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
      }).toList();
    } catch (e) {
      print('Görev arama hatası: $e');
      return [];
    }
  }

  // Görev etiketlerini getir
  Future<List<String>> getAllTaskTags() async {
    try {
      final snapshot = await _firestore.collection('tasks').get();
      final tasks = snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
      
      final allTags = <String>{};
      for (final task in tasks) {
        allTags.addAll(task.tags);
      }
      
      return allTags.toList()..sort();
    } catch (e) {
      print('Görev etiketleri getirme hatası: $e');
      return [];
    }
  }

  // Etikete göre görevleri getir
  Future<List<TaskModel>> getTasksByTag(String tag) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('tags', arrayContains: tag)
          .orderBy('dueDate')
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Etiket görevlerini getirme hatası: $e');
      return [];
    }
  }
} 