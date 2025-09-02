enum TaskType {
  daily,    // 每日任務
  weekly,   // 每週任務
  achievement, // 成就任務
}

enum TaskStatus {
  available,  // 可執行
  inProgress, // 進行中
  completed,  // 已完成
  claimed,    // 已領取獎勵
}

enum RewardType {
  duration,   // 時長獎勵
  range,      // 範圍獎勵
  both,       // 時長+範圍獎勵
}

class TaskReward {
  final RewardType type;
  final int durationMinutes; // 額外時長（分鐘）
  final double rangeMeters;  // 額外範圍（米）
  final String description;

  TaskReward({
    required this.type,
    this.durationMinutes = 0,
    this.rangeMeters = 0,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'durationMinutes': durationMinutes,
      'rangeMeters': rangeMeters,
      'description': description,
    };
  }

  factory TaskReward.fromJson(Map<String, dynamic> json) {
    return TaskReward(
      type: RewardType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => RewardType.duration,
      ),
      durationMinutes: json['durationMinutes'] ?? 0,
      rangeMeters: json['rangeMeters']?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
    );
  }
  
  @override
  String toString() {
    return description;
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final TaskStatus status;
  final TaskReward reward;
  final int targetCount;     // 目標數量
  final int currentCount;    // 當前進度
  final DateTime? deadline;  // 截止時間
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? claimedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.reward,
    required this.targetCount,
    this.currentCount = 0,
    this.deadline,
    required this.createdAt,
    this.completedAt,
    this.claimedAt,
  });

  // 計算進度百分比
  double get progress => targetCount > 0 ? currentCount / targetCount : 0.0;

  // 是否已完成
  bool get isCompleted => currentCount >= targetCount;

  // 是否已過期
  bool get isExpired => deadline != null && DateTime.now().isAfter(deadline!);

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    TaskStatus? status,
    TaskReward? reward,
    int? targetCount,
    int? currentCount,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? claimedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      reward: reward ?? this.reward,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'status': status.toString(),
      'reward': reward.toJson(),
      'targetCount': targetCount,
      'currentCount': currentCount,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'claimedAt': claimedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: TaskType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => TaskType.daily,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => TaskStatus.available,
      ),
      reward: TaskReward.fromJson(json['reward']),
      targetCount: json['targetCount'],
      currentCount: json['currentCount'] ?? 0,
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      claimedAt: json['claimedAt'] != null 
          ? DateTime.parse(json['claimedAt']) 
          : null,
    );
  }
}