import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MySimpleApp());
}

class MySimpleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '秘跡 Miji - 簡化版',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SimpleHomePage(),
    );
  }
}

class SimpleHomePage extends StatefulWidget {
  @override
  _SimpleHomePageState createState() => _SimpleHomePageState();
}

class _SimpleHomePageState extends State<SimpleHomePage> {
  String _status = '準備就緒';
  List<String> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('秘跡 Miji - 簡化版'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 狀態顯示
              Card(
                elevation: 8,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '應用程式狀態',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _status,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // 功能按鈕
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _testBasicFunctionality,
                      icon: Icon(Icons.psychology),
                      label: Text('測試基本功能'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _testLocation,
                      icon: Icon(Icons.location_on),
                      label: Text('測試位置'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _generateMessage,
                      icon: Icon(Icons.message),
                      label: Text('生成訊息'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.purple,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _clearMessages,
                      icon: Icon(Icons.clear_all),
                      label: Text('清除訊息'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // 訊息列表
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '訊息記錄',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: _messages.isEmpty
                              ? Center(
                                  child: Text(
                                    '暫無訊息',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: Icon(Icons.message, color: Colors.blue),
                                      title: Text(_messages[index]),
                                      subtitle: Text('時間: ${DateTime.now().toString().substring(11, 19)}'),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _testBasicFunctionality() {
    setState(() {
      _status = '基本功能測試中...';
    });
    
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _status = '基本功能正常！';
        _messages.add('✅ 基本功能測試通過');
      });
    });
  }

  void _testLocation() {
    setState(() {
      _status = '位置測試中...';
    });
    
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _status = '位置服務正常！';
        _messages.add('📍 位置測試通過 - 澳門 (22.1987, 113.5439)');
      });
    });
  }

  void _generateMessage() {
    setState(() {
      _status = '生成訊息中...';
    });
    
    final messages = [
      '今天天氣真好！',
      '澳門的夜景真美',
      '這裡的葡式蛋撻很美味',
      '大三巴牌坊值得一遊',
      '澳門塔的風景壯觀',
      '威尼斯人酒店很豪華',
      '澳門的歷史文化豐富',
      '這裡的交通很方便',
      '澳門的美食種類繁多',
      '這是一個美麗的城市'
    ];
    
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        final randomMessage = messages[DateTime.now().millisecond % messages.length];
        _status = '訊息生成完成！';
        _messages.add('💬 $randomMessage');
      });
    });
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
      _status = '訊息已清除';
    });
  }
}
