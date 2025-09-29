# 秘跡 Miji v1.6 (2025-09-15)

## 新增
- 自訂圖示方案改回原生 Material Icons，並統一按鈕樣式（白底圓角、陰影、主題藍色圖示）。
- 新增 `lib/widgets/reliable_icon.dart`（最終未採用，保留於歷史版本備查）。

## 修正
- 修正地圖消失與圖示變成 X 的問題：
  - 還原與精簡 `web/index.html`，移除會影響 Flutter/Google Maps 的激進 CSS/JS。
  - 保留必要的結構，確保地圖與 UI 正常渲染。
- 移除右上角 DEBUG 橫幅（`debugShowCheckedModeBanner: false`）。
- 端口占用導致預覽無法開啟：改用不同埠（8081/8084）並清理多餘進程。

## 其他
- 建立桌面備份：`秘跡miji_v1.6(9.15)` 並推送 GitHub：
  - 分支：`release/v1.6-2025-09-15`
  - 標籤：`v1.6-2025-09-15`

> 注意：Google Maps Web SDK 提示 `Marker` 已被建議改為 `AdvancedMarkerElement`，後續可規劃升級。
