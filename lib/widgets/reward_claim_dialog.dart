import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/task.dart';

class RewardClaimDialog extends StatefulWidget {
  final Task task;
  final VoidCallback? onClaimed;

  const RewardClaimDialog({
    super.key,
    required this.task,
    this.onClaimed,
  });

  @override
  State<RewardClaimDialog> createState() => _RewardClaimDialogState();
}

class _RewardClaimDialogState extends State<RewardClaimDialog>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    
    // 初始化彩帶控制器
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // 初始化動畫控制器
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 設置動畫
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    

    
    // 開始動畫和效果
    _startCelebration();
  }

  void _startCelebration() async {
    // 播放音效
    try {
      // 使用內建的成功音效（模擬）
      // 在實際應用中，你可以添加音效文件到assets文件夾
      // await _audioPlayer.play(AssetSource('sounds/reward_claim.mp3'));
    } catch (e) {
      // 音效播放失敗時不影響其他功能
      // 在生產環境中可以記錄到日誌系統
    }
    
    // 開始動畫
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    
    // 延遲一點再開始彩帶
    await Future.delayed(const Duration(milliseconds: 400));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主要對話框
        Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 慶祝圖標
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // 恭喜文字
                        const Text(
                          '🎉 恭喜獲得獎勵！',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 任務標題
                        Text(
                          widget.task.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // 獎勵內容
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '獲得獎勵',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.task.reward.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 確認按鈕
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onClaimed?.call();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              '太棒了！',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // 彩帶效果
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // 向下
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
        
        // 左側彩帶
        Align(
          alignment: Alignment.centerLeft,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 0, // 向右
            maxBlastForce: 3,
            minBlastForce: 1,
            emissionFrequency: 0.03,
            numberOfParticles: 30,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.pink,
            ],
          ),
        ),
        
        // 右側彩帶
        Align(
          alignment: Alignment.centerRight,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi, // 向左
            maxBlastForce: 3,
            minBlastForce: 1,
            emissionFrequency: 0.03,
            numberOfParticles: 30,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.pink,
            ],
          ),
        ),
      ],
    );
  }
}