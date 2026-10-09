// Offline-First Sync Service for gate resilience during weak or disconnected networks

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:security_app/core/models/sync_queue.dart';
import 'package:security_app/core/data/mock_database.dart';

class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final MockDatabase _db = MockDatabase();
  final Uuid _uuid = const Uuid();

  bool get isOnline => _db.isOnline;
  SyncStatus get syncStatus => _db.syncStatus;
  int get pendingQueueCount =>
      _db.syncQueue.where((item) => item.status == SyncStatus.pending).length;

  /// Toggles simulated online/offline network connection
  void setNetworkOnline(bool online) {
    if (_db.isOnline == online) return;
    _db.isOnline = online;
    if (_db.isOnline) {
      triggerSync();
    } else {
      _db.syncStatus = SyncStatus.pending;
      notifyListeners();
    }
  }

  /// Queues an operation locally when offline or to guarantee durability
  void enqueueAction({
    required String tenantId,
    required SyncAction action,
    required String entityId,
    required Map<String, dynamic> payload,
  }) {
    final item = SyncQueueItem(
      id: 'sync_${_uuid.v4().substring(0, 8)}',
      tenantId: tenantId,
      action: action,
      entityId: entityId,
      payload: payload,
      createdAt: DateTime.now(),
      status: _db.isOnline ? SyncStatus.synced : SyncStatus.pending,
    );

    _db.syncQueue.add(item);
    notifyListeners();

    if (_db.isOnline) {
      triggerSync();
    }
  }

  /// Triggers processing of queued actions
  Future<void> triggerSync() async {
    if (!_db.isOnline) return;

    final pendingItems =
        _db.syncQueue.where((item) => item.status == SyncStatus.pending).toList();

    if (pendingItems.isEmpty) {
      _db.syncStatus = SyncStatus.synced;
      notifyListeners();
      return;
    }

    _db.syncStatus = SyncStatus.syncing;
    notifyListeners();

    // Simulate batch network synchronization
    await Future.delayed(const Duration(milliseconds: 1200));

    for (var item in pendingItems) {
      final index = _db.syncQueue.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _db.syncQueue[index] = item.copyWith(status: SyncStatus.synced);
      }
    }

    _db.syncStatus = SyncStatus.synced;
    notifyListeners();
  }
}
