import 'dart:async';

import '../models/task.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();


  final List<Task> _tasks = [];
  final StreamController<List<Task>> _tasksController = StreamController<List<Task>>.broadcast();
  
  // 用戶獎勵狀態
  int _bonusDurationMinutes = 0; // 額外時長（分鐘）
  double _bonusRangeMeters = 0.0; // 額外範圍（米）
  
  Stream<List<Task>> get tasksStream => _tasksController.stream;
  List<Task> get tasks => List.unmodifiable(_tasks);
  int get bonusDurationMinutes => _bonusDurationMinutes;
  double get bonusRangeMeters => _bonusRangeMeters;

  // 初始化任務系統
  void initialize() {
    _generateDailyTasks();
    _generateWeeklyTasks();
    _generateAchievementTasks();
    _notifyListeners();
  }

  // 生成每日任務
  void _generateDailyTasks() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    final dailyTasks = [
      Task(
        id: 'daily_mystery_messenger',
        title: '🕵️ 神秘信使',
        description: '發送3條匿名訊息，成為今日的神秘信使',
        type: TaskType.daily,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.duration,
          durationMinutes: 45,
          description: '🎁 +45分鐘神秘時光',
        ),
        targetCount: 3,
        deadline: tomorrow,
        createdAt: now,
      ),
      Task(
        id: 'daily_treasure_hunter',
        title: '🔍 尋寶獵人',
        description: '發現並查看7條隱藏在周圍的秘密訊息',
        type: TaskType.daily,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.range,
          rangeMeters: 300,
          description: '🗺️ +300米探索範圍',
        ),
        targetCount: 7,
        deadline: tomorrow,
        createdAt: now,
      ),
      Task(
        id: 'daily_kindness_spreader',
        title: '💝 善意傳播者',
        description: '為3條訊息點讚，傳播正能量',
        type: TaskType.daily,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.both,
          durationMinutes: 20,
          rangeMeters: 150,
          description: '✨ +20分鐘時長 +150米愛心範圍',
        ),
        targetCount: 3,
        deadline: tomorrow,
        createdAt: now,
      ),
      Task(
        id: 'daily_time_capsule',
        title: '⏰ 時光膠囊',
        description: '發送一條設定為24小時後消失的特別訊息',
        type: TaskType.daily,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.duration,
          durationMinutes: 60,
          description: '🕰️ +1小時時光守護',
        ),
        targetCount: 1,
        deadline: tomorrow,
        createdAt: now,
      ),
    ];
    
    _tasks.addAll(dailyTasks);
  }

  // 生成每週任務
  void _generateWeeklyTasks() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    final weeklyTasks = [
      Task(
        id: 'weekly_secret_keeper',
        title: '🔐 秘密守護者',
        description: '連續5天保持活躍，守護城市的秘密',
        type: TaskType.weekly,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.both,
          durationMinutes: 180,
          rangeMeters: 800,
          description: '🏆 +3小時守護時光 +800米守護範圍',
        ),
        targetCount: 5,
        deadline: nextWeek,
        createdAt: now,
      ),
      Task(
        id: 'weekly_story_weaver',
        title: '📖 故事編織者',
        description: '本週發送25條充滿創意的訊息',
        type: TaskType.weekly,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.duration,
          durationMinutes: 240,
          description: '✍️ +4小時創作時光',
        ),
        targetCount: 25,
        deadline: nextWeek,
        createdAt: now,
      ),
      Task(
        id: 'weekly_connection_master',
        title: '🌐 連結大師',
        description: '與15位不同的用戶互動（點讚或回覆）',
        type: TaskType.weekly,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.both,
          durationMinutes: 120,
          rangeMeters: 600,
          description: '🤝 +2小時社交時光 +600米連結範圍',
        ),
        targetCount: 15,
        deadline: nextWeek,
        createdAt: now,
      ),
      Task(
        id: 'weekly_night_owl',
        title: '🦉 夜貓子探險',
        description: '在晚上10點後發送5條神秘夜間訊息',
        type: TaskType.weekly,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.range,
          rangeMeters: 1000,
          description: '🌙 +1000米夜間探索範圍',
        ),
        targetCount: 5,
        deadline: nextWeek,
        createdAt: now,
      ),
    ];
    
    _tasks.addAll(weeklyTasks);
  }

  // 生成成就任務
  void _generateAchievementTasks() {
    final now = DateTime.now();
    
    final achievementTasks = [
      Task(
        id: 'achievement_first_whisper',
        title: '🌟 初次低語',
        description: '發送你的第一條秘密訊息，開啟神秘之旅',
        type: TaskType.achievement,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.both,
          durationMinutes: 90,
          rangeMeters: 400,
          description: '🎊 +1.5小時新手時光 +400米探索範圍',
        ),
        targetCount: 1,
        createdAt: now,
      ),
      Task(
        id: 'achievement_beloved_storyteller',
        title: '💖 人氣說書人',
        description: '累計獲得100個點讚，成為受歡迎的故事創作者',
        type: TaskType.achievement,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.both,
          durationMinutes: 300,
          rangeMeters: 1500,
          description: '👑 +5小時創作時光 +1500米影響範圍',
        ),
        targetCount: 100,
        createdAt: now,
      ),
      Task(
        id: 'achievement_city_wanderer',
        title: '🗺️ 城市漫遊者',
        description: '在20個不同地點留下足跡，探索城市每個角落',
        type: TaskType.achievement,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.both,
          durationMinutes: 360,
          rangeMeters: 1200,
          description: '🏃‍♂️ +6小時漫遊時光 +1200米探索範圍',
        ),
        targetCount: 20,
        createdAt: now,
      ),
      Task(
        id: 'achievement_midnight_legend',
        title: '🌙 午夜傳說',
        description: '在午夜12點發送神秘訊息，成為夜間傳說',
        type: TaskType.achievement,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.both,
          durationMinutes: 180,
          rangeMeters: 2000,
          description: '🌟 +3小時午夜時光 +2000米傳說範圍',
        ),
        targetCount: 1,
        createdAt: now,
      ),
      Task(
        id: 'achievement_secret_collector',
        title: '🔍 秘密收集家',
        description: '發現並查看500條其他用戶的秘密訊息',
        type: TaskType.achievement,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.range,
          rangeMeters: 3000,
          description: '🕵️ +3000米超級探索範圍',
        ),
        targetCount: 500,
        createdAt: now,
      ),
      Task(
        id: 'achievement_time_master',
        title: '⏳ 時間大師',
        description: '成功設定並管理100條限時訊息',
        type: TaskType.achievement,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.duration,
          durationMinutes: 720,
          description: '⚡ +12小時時間掌控力',
        ),
        targetCount: 100,
        createdAt: now,
      ),
      Task(
        id: 'achievement_community_builder',
        title: '🏗️ 社群建造者',
        description: '與200位不同用戶產生互動，建立龐大社交網絡',
        type: TaskType.achievement,
        status: TaskStatus.available,
        reward: TaskReward(
          type: RewardType.both,
          durationMinutes: 600,
          rangeMeters: 2500,
          description: '🌍 +10小時社交時光 +2500米社群範圍',
        ),
        targetCount: 200,
        createdAt: now,
      ),
    ];
    
    _tasks.addAll(achievementTasks);
  }

  // 更新任務進度
  void updateTaskProgress(String taskId, {int increment = 1}) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final newCount = (task.currentCount + increment).clamp(0, task.targetCount);
      
      TaskStatus newStatus = task.status;
      DateTime? completedAt = task.completedAt;
      
      if (newCount >= task.targetCount && task.status != TaskStatus.completed) {
        newStatus = TaskStatus.completed;
        completedAt = DateTime.now();
      }
      
      _tasks[taskIndex] = task.copyWith(
        currentCount: newCount,
        status: newStatus,
        completedAt: completedAt,
      );
      
      _notifyListeners();
    }
  }

  // 領取任務獎勵
  bool claimTaskReward(String taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      
      if (task.status == TaskStatus.completed && task.claimedAt == null) {
        // 應用獎勵
        final reward = task.reward;
        _bonusDurationMinutes += reward.durationMinutes;
        _bonusRangeMeters += reward.rangeMeters;
        
        // 更新任務狀態
        _tasks[taskIndex] = task.copyWith(
          status: TaskStatus.claimed,
          claimedAt: DateTime.now(),
        );
        
        _notifyListeners();
        return true;
      }
    }
    return false;
  }

  // 獲取可領取的任務
  List<Task> getClaimableTasks() {
    return _tasks.where((task) => 
      task.status == TaskStatus.completed && task.claimedAt == null
    ).toList();
  }

  // 獲取特定類型的任務
  List<Task> getTasksByType(TaskType type) {
    return _tasks.where((task) => task.type == type).toList();
  }

  // 重置每日任務
  void resetDailyTasks() {
    _tasks.removeWhere((task) => task.type == TaskType.daily);
    _generateDailyTasks();
    _notifyListeners();
  }

  // 重置每週任務
  void resetWeeklyTasks() {
    _tasks.removeWhere((task) => task.type == TaskType.weekly);
    _generateWeeklyTasks();
    _notifyListeners();
  }

  // 獲取總獎勵時長（分鐘）
  int getTotalBonusDuration() {
    return _bonusDurationMinutes;
  }

  // 獲取總獎勵範圍（米）
  double getTotalBonusRange() {
    return _bonusRangeMeters;
  }

  // 消耗獎勵時長
  void consumeBonusDuration(int minutes) {
    _bonusDurationMinutes = (_bonusDurationMinutes - minutes).clamp(0, _bonusDurationMinutes);
  }

  // 消耗獎勵範圍
  void consumeBonusRange(double meters) {
    _bonusRangeMeters = (_bonusRangeMeters - meters).clamp(0.0, _bonusRangeMeters);
  }

  void _notifyListeners() {
    _tasksController.add(List.unmodifiable(_tasks));
  }

  void dispose() {
    _tasksController.close();
  }
}