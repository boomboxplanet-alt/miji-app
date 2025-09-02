import 'package:flutter/material.dart';

enum Gender { male, female, unknown }

class Message {
  final String id;
  final String content;
  final double latitude;
  final double longitude;
  final double radius;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isAnonymous;
  final String senderId;
  final String? senderName; // 發送者名字
  final Gender gender;
  final int viewCount;
  final int likeCount;
  final int dislikeCount;
  final List<String> viewedBy;
  final List<String> likedBy;
  final List<String> dislikedBy;
  final Color? bubbleColor; // 固定的泡泡顏色
  final String? originalLanguage; // 原始語言代碼
  final String? translatedContent; // 翻譯後的內容
  final bool isTranslated; // 是否已翻譯
  final bool isBotGenerated; // 是否為機器人生成的訊息

  Message({
    required this.id,
    required this.content,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.createdAt,
    required this.expiresAt,
    this.isAnonymous = true,
    required this.senderId,
    this.senderName,
    this.gender = Gender.unknown,
    this.viewCount = 0,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.viewedBy = const [],
    this.likedBy = const [],
    this.dislikedBy = const [],
    this.bubbleColor,
    this.originalLanguage,
    this.translatedContent,
    this.isTranslated = false,
    this.isBotGenerated = false,
  });

  Message copyWith({
    String? id,
    String? content,
    double? latitude,
    double? longitude,
    double? radius,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isAnonymous,
    String? senderId,
    String? senderName,
    Gender? gender,
    int? viewCount,
    int? likeCount,
    int? dislikeCount,
    List<String>? viewedBy,
    List<String>? likedBy,
    List<String>? dislikedBy,
    Color? bubbleColor,
    String? originalLanguage,
    String? translatedContent,
    bool? isTranslated,
    bool? isBotGenerated,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      gender: gender ?? this.gender,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      viewedBy: viewedBy ?? this.viewedBy,
       likedBy: likedBy ?? this.likedBy,
       dislikedBy: dislikedBy ?? this.dislikedBy,
       bubbleColor: bubbleColor ?? this.bubbleColor,
       originalLanguage: originalLanguage ?? this.originalLanguage,
       translatedContent: translatedContent ?? this.translatedContent,
       isTranslated: isTranslated ?? this.isTranslated,
       isBotGenerated: isBotGenerated ?? this.isBotGenerated,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      senderId: json['senderId'] as String? ?? 'unknown',
      senderName: json['senderName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isAnonymous: json['isAnonymous'] as bool? ?? true,
      gender: Gender.values.firstWhere(
        (g) => g.name == json['gender'],
        orElse: () => Gender.unknown,
      ),
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      dislikeCount: json['dislikeCount'] as int? ?? 0,
      viewedBy: List<String>.from(json['viewedBy'] ?? []),
      likedBy: List<String>.from(json['likedBy'] ?? []),
      dislikedBy: List<String>.from(json['dislikedBy'] ?? []),
      bubbleColor: json['bubbleColor'] != null ? Color(json['bubbleColor']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isAnonymous': isAnonymous,
      'senderId': senderId,
      'senderName': senderName,
      'gender': gender.name,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'viewedBy': viewedBy,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
      'bubbleColor': bubbleColor?.value,
    };
  }
}