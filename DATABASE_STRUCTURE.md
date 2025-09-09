# 🗄️ 秘跡miji 資料庫結構設計

## 📋 項目信息
- **項目名稱**: 秘跡miji
- **項目 ID**: viralnav-314c7
- **項目編號**: 613934957452
- **API 金鑰**: AIzaSyB5EIX3h6jLAF7C_5_fsE_lOQUjTMr7J58

## 🏗️ Firestore 資料庫結構

### 1. 用戶集合 (users)
```javascript
users/{userId} {
  uid: string,                    // 用戶唯一ID
  email: string,                  // 電子郵件
  displayName: string,            // 顯示名稱
  photoURL: string,               // 頭像URL
  createdAt: timestamp,           // 創建時間
  lastLoginAt: timestamp,         // 最後登入時間
  isActive: boolean,              // 是否活躍
  preferences: {
    language: string,             // 語言偏好
    theme: string,                // 主題偏好
    notifications: boolean        // 通知設定
  },
  location: {
    latitude: number,             // 緯度
    longitude: number,            // 經度
    address: string,              // 地址
    lastUpdated: timestamp        // 最後更新時間
  }
}
```

### 2. 訊息集合 (messages)
```javascript
messages/{messageId} {
  id: string,                     // 訊息ID
  content: string,                // 訊息內容
  authorId: string,               // 作者ID
  authorName: string,             // 作者名稱
  location: {
    latitude: number,             // 緯度
    longitude: number,            // 經度
    address: string,              // 地址
    radius: number                // 可見半徑(米)
  },
  visibility: {
    startTime: timestamp,         // 開始時間
    endTime: timestamp,           // 結束時間
    isActive: boolean             // 是否活躍
  },
  settings: {
    bubbleColor: string,          // 氣泡顏色
    duration: number,             // 持續時間(分鐘)
    isAnonymous: boolean          // 是否匿名
  },
  interactions: {
    likes: number,                // 點讚數
    dislikes: number,             // 點踩數
    reports: number,              // 舉報數
    views: number                 // 瀏覽數
  },
  createdAt: timestamp,           // 創建時間
  updatedAt: timestamp,           // 更新時間
  expiresAt: timestamp            // 過期時間
}
```

### 3. 互動集合 (interactions)
```javascript
interactions/{interactionId} {
  id: string,                     // 互動ID
  messageId: string,              // 訊息ID
  userId: string,                 // 用戶ID
  type: string,                   // 類型: 'like', 'dislike', 'report', 'view'
  createdAt: timestamp,           // 創建時間
  metadata: {
    userAgent: string,            // 用戶代理
    ipAddress: string,            // IP地址
    location: {
      latitude: number,
      longitude: number
    }
  }
}
```

### 4. 任務集合 (tasks)
```javascript
tasks/{taskId} {
  id: string,                     // 任務ID
  title: string,                  // 任務標題
  description: string,            // 任務描述
  type: string,                   // 任務類型: 'daily', 'weekly', 'special'
  requirements: {
    minMessages: number,          // 最少訊息數
    minLikes: number,             // 最少點讚數
    minDuration: number           // 最少持續時間
  },
  rewards: {
    points: number,               // 獎勵積分
    badges: array,                // 獎勵徽章
    specialAccess: boolean        // 特殊權限
  },
  isActive: boolean,              // 是否活躍
  startDate: timestamp,           // 開始日期
  endDate: timestamp,             // 結束日期
  createdAt: timestamp            // 創建時間
}
```

### 5. 用戶任務集合 (userTasks)
```javascript
userTasks/{userTaskId} {
  id: string,                     // 用戶任務ID
  userId: string,                 // 用戶ID
  taskId: string,                 // 任務ID
  status: string,                 // 狀態: 'active', 'completed', 'expired'
  progress: {
    currentValue: number,         // 當前進度
    targetValue: number,          // 目標值
    percentage: number            // 完成百分比
  },
  startedAt: timestamp,           // 開始時間
  completedAt: timestamp,         // 完成時間
  claimedAt: timestamp            // 領取時間
}
```

### 6. 系統設定集合 (systemSettings)
```javascript
systemSettings/{settingId} {
  id: string,                     // 設定ID
  key: string,                    // 設定鍵
  value: any,                     // 設定值
  type: string,                   // 類型: 'string', 'number', 'boolean', 'object'
  description: string,            // 描述
  isPublic: boolean,              // 是否公開
  updatedAt: timestamp,           // 更新時間
  updatedBy: string               // 更新者
}
```

### 7. 內容審核集合 (contentModeration)
```javascript
contentModeration/{moderationId} {
  id: string,                     // 審核ID
  messageId: string,              // 訊息ID
  userId: string,                 // 舉報用戶ID
  reason: string,                 // 舉報原因
  status: string,                 // 狀態: 'pending', 'approved', 'rejected'
  moderatorId: string,            // 審核員ID
  action: string,                 // 處理動作: 'delete', 'warn', 'ignore'
  createdAt: timestamp,           // 創建時間
  resolvedAt: timestamp,          // 解決時間
  notes: string                   // 備註
}
```

## 🔐 安全規則 (Firestore Security Rules)

```javascript
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
}
```

## 📊 索引配置

### 複合索引
```javascript
// messages 集合
- location.latitude, location.longitude, createdAt
- visibility.isActive, createdAt
- authorId, createdAt
- expiresAt, visibility.isActive

// interactions 集合
- messageId, type, createdAt
- userId, type, createdAt

// userTasks 集合
- userId, status, startedAt
- taskId, status, completedAt
```

## 🚀 初始化腳本

### 1. 創建系統設定
```javascript
// 在 Firebase Console 中執行
const systemSettings = [
  {
    id: 'app_version',
    key: 'app_version',
    value: '1.0.0',
    type: 'string',
    description: '應用程式版本',
    isPublic: true
  },
  {
    id: 'max_message_duration',
    key: 'max_message_duration',
    value: 1440, // 24小時
    type: 'number',
    description: '訊息最大持續時間(分鐘)',
    isPublic: true
  },
  {
    id: 'max_message_radius',
    key: 'max_message_radius',
    value: 1000, // 1公里
    type: 'number',
    description: '訊息最大可見半徑(米)',
    isPublic: true
  }
];
```

### 2. 創建預設任務
```javascript
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
    isActive: true
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
    isActive: true
  }
];
```

## 📱 移動端配置

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyB5EIX3h6jLAF7C_5_fsE_lOQUjTMr7J58"/>
```

### iOS (ios/Runner/AppDelegate.swift)
```swift
GMSServices.provideAPIKey("AIzaSyB5EIX3h6jLAF7C_5_fsE_lOQUjTMr7J58")
```

## 🔧 部署檢查清單

- [ ] Firebase 項目已創建
- [ ] Firestore 資料庫已啟用
- [ ] Authentication 已啟用
- [ ] Google Maps API 已啟用
- [ ] 安全規則已配置
- [ ] 索引已創建
- [ ] 系統設定已初始化
- [ ] 預設任務已創建
- [ ] 移動端配置已完成
- [ ] Web 端配置已完成

## 💡 建議

1. **分階段部署**: 先部署基本功能，再逐步添加高級功能
2. **監控使用量**: 設置 Firebase 使用量警報
3. **備份策略**: 定期備份 Firestore 資料
4. **性能優化**: 根據使用情況調整索引
5. **安全審計**: 定期檢查安全規則和權限
