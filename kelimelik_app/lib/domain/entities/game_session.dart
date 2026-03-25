/// Game session data for save/load persistence.
class GameSession {
  final String name;
  final List<List<Map<String, dynamic>>> boardState;
  final DateTime lastModified;

  const GameSession({
    required this.name,
    required this.boardState,
    required this.lastModified,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'board': boardState,
    'lastModified': lastModified.toIso8601String(),
  };

  factory GameSession.fromJson(Map<String, dynamic> json) => GameSession(
    name: json['name'] as String? ?? 'Unnamed',
    boardState:
        (json['board'] as List?)
            ?.map(
              (row) => (row as List)
                  .map(
                    (cell) => cell is Map<String, dynamic>
                        ? cell
                        : <String, dynamic>{
                            'char': cell.toString(),
                            'is_joker': false,
                          },
                  )
                  .toList(),
            )
            .toList() ??
        [],
    lastModified:
        DateTime.tryParse(json['lastModified'] as String? ?? '') ??
        DateTime.now(),
  );
}
