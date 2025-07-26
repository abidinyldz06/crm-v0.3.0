import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ErrorType {
  network,
  firebase,
  validation,
  permission,
  unknown,
}

class AppError {
  final String message;
  final String? details;
  final ErrorType type;
  final String? code;

  AppError({
    required this.message,
    this.details,
    required this.type,
    this.code,
  });

  @override
  String toString() => 'AppError: $message${details != null ? ' - $details' : ''}';
}

class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();

  // Firebase hatalarını çevir
  AppError handleFirebaseError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return AppError(
            message: 'Bu işlem için yetkiniz bulunmuyor.',
            details: error.message,
            type: ErrorType.permission,
            code: error.code,
          );
        case 'not-found':
          return AppError(
            message: 'Aranan veri bulunamadı.',
            details: error.message,
            type: ErrorType.firebase,
            code: error.code,
          );
        case 'already-exists':
          return AppError(
            message: 'Bu veri zaten mevcut.',
            details: error.message,
            type: ErrorType.firebase,
            code: error.code,
          );
        case 'unavailable':
          return AppError(
            message: 'Servis şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.',
            details: error.message,
            type: ErrorType.network,
            code: error.code,
          );
        case 'deadline-exceeded':
          return AppError(
            message: 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.',
            details: error.message,
            type: ErrorType.network,
            code: error.code,
          );
        default:
          return AppError(
            message: 'Bir hata oluştu: ${error.message ?? 'Bilinmeyen hata'}',
            details: error.toString(),
            type: ErrorType.firebase,
            code: error.code,
          );
      }
    }
    
    return AppError(
      message: 'Beklenmeyen bir hata oluştu.',
      details: error.toString(),
      type: ErrorType.unknown,
    );
  }

  // Genel hata işleyici
  AppError handleError(dynamic error) {
    if (error is FirebaseException) {
      return handleFirebaseError(error);
    }
    
    if (error is AppError) {
      return error;
    }

    // Network hataları
    if (error.toString().contains('SocketException') || 
        error.toString().contains('TimeoutException')) {
      return AppError(
        message: 'İnternet bağlantınızı kontrol edin.',
        details: error.toString(),
        type: ErrorType.network,
      );
    }

    return AppError(
      message: 'Beklenmeyen bir hata oluştu.',
      details: error.toString(),
      type: ErrorType.unknown,
    );
  }

  // Kullanıcıya hata göster
  void showError(BuildContext context, dynamic error) {
    final appError = handleError(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appError.message),
        backgroundColor: _getErrorColor(appError.type),
        duration: const Duration(seconds: 4),
        action: appError.details != null
            ? SnackBarAction(
                label: 'Detay',
                textColor: Colors.white,
                onPressed: () => _showErrorDialog(context, appError),
              )
            : null,
      ),
    );
  }

  // Başarı mesajı göster
  void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Bilgi mesajı göster
  void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Hata detay dialogu
  void _showErrorDialog(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getErrorIcon(error.type), color: _getErrorColor(error.type)),
            const SizedBox(width: 8),
            const Text('Hata Detayı'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mesaj: ${error.message}'),
            if (error.code != null) ...[
              const SizedBox(height: 8),
              Text('Kod: ${error.code}'),
            ],
            if (error.details != null) ...[
              const SizedBox(height: 8),
              Text('Detay: ${error.details}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.firebase:
        return Colors.red;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.permission:
        return Colors.deepOrange;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }

  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.firebase:
        return Icons.cloud_off;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.permission:
        return Icons.lock;
      case ErrorType.unknown:
        return Icons.error;
    }
  }
}