import 'package:flutter/material.dart';
import 'package:textify/Logic/Websocket.dart';
import 'package:textify/Widgets/MessagePreview.dart';

class RecentChatsPage extends StatefulWidget {
  const RecentChatsPage({super.key});

  @override
  State<RecentChatsPage> createState() => _RecentChatsPageState();
}

class _RecentChatsPageState extends State<RecentChatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        children: [
          _buildChatList(), // All Chats
          _buildChatList(), // Personal
          _buildChatList(), // Work
        ],
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
    return ListView(
      children: const [
        MessagePreview(
          name: "Darlene Steward",
          message: "Pls take a look at the images.",
        ),
        MessagePreview(
          name: "Fullsnack Designers",
          message: "Hello guys, we have discussed about .....",
          unreadCount: 5,
        ),
        MessagePreview(
          name: "Lee Williamson",
          message: "Yes, that’s gonna work, hopefully.",
        ),
        MessagePreview(name: "Ronald Mccoy", message: "Thanks dude 😌"),
        MessagePreview(
          name: "Albert Bell",
          message: "I’m happy this anime has such grea...",
        ),
      ],
    );
  }
}
