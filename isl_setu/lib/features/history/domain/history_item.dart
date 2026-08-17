import 'dart:convert';

class HistoryItem {
  final String id;
  final String sentence;
  final DateTime timestamp;

  const HistoryItem({
    required this.id,
    required this.sentence,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sentence': sentence,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      sentence: json['sentence'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String encode() => jsonEncode(toJson());

  factory HistoryItem.decode(String raw) =>
      HistoryItem.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
