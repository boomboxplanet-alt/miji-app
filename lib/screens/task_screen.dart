import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/reward_claim_dialog.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: AppBar(
              title: const Row(
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    '任務中心',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: '關閉',
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Container(
                  height: 48,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: const Color(0xFF6366F1),
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                    dividerColor: Colors.transparent,
                    indicatorPadding: const EdgeInsets.all(4),
                    labelPadding: EdgeInsets.zero,
                    isScrollable: false,
                    tabs: const [
                      Tab(
                        height: 40,
                        child: Center(
                          child: Text(
                            '每日任務',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Tab(
                        height: 40,
                        child: Center(
                          child: Text(
                            '每週任務',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Tab(
                        height: 40,
                        child: Center(
                          child: Text(
                            '成就',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // 獎勵狀態卡片
            Flexible(
              flex: 0,
              child: _buildRewardStatusCard(),
            ),

            // 任務列表
            Expanded(
              flex: 1,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(TaskType.daily),
                  _buildTaskList(TaskType.weekly),
                  _buildTaskList(TaskType.achievement),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardStatusCard() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '我的獎勵',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            taskProvider.getBonusDescription(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (taskProvider.hasNewRewards)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${taskProvider.claimableTasks.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (taskProvider.hasNewRewards) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.1),
                          const Color(0xFF059669).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.celebration,
                              color: Color(0xFF10B981),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '有 ${taskProvider.claimableTasks.length} 個任務獎勵可以領取！',
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final claimableTasks =
                                  taskProvider.claimableTasks;
                              if (claimableTasks.isNotEmpty &&
                                  context.mounted) {
                                // 顯示第一個任務的獎勵彈窗
                                await _showRewardDialog(claimableTasks.first);

                                // 如果還有更多任務，繼續顯示
                                for (int i = 1;
                                    i < claimableTasks.length;
                                    i++) {
                                  if (context.mounted) {
                                    await Future.delayed(
                                        const Duration(milliseconds: 500));
                                    await _showRewardDialog(claimableTasks[i]);
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              minimumSize: const Size(0, 40),
                            ),
                            child: const Text(
                              '立即領取所有獎勵',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.3,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskList(TaskType type) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.getTasksByType(type);

        if (tasks.isEmpty) {
          return SingleChildScrollView(
            child: SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 48,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '暫無${_getTypeDisplayName(type)}任務',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return _buildTaskCard(tasks[index]);
          },
        );
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: task.isCompleted
              ? null
              : () {
                  // 處理任務點擊
                },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 第一行：圖標 + 任務標題
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: task.isCompleted
                                  ? [
                                      const Color(0xFF10B981),
                                      const Color(0xFF059669)
                                    ]
                                  : [
                                      const Color(0xFF6366F1),
                                      const Color(0xFF8B5CF6)
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            task.isCompleted
                                ? Icons.check_rounded
                                : _getTaskIconData(task.type),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: task.isCompleted
                                  ? Colors.grey.shade600
                                  : const Color(0xFF1F2937),
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              letterSpacing: 0.2,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 第二行：任務內容
                    Padding(
                      padding: const EdgeInsets.only(left: 52),
                      child: Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: task.isCompleted
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          letterSpacing: 0.1,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 第三行：任務獎勵
                    if (!task.isCompleted)
                      Padding(
                        padding: const EdgeInsets.only(left: 52),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task.reward.description,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6366F1),
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    // 進度條
                    Padding(
                      padding: const EdgeInsets.only(left: 52, right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '進度',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${task.currentCount}/${task.targetCount}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: task.isCompleted
                                      ? const Color(0xFF10B981)
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: task.progress,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  task.isCompleted
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF6366F1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!task.isCompleted) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: task.progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF6366F1)),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(task.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                          letterSpacing: 0.3,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _formatDeadline(task.deadline ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                              height: 1.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTaskIconData(TaskType type) {
    switch (type) {
      case TaskType.daily:
        return Icons.today;
      case TaskType.weekly:
        return Icons.calendar_view_week;
      case TaskType.achievement:
        return Icons.emoji_events;
    }
  }

  String _getTypeDisplayName(TaskType type) {
    switch (type) {
      case TaskType.daily:
        return '每日';
      case TaskType.weekly:
        return '每週';
      case TaskType.achievement:
        return '成就';
    }
  }

  // 顯示獎勵領取彈窗
  Future<void> _showRewardDialog(Task task) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RewardClaimDialog(
        task: task,
        onClaimed: () async {
          // 領取獎勵
          await taskProvider.claimTaskReward(task.id);
        },
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return '已過期';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天後';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小時後';
    } else {
      return '${difference.inMinutes}分鐘後';
    }
  }
}
