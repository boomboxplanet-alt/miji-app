import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get bonusDurationMinutes => _taskService.bonusDurationMinutes;
  double get bonusRangeMeters => _taskService.bonusRangeMeters;

  TaskProvider() {
    _initialize();
  }

  void _initialize() {
    _taskService.initialize();
    _taskService.tasksStream.listen((tasks) {
      print('TaskProvider received ${tasks.length} tasks');
      _tasks = tasks;
      notifyListeners();
    });
    
    // 立即獲取當前任務
    _tasks = _taskService.tasks;
    print('TaskProvider initialized with ${_tasks.length} tasks');
    notifyListeners();
  }

  // 獲取特定類型的任務
  List<Task> getTasksByType(TaskType type) {
    return _tasks.where((task) => task.type == type).toList();
  }

  // 獲取每日任務
  List<Task> get dailyTasks => getTasksByType(TaskType.daily);

  // 獲取每週任務
  List<Task> get weeklyTasks => getTasksByType(TaskType.weekly);

  // 獲取成就任務
  List<Task> get achievementTasks => getTasksByType(TaskType.achievement);

  // 獲取可領取的任務
  List<Task> get claimableTasks {
    return _tasks.where((task) => 
      task.status == TaskStatus.completed && task.claimedAt == null
    ).toList();
  }

  // 獲取已完成的任務數量（包括已領取的）
  int get completedTasksCount {
    return _tasks.where((task) => 
      task.status == TaskStatus.completed || task.status == TaskStatus.claimed
    ).length;
  }
  
  // 獲取已完成但未領取的任務數量
  int get unclaimedCompletedTasksCount {
    return _tasks.where((task) => 
      task.status == TaskStatus.completed && task.claimedAt == null
    ).length;
  }

  // 獲取總任務數量
  int get totalTasksCount => _tasks.length;

  // 更新任務進度
  void updateTaskProgress(String taskId, {int increment = 1}) {
    try {
      _taskService.updateTaskProgress(taskId, increment: increment);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '更新任務進度失敗: $e';
      notifyListeners();
    }
  }

  // 領取任務獎勵
  Future<bool> claimTaskReward(String taskId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final success = _taskService.claimTaskReward(taskId);
      _errorMessage = null;
      
      return success;
    } catch (e) {
      _errorMessage = '領取獎勵失敗: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 領取所有可領取的獎勵
  Future<int> claimAllRewards() async {
    int claimedCount = 0;
    final claimableTasks = this.claimableTasks;
    
    for (final task in claimableTasks) {
      final success = await claimTaskReward(task.id);
      if (success) {
        claimedCount++;
      }
    }
    
    return claimedCount;
  }

  // 重置每日任務
  void resetDailyTasks() {
    _taskService.resetDailyTasks();
  }

  // 重置每週任務
  void resetWeeklyTasks() {
    _taskService.resetWeeklyTasks();
  }

  // 獲取任務完成率
  double getTaskCompletionRate(TaskType type) {
    final typeTasks = getTasksByType(type);
    if (typeTasks.isEmpty) return 0.0;
    
    final completedTasks = typeTasks.where((task) => 
      task.status == TaskStatus.completed || task.status == TaskStatus.claimed
    ).length;
    
    return completedTasks / typeTasks.length;
  }

  // 獲取今日完成的任務數量
  int getTodayCompletedTasksCount() {
    final today = DateTime.now();
    return _tasks.where((task) => 
      task.completedAt != null &&
      task.completedAt!.year == today.year &&
      task.completedAt!.month == today.month &&
      task.completedAt!.day == today.day
    ).length;
  }

  // 檢查是否有新的可領取獎勵
  bool get hasNewRewards => claimableTasks.isNotEmpty;

  // 獲取總獎勵描述
  String getBonusDescription() {
    final duration = bonusDurationMinutes;
    final range = bonusRangeMeters;
    
    if (duration > 0 && range > 0) {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      String durationText = '';
      if (hours > 0) {
        durationText = '$hours小時';
        if (minutes > 0) {
          durationText += '$minutes分鐘';
        }
      } else {
        durationText = '$minutes分鐘';
      }
      return '額外時長: $durationText, 額外範圍: ${range.toInt()}米';
    } else if (duration > 0) {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      String durationText = '';
      if (hours > 0) {
        durationText = '$hours小時';
        if (minutes > 0) {
          durationText += '$minutes分鐘';
        }
      } else {
        durationText = '$minutes分鐘';
      }
      return '額外時長: $durationText';
    } else if (range > 0) {
      return '額外範圍: ${range.toInt()}米';
    } else {
      return '完成任務即可獲得獎勵';
    }
  }

  // 消耗獎勵時長
  void consumeBonusDuration(int minutes) {
    _taskService.consumeBonusDuration(minutes);
    notifyListeners();
  }

  // 消耗獎勵範圍
  void consumeBonusRange(double meters) {
    _taskService.consumeBonusRange(meters);
    notifyListeners();
  }

  // 模擬任務進度更新（用於測試）
  void simulateTaskProgress() {
    // 發送訊息任務
    updateTaskProgress('daily_mystery_messenger');
    updateTaskProgress('weekly_story_weaver');
    updateTaskProgress('achievement_first_whisper');
    
    // 查看訊息任務
    updateTaskProgress('daily_treasure_hunter');
    
    // 點讚任務
    updateTaskProgress('daily_kindness_spreader');
  }
}