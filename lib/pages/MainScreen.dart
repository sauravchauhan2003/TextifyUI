// File: RecentChatsPage.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:textify/Logic/Webrtc.dart';
import 'package:textify/Logic/Websocket.dart';
import 'package:textify/Widgets/MessagePreview.dart';
import 'package:hive/hive.dart';
import 'package:textify/Logic/message.dart';
import 'package:textify/pages/IncomingCall.dart';

class RecentChatsPage extends StatefulWidget {
  const RecentChatsPage({super.key});

  @override
  State<RecentChatsPage> createState() => _RecentChatsPageState();
}

class _RecentChatsPageState extends State<RecentChatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Message> allMessages = [];
  Map<String, Message> latestMessages = {};
  String currentUser = "";

  final List<Tab> _tabs = const [
    Tab(text: "All chats"),
    Tab(text: "Personal"),
    Tab(text: "Work"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    WebSocketService().startListening();
    WebRtcManager().connectToSignalingServer();
    WebRtcManager().onIncomingCall = _handleIncomingCall;

    SharedPreferences.getInstance().then((prefs) {
      currentUser = prefs.getString("username") ?? "";
      Hive.openBox<Message>('messages').then((box) {
        box.watch().listen((event) {
          loadMessages();
        });
        loadMessages();
      });
    });
  }

  void _handleIncomingCall(String from, String callType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => IncomingCall(
              from: from,
              callType: callType,
              onAccept:
                  () => WebRtcManager().acceptCall(callType, from, context),
              onReject:
                  () => WebRtcManager().sendMessage({
                    'type': 'end',
                    'from': from,
                    'to': '', // or current user if needed
                  }),
            ),
      ),
    );
  }

  Future<void> loadMessages() async {
    final box = await Hive.openBox<Message>('messages');
    final all = box.values.toList();
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final Map<String, Message> latest = {};
    for (var msg in all) {
      final otherUser = msg.sender == currentUser ? msg.receiver : msg.sender;
      if (!latest.containsKey(otherUser)) {
        latest[otherUser] = msg;
      }
    }

    setState(() {
      allMessages = all;
      latestMessages = latest;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Recent Chats',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          tabAlignment: TabAlignment.center,
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.black87,
          tabs: _tabs,
        ),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [_buildChatList(), _buildChatList(), _buildChatList()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    final sortedEntries =
        latestMessages.entries.toList()
          ..sort((a, b) => b.value.timestamp.compareTo(a.value.timestamp));

    return ListView.builder(
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final otherUser = entry.key;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/chat', arguments: otherUser);
          },
          child: MessagePreview(name: otherUser, message: entry.value.content),
        );
      },
    );
  }
}
