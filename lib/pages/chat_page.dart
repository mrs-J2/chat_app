// lib/pages/chat_page.dart
import '../components/my_textfield.dart';
import '../models/message.dart';
import '../models/user_model.dart';
import '../services/auth/auth_service.dart';
import '../services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class ChatPage extends StatefulWidget {
  final String recieverEmail;
  final String recieverID;
  final String recieverUsername;

  const ChatPage({
    super.key,
    required this.recieverEmail,
    required this.recieverID,
    required this.recieverUsername,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  String? _recieverProfilePic;
  UserModel? _receiverUser;
  bool _isReceiverOnline = false;
  String _lastSeenText = "Loading...";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadReceiverData();
    _listenToMessagesAndMarkSeen();
    _authService.setUserOnline();
    _loadRecieverPic();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused || 
      state == AppLifecycleState.detached || 
      state == AppLifecycleState.inactive) {
    _authService.setUserOffline();
  } else if (state == AppLifecycleState.resumed) {
    _authService.setUserOnline();
  }
}
void _listenToMessagesAndMarkSeen() {
  final currentUserID = _authService.getCurrentUser()!.uid;
  List<String> ids = [currentUserID, widget.recieverID]..sort();
  String chatroomID = ids.join('_');

  FirebaseFirestore.instance
      .collection("chat_rooms")
      .doc(chatroomID)
      .collection("messages")
      .where('senderID', isEqualTo: widget.recieverID)
      .where('seen', isEqualTo: false)
      .snapshots()
      .listen((snapshot) async {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
        await change.doc.reference.update({'seen': true});
      }
    }
  });
}
  Future<void> _loadReceiverData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.recieverID)
        .get();

    if (doc.exists && mounted) {
      final user = UserModel.fromMap(doc.data()!, doc.id);
      setState(() {
        _receiverUser = user;
        _recieverProfilePic = user.profilePicUrl;
        _isReceiverOnline = user.isOnline;
        _lastSeenText = user.isOnline ? "Online" : _formatLastSeen(user.lastSeen);
      });

      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.recieverID)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          final updatedUser = UserModel.fromMap(snapshot.data()!, snapshot.id);
          setState(() {
            _isReceiverOnline = updatedUser.isOnline;
            _lastSeenText = updatedUser.isOnline ? "Online" : _formatLastSeen(updatedUser.lastSeen);
          });
        }
      });
    }
  }

  String _formatLastSeen(Timestamp? timestamp) {
    if (timestamp == null) return "Last seen unknown";
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "Last seen just now";
    if (diff.inMinutes < 60) return "Last seen ${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "Last seen ${diff.inHours} hr ago";
    return "Last seen ${DateFormat('MMM d').format(date)}";
  }

  Future<void> _loadRecieverPic() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.recieverID)
        .get();
    if (doc.exists && mounted) {
      setState(() {
        _recieverProfilePic = doc.data()?['profilePicUrl'];
      });
    }
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.recieverID, _messageController.text);
      _messageController.clear();
    }
  }

  Future<void> sendImageMessage(String receiverID) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    await _chatService.sendImageMessage(receiverID, File(picked.path));
  }

  Future<void> sendFile(String receiverID) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    await _chatService.sendFileMessage(receiverID, File(result.files.single.path!));
  }

  void _deleteChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Chat"),
        content: const Text("Delete all messages?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _chatService.deleteChat(widget.recieverID);
      if (mounted) Navigator.pop(context);
    }
  }

  void _deleteMessage(String messageId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Message"),
        content: const Text("Delete for everyone?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final currentUserID = _authService.getCurrentUser()!.uid;
      List<String> ids = [currentUserID, widget.recieverID]..sort();
      String chatroomID = ids.join('_');
      await FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(chatroomID)
          .collection("messages")
          .doc(messageId)
          .delete();
    }
  }


  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('h:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.recieverUsername, style: const TextStyle(fontSize: 16)),
            Text(
              _lastSeenText,
              style: TextStyle(
                fontSize: 12,
                color: _isReceiverOnline ? Colors.green : Colors.grey,
                fontWeight: _isReceiverOnline ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: _recieverProfilePic != null && _recieverProfilePic!.isNotEmpty
                ? NetworkImage(_recieverProfilePic!)
                : null,
            child: _recieverProfilePic == null || _recieverProfilePic!.isEmpty
                ? const Icon(Icons.person, size: 18)
                : null,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          PopupMenuButton<String>(
            onSelected: (v) => v == 'delete' ? _deleteChat() : null,
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Text("Delete Chat")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.recieverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Error"));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Text("Loading..."));

        return ListView.builder(
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final message = Message.fromMap(doc.data() as Map<String, dynamic>);
            return _buildMessageItem(message, doc.id);
          },
        );
      },
    );
  }

 Widget _buildMessageItem(Message message, String messageId) {
  final bool isMe = message.senderID == _authService.getCurrentUser()!.uid;

  Widget bubble;

  if (message.isImage) {
    bubble = _buildImageBubble(message.message);
  } else if (message.isFile) {
    bubble = _buildFileBubble(message.fileName);
  } else {
    bubble = ChatBubble(
      clipper: ChatBubbleClipper1(type: isMe ? BubbleType.sendBubble : BubbleType.receiverBubble),
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      margin: const EdgeInsets.only(top: 5),
      backGroundColor: isMe ? Colors.green : Colors.grey.shade500,
      child: Text(message.message, style: const TextStyle(color: Colors.white)),
    );
  }

  return GestureDetector(
    onDoubleTap: () => _toggleHeart(messageId),
    child: Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              bubble,
              if (message.heartCount > 0)
                Positioned(
                  bottom: 4,
                  right: isMe ? 8 : null,
                  left: isMe ? null : 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('heart', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          message.heartCount.toString(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 2, bottom: 8, left: isMe ? 0 : 25, right: isMe ? 25 : 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTimestamp(message.timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                if (isMe) 
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      message.seen ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.seen ? Colors.blue : Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  void _toggleHeart(String messageId) async {
    await _chatService.toggleHeart(widget.recieverID, messageId, true);
  }

  Widget _buildImageBubble(String base64) {
    try {
      final imageData = base64.contains('|') ? base64.split('|')[1] : base64;
      return Container(
        constraints: const BoxConstraints(maxWidth: 250),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.memory(base64Decode(imageData), fit: BoxFit.cover),
        ),
      );
    } catch (e) {
      return const Text("Image error");
    }
  }

  Widget _buildFileBubble(String? fileName) {
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
    decoration: BoxDecoration(
      color: Colors.blueGrey.shade400,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.insert_drive_file, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            fileName ?? "File",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.attach_file, color: Colors.grey),
            onSelected: (v) => v == 0 ? sendImageMessage(widget.recieverID) : sendFile(widget.recieverID),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 0, child: Text("Image")),
              const PopupMenuItem(value: 1, child: Text("File")),
            ],
          ),
          Expanded(
            child: MyTextfield(hintText: "Type a message..", obscureText: false, controller: _messageController),
          ),
          Container(
            margin: const EdgeInsets.only(right: 25),
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            child: IconButton(onPressed: sendMessage, icon: const Icon(Icons.arrow_upward, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}