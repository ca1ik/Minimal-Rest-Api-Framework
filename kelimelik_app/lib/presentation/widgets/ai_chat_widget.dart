import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';

/// AI Chat message model
class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

/// Provider for AI chat state
final aiChatExpandedProvider = StateProvider<bool>((ref) => false);

/// AI Chat widget with RGB LED glow effect at bottom-right.
class AiChatWidget extends ConsumerStatefulWidget {
  const AiChatWidget({super.key});

  @override
  ConsumerState<AiChatWidget> createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends ConsumerState<AiChatWidget>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  late final AnimationController _rgbController;
  late final AnimationController _pulseController;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _rgbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Welcome message
    _messages.add(
      _ChatMessage(
        text:
            'Merhaba! Ben Kelimelik AI asistanınızım. Bana kelimelik hakkında soru sorabilir veya '
            'komut verebilirsiniz.\n\n'
            'Örnek komutlar:\n'
            '• "ES kelimesini 7,7\'ye yatay yaz"\n'
            '• "Tahtayı temizle"\n'
            '• "Hamle bul"\n'
            '• "En iyi hamleyi oyna"\n'
            '• "Kalan harfleri göster"',
        isUser: false,
        time: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _rgbController.dispose();
    _pulseController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getRgbColor(double t) {
    final r = (sin(t * 2 * pi) * 127 + 128).toInt();
    final g = (sin(t * 2 * pi + 2.094) * 127 + 128).toInt();
    final b = (sin(t * 2 * pi + 4.189) * 127 + 128).toInt();
    return Color.fromARGB(255, r, g, b);
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(text: text.trim(), isUser: true, time: DateTime.now()),
      );
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Process command
    final command = text.trim().toLowerCase();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final response = _processCommand(command);
      setState(() {
        _messages.add(
          _ChatMessage(text: response, isUser: false, time: DateTime.now()),
        );
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  String _processCommand(String command) {
    final notifier = ref.read(gameProvider.notifier);
    final state = ref.read(gameProvider);

    // Board clear
    if (command.contains('temizle') || command.contains('sıfırla')) {
      notifier.clearBoard();
      return 'Tahta temizlendi! ✅';
    }

    // Find moves
    if (command.contains('hamle bul') || command.contains('çöz')) {
      if (state.handLetters.trim().isEmpty) {
        return 'Önce elinizdeki harfleri girin, sonra hamle bulabilirim.';
      }
      notifier.findMoves();
      return 'Hamle arama başlatıldı! 🔍 Sonuçlar hazır olduğunda tabloda görünecek.';
    }

    // Play best move
    if (command.contains('en iyi') && command.contains('oyna') ||
        command.contains('best')) {
      if (state.moves.isEmpty) {
        return 'Henüz bulunan hamle yok. Önce "hamle bul" deneyin.';
      }
      notifier.selectMove(0);
      notifier.playSelectedMove();
      return 'En yüksek puanlı hamle oynandı! 🎯\n'
          '${state.moves.first.word} → ${state.moves.first.score} puan';
    }

    // Select move
    if (command.contains('seç') && command.contains('oyna')) {
      if (state.selectedMoveIndex != null) {
        notifier.playSelectedMove();
        return 'Seçili hamle oynandı! ✅';
      }
      return 'Önce sonuçlar tablosundan bir hamle seçin.';
    }

    // Remaining letters
    if (command.contains('kalan') && command.contains('harf')) {
      final remaining = state.remainingLetters;
      final total = remaining.values.fold<int>(0, (s, v) => s + v.clamp(0, 99));
      final nonZero = remaining.entries
          .where((e) => e.value > 0)
          .map((e) => '${e.key}:${e.value}')
          .join(', ');
      return 'Kalan $total taş:\n$nonZero';
    }

    // Enter word on board
    final writeMatch = RegExp(
      r'(?:yaz|koy|yerleştir).*?([a-züöçşığ]+).*?(\d+)\s*[,;.]\s*(\d+).*?(yatay|dikey)',
      caseSensitive: false,
    ).firstMatch(command);
    if (writeMatch != null) {
      final word = writeMatch.group(1)!;
      final row = int.tryParse(writeMatch.group(2)!) ?? 0;
      final col = int.tryParse(writeMatch.group(3)!) ?? 0;
      final horizontal = writeMatch.group(4)!.contains('yatay');
      notifier.enterWord(row, col, word, horizontal);
      return '"${word.toUpperCase()}" kelimesi ($row,$col) konumuna '
          '${horizontal ? "yatay" : "dikey"} olarak yazıldı! ✅';
    }

    // Set hand letters
    if (command.contains('harf') &&
        (command.contains('gir') || command.contains('ayarla'))) {
      final letters = command.replaceAll(RegExp(r'[^a-züöçşığ*]'), '');
      if (letters.isNotEmpty) {
        notifier.setHandLetters(letters);
        return 'El harfleri "${letters.toUpperCase()}" olarak ayarlandı! ✅';
      }
    }

    // Opponent analysis
    if (command.contains('rakip')) {
      notifier.findMoves(isOpponent: true);
      return 'Rakip analizi başlatıldı! 🕵️ Sonuçlar hazır olduğunda görünecek.';
    }

    // Game type
    if (command.contains('5lik') ||
        command.contains('beşlik') ||
        command.contains('9x9')) {
      notifier.setGameType(GameType.beslik);
      return 'Oyun modu 9×9 (5\'lik) olarak değiştirildi! ✅';
    }
    if (command.contains('klasik') || command.contains('15x15')) {
      notifier.setGameType(GameType.klasik);
      return 'Oyun modu 15×15 (Klasik) olarak değiştirildi! ✅';
    }

    // Stats
    if (command.contains('istatistik') || command.contains('durum')) {
      final dict = ref.read(dictionaryProvider).valueOrNull;
      return 'Durum Raporu:\n'
          '• Sözlük: ${dict?.length ?? 0} kelime\n'
          '• Tahta: ${state.gameType == GameType.klasik ? "15×15" : "9×9"}\n'
          '• Bulunan hamle: ${state.moves.length}\n'
          '• En yüksek puan: ${state.moves.isNotEmpty ? state.moves.first.score : 0}\n'
          '• Kalan taş: ${state.totalRemainingLetters}';
    }

    // Help
    if (command.contains('yardım') || command.contains('help')) {
      return 'Kullanılabilir komutlar:\n\n'
          '🎮 Oyun:\n'
          '• "hamle bul" — Hamle ara\n'
          '• "en iyi hamleyi oyna" — #1 hamleyi oyna\n'
          '• "tahtayı temizle" — Sıfırla\n'
          '• "rakip analizi" — Rakip hamlelerini bul\n\n'
          '📝 Tahta:\n'
          '• "[kelime] [satır],[sütun] yatay/dikey yaz"\n'
          '• "harf gir [harfler]" — El harflerini ayarla\n\n'
          '📊 Bilgi:\n'
          '• "kalan harfler" — Torba durumu\n'
          '• "durum" — Genel istatistik\n'
          '• "klasik/5lik" — Oyun modu değiştir';
    }

    return 'Anlamadım. "yardım" yazarak kullanılabilir komutları görebilirsiniz. 🤔';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = ref.watch(aiChatExpandedProvider);

    return AnimatedBuilder(
      animation: _rgbController,
      builder: (context, child) {
        final rgbColor = _getRgbColor(_rgbController.value);

        if (!isExpanded) {
          return _buildFab(context, rgbColor);
        }
        return _buildExpandedChat(context, rgbColor);
      },
    );
  }

  Widget _buildFab(BuildContext context, Color rgbColor) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulse = _pulseController.value * 0.3 + 0.7;
        return GestureDetector(
          onTap: () => ref.read(aiChatExpandedProvider.notifier).state = true,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _getRgbColor(_rgbController.value),
                  _getRgbColor(_rgbController.value + 0.33),
                  _getRgbColor(_rgbController.value + 0.66),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: rgbColor.withValues(alpha: 0.5 * pulse),
                  blurRadius: 20 * pulse,
                  spreadRadius: 4 * pulse,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 26,
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedChat(BuildContext context, Color rgbColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? KColors.darkCard : KColors.lightCard;
    final borderColor = isDark ? KColors.darkBorder : KColors.lightBorder;

    return Container(
      width: 380,
      height: 480,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: rgbColor.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 2,
          ),
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 32),
        ],
      ),
      child: Column(
        children: [
          // Header with RGB gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              gradient: LinearGradient(
                colors: [
                  _getRgbColor(_rgbController.value).withValues(alpha: 0.2),
                  _getRgbColor(
                    _rgbController.value + 0.5,
                  ).withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getRgbColor(_rgbController.value),
                        _getRgbColor(_rgbController.value + 0.5),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Kelimelik AI',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: KColors.darkAccentGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ONLINE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: KColors.darkAccentGreen,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      ref.read(aiChatExpandedProvider.notifier).state = false,
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: isDark
                        ? KColors.darkTextSubtle
                        : KColors.lightTextSubtle,
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length && _isTyping) {
                  return _buildTypingIndicator(context);
                }
                return _buildMessage(context, _messages[i]);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? KColors.darkBorder : KColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: theme.textTheme.bodySmall,
                    decoration: InputDecoration(
                      hintText: 'Komut veya soru yazın...',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: rgbColor, width: 1.5),
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _rgbController,
                  builder: (context, child) => GestureDetector(
                    onTap: () => _sendMessage(_controller.text),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            _getRgbColor(_rgbController.value),
                            _getRgbColor(_rgbController.value + 0.5),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context, _ChatMessage msg) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: msg.isUser
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : (isDark ? KColors.darkCardHover : KColors.lightCardHover),
          borderRadius: BorderRadius.circular(12),
          border: msg.isUser
              ? Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Text(
          msg.text,
          style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? KColors.darkCardHover : KColors.lightCardHover,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final offset = (_pulseController.value + i * 0.2) % 1.0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        (isDark
                                ? KColors.darkTextSubtle
                                : KColors.lightTextSubtle)
                            .withValues(alpha: 0.3 + offset * 0.7),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
