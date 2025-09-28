import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Supabase 儲存服務 - 替代 Firebase Storage
class SupabaseStorageService {
  static SupabaseStorageService? _instance;
  static SupabaseStorageService get instance =>
      _instance ??= SupabaseStorageService._();

  SupabaseStorageService._();

  final SupabaseService _supabaseService = SupabaseService.instance;

  /// 獲取 Supabase 客戶端
  SupabaseClient get client => _supabaseService.client;

  /// 上傳檔案
  Future<String?> uploadFile({
    required String bucketName,
    required String fileName,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) {
        print('用戶未登入，無法上傳檔案');
        return null;
      }

      // 生成唯一檔案名
      final uniqueFileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // 上傳檔案
      await client.storage
          .from(bucketName)
          .uploadBinary(uniqueFileName, fileBytes);

      // 獲取公開 URL
      final publicUrl =
          client.storage.from(bucketName).getPublicUrl(uniqueFileName);

      print('檔案上傳成功: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('上傳檔案失敗: $e');
      return null;
    }
  }

  /// 上傳圖片
  Future<String?> uploadImage({
    required String fileName,
    required Uint8List imageBytes,
  }) async {
    return uploadFile(
      bucketName: 'images',
      fileName: fileName,
      fileBytes: imageBytes,
      contentType: 'image/jpeg',
    );
  }

  /// 上傳音頻檔案
  Future<String?> uploadAudio({
    required String fileName,
    required Uint8List audioBytes,
  }) async {
    return uploadFile(
      bucketName: 'audio',
      fileName: fileName,
      fileBytes: audioBytes,
      contentType: 'audio/mpeg',
    );
  }

  /// 刪除檔案
  Future<bool> deleteFile({
    required String bucketName,
    required String fileName,
  }) async {
    try {
      await client.storage.from(bucketName).remove([fileName]);

      print('檔案刪除成功: $fileName');
      return true;
    } catch (e) {
      print('刪除檔案失敗: $e');
      return false;
    }
  }

  /// 獲取檔案列表
  Future<List<Map<String, dynamic>>> listFiles({
    required String bucketName,
    String? folder,
  }) async {
    try {
      final response =
          await client.storage.from(bucketName).list(path: folder ?? '');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('獲取檔案列表失敗: $e');
      return [];
    }
  }

  /// 上傳用戶頭像
  Future<String?> uploadUserAvatar({
    required Uint8List imageBytes,
  }) async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) {
        print('用戶未登入，無法上傳頭像');
        return null;
      }

      final fileName =
          'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      return await uploadFile(
        bucketName: 'user-avatars',
        fileName: fileName,
        fileBytes: imageBytes,
        contentType: 'image/jpeg',
      );
    } catch (e) {
      print('上傳用戶頭像失敗: $e');
      return null;
    }
  }

  /// 獲取檔案下載 URL
  Future<String?> getDownloadUrl({
    required String bucketName,
    required String fileName,
    int expiresIn = 3600, // 1 小時
  }) async {
    try {
      final response = await client.storage
          .from(bucketName)
          .createSignedUrl(fileName, expiresIn);

      return response;
    } catch (e) {
      print('獲取下載 URL 失敗: $e');
      return null;
    }
  }
}
