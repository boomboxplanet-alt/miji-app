// Firebase 初始化腳本
// 用於設置 秘跡miji 項目的資料庫結構

const admin = require('firebase-admin');

// 初始化 Firebase Admin SDK
const serviceAccount = {
  // 這裡需要您的 Firebase 服務帳戶密鑰
  // 從 Firebase Console > Project Settings > Service Accounts 下載
  type: "service_account",
  project_id: "viralnav-314c7",
  private_key_id: "your_private_key_id",
  private_key: "your_private_key",
  client_email: "your_client_email",
  client_id: "your_client_id",
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url: "your_client_x509_cert_url"
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'viralnav-314c7'
});

const db = admin.firestore();

// 創建系統設定
async function createSystemSettings() {
  console.log('創建系統設定...');
  
  const systemSettings = [
    {
      id: 'app_version',
      key: 'app_version',
      value: '1.0.0',
      type: 'string',
      description: '應用程式版本',
      isPublic: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: 'system'
    },
    {
      id: 'max_message_duration',
      key: 'max_message_duration',
      value: 1440, // 24小時
      type: 'number',
      description: '訊息最大持續時間(分鐘)',
      isPublic: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: 'system'
    },
    {
      id: 'max_message_radius',
      key: 'max_message_radius',
      value: 1000, // 1公里
      type: 'number',
      description: '訊息最大可見半徑(米)',
      isPublic: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: 'system'
    },
    {
      id: 'min_message_duration',
      key: 'min_message_duration',
      value: 5, // 5分鐘
      type: 'number',
      description: '訊息最小持續時間(分鐘)',
      isPublic: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: 'system'
    },
    {
      id: 'min_message_radius',
      key: 'min_message_radius',
      value: 10, // 10米
      type: 'number',
      description: '訊息最小可見半徑(米)',
      isPublic: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: 'system'
    }
  ];

  for (const setting of systemSettings) {
    await db.collection('systemSettings').doc(setting.id).set(setting);
    console.log(`✅ 創建系統設定: ${setting.key}`);
  }
}

// 創建預設任務
async function createDefaultTasks() {
  console.log('創建預設任務...');
  
  const defaultTasks = [
    {
      id: 'daily_message',
      title: '每日訊息',
      description: '發送一條訊息',
      type: 'daily',
      requirements: {
        minMessages: 1,
        minLikes: 0,
        minDuration: 0
      },
      rewards: {
        points: 10,
        badges: [],
        specialAccess: false
      },
      isActive: true,
      startDate: admin.firestore.FieldValue.serverTimestamp(),
      endDate: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {
      id: 'weekly_popular',
      title: '週度人氣王',
      description: '獲得10個點讚',
      type: 'weekly',
      requirements: {
        minMessages: 0,
        minLikes: 10,
        minDuration: 0
      },
      rewards: {
        points: 100,
        badges: ['popular'],
        specialAccess: false
      },
      isActive: true,
      startDate: admin.firestore.FieldValue.serverTimestamp(),
      endDate: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {
      id: 'message_master',
      title: '訊息大師',
      description: '發送5條訊息',
      type: 'special',
      requirements: {
        minMessages: 5,
        minLikes: 0,
        minDuration: 0
      },
      rewards: {
        points: 50,
        badges: ['master'],
        specialAccess: true
      },
      isActive: true,
      startDate: admin.firestore.FieldValue.serverTimestamp(),
      endDate: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    }
  ];

  for (const task of defaultTasks) {
    await db.collection('tasks').doc(task.id).set(task);
    console.log(`✅ 創建任務: ${task.title}`);
  }
}

// 創建安全規則
async function createSecurityRules() {
  console.log('創建安全規則...');
  
  const securityRules = `
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 用戶只能讀寫自己的資料
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 訊息規則
    match /messages/{messageId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        request.auth.uid == resource.data.authorId;
      allow update: if request.auth != null && 
        request.auth.uid == resource.data.authorId;
      allow delete: if request.auth != null && 
        request.auth.uid == resource.data.authorId;
    }
    
    // 互動規則
    match /interactions/{interactionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // 任務規則
    match /tasks/{taskId} {
      allow read: if request.auth != null;
      allow write: if false; // 只有管理員可以修改
    }
    
    // 用戶任務規則
    match /userTasks/{userTaskId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // 系統設定規則
    match /systemSettings/{settingId} {
      allow read: if resource.data.isPublic == true;
      allow write: if false; // 只有管理員可以修改
    }
    
    // 內容審核規則
    match /contentModeration/{moderationId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if false; // 只有管理員可以修改
    }
  }
}`;

  console.log('安全規則已準備好，請手動在 Firebase Console 中設置');
  console.log(securityRules);
}

// 主函數
async function main() {
  try {
    console.log('🚀 開始初始化 秘跡miji Firebase 項目...');
    
    await createSystemSettings();
    await createDefaultTasks();
    await createSecurityRules();
    
    console.log('✅ Firebase 項目初始化完成！');
    console.log('📋 下一步：');
    console.log('1. 在 Firebase Console 中設置安全規則');
    console.log('2. 啟用 Authentication');
    console.log('3. 配置 Google Sign-In');
    console.log('4. 設置 Firestore 索引');
    
  } catch (error) {
    console.error('❌ 初始化失敗:', error);
  } finally {
    process.exit(0);
  }
}

// 執行初始化
main();
