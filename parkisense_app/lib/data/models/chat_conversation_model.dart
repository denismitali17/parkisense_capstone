import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversationModel {
  final String id;
  final String userId;
  final String userName;
  final String doctorId;
  final String doctorName;
  final DateTime lastMessageTime;
  final String? lastMessage;
  final int unreadUserCount;
  final int unreadDoctorCount;
  final DateTime createdAt;

  ChatConversationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.doctorId,
    required this.doctorName,
    required this.lastMessageTime,
    this.lastMessage,
    this.unreadUserCount = 0,
    this.unreadDoctorCount = 0,
    required this.createdAt,
  });

  factory ChatConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatConversationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'],
      unreadUserCount: data['unreadUserCount'] ?? 0,
      unreadDoctorCount: data['unreadDoctorCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessage': lastMessage,
      'unreadUserCount': unreadUserCount,
      'unreadDoctorCount': unreadDoctorCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ChatConversationModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? doctorId,
    String? doctorName,
    DateTime? lastMessageTime,
    String? lastMessage,
    int? unreadUserCount,
    int? unreadDoctorCount,
    DateTime? createdAt,
  }) {
    return ChatConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadUserCount: unreadUserCount ?? this.unreadUserCount,
      unreadDoctorCount: unreadDoctorCount ?? this.unreadDoctorCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
