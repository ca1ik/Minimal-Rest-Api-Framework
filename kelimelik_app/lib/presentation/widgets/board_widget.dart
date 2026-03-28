import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/board_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/turkish_string.dart';
import '../providers/game_provider.dart';

/// High-performance game board built with CustomPainter + overlay input.
/// Supports keyboard navigation, right-click context menu, and mouse-wheel.
class GameBoardWidget extends ConsumerStatefulWidget {
  const GameBoardWidget({super.key});

  @override
  ConsumerState<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends ConsumerState<GameBoardWidget> {
  int? _focusedRow;
  int? _focusedCol;
  final _focusNode = FocusNode();
  final _textController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final boardSize = gameState.boardSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell size to fit available space
        final maxDim = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        // Reserve space for row/col headers
        final headerSize = 24.0;
        final availableSize = maxDim - headerSize;
        final cellSize = (availableSize / boardSize).floorToDouble().clamp(
          28.0,
          56.0,
        );
        final totalSize = cellSize * boardSize + headerSize;

        return KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (event) => _handleKeyboard(event, boardSize),
          child: GestureDetector(
            onTapDown: (details) =>
                _handleTap(details, cellSize, headerSize, boardSize),
            onSecondaryTapDown: (details) => _handleRightClick(
              context,
              details,
              cellSize,
              headerSize,
              boardSize,
            ),
            child: SizedBox(
              width: totalSize,
              height: totalSize,
              child: CustomPaint(
                painter: _BoardPainter(
                  board: gameState.board,
                  bonusMap: gameState.bonusMap,
                  boardSize: boardSize,
                  cellSize: cellSize,
                  headerSize: headerSize,
                  focusedRow: _focusedRow,
                  focusedCol: _focusedCol,
                  isDark: isDark,
                  userStars: gameState.userStars,
                ),
                child: _isEditing && _focusedRow != null && _focusedCol != null
                    ? _buildInlineEditor(cellSize, headerSize)
                    : const SizedBox.expand(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInlineEditor(double cellSize, double headerSize) {
    final left = headerSize + _focusedCol! * cellSize;
    final top = headerSize + _focusedRow! * cellSize;

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          width: cellSize,
          height: cellSize,
          child: TextField(
            controller: _textController,
            autofocus: true,
            maxLength: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: cellSize * 0.45,
              fontWeight: FontWeight.w800,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZçÇğĞıİöÖşŞüÜ\*]'),
              ),
            ],
            onChanged: (value) {
              if (value.isNotEmpty) {
                final upper = turkceUpper(value);
                ref
                    .read(gameProvider.notifier)
                    .setCellLetter(_focusedRow!, _focusedCol!, upper);
                setState(() {
                  _isEditing = false;
                  // Move to next cell
                  final boardSize = ref.read(gameProvider).boardSize;
                  if (_focusedCol! < boardSize - 1) {
                    _focusedCol = _focusedCol! + 1;
                  }
                });
                _textController.clear();
              }
            },
            onSubmitted: (_) => setState(() => _isEditing = false),
          ),
        ),
      ],
    );
  }

  void _handleTap(
    TapDownDetails details,
    double cellSize,
    double headerSize,
    int boardSize,
  ) {
    final col = ((details.localPosition.dx - headerSize) / cellSize).floor();
    final row = ((details.localPosition.dy - headerSize) / cellSize).floor();

    if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
      setState(() {
        _focusedRow = row;
        _focusedCol = col;
        _isEditing = true;
        _textController.clear();
      });
      _focusNode.requestFocus();
    }
  }

  void _handleRightClick(
    BuildContext context,
    TapDownDetails details,
    double cellSize,
    double headerSize,
    int boardSize,
  ) {
    final col = ((details.localPosition.dx - headerSize) / cellSize).floor();
    final row = ((details.localPosition.dy - headerSize) / cellSize).floor();

    if (row < 0 || row >= boardSize || col < 0 || col >= boardSize) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final globalPos = renderBox.localToGlobal(details.localPosition);

    final notifier = ref.read(gameProvider.notifier);
    final cell = ref.read(gameProvider).board[row][col];

    showMenu<void>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPos.dx,
        globalPos.dy,
        globalPos.dx + 1,
        globalPos.dy + 1,
      ),
      items: <PopupMenuEntry<void>>[
        PopupMenuItem<void>(
          onTap: () => notifier.toggleStar(row, col),
          child: Row(
            children: [
              const Icon(Icons.star, size: 16, color: KColors.boardStar),
              const SizedBox(width: 8),
              Text(cell.hasStar ? S.removeStar : S.addStar),
            ],
          ),
        ),
        PopupMenuItem<void>(
          onTap: () => notifier.toggleJoker(row, col),
          child: Row(
            children: [
              Icon(
                Icons.casino,
                size: 16,
                color: cell.isJoker ? Colors.red : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(cell.isJoker ? S.removeJoker : S.markJoker),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          onTap: () => _promptWordEntry(context, row, col, true),
          child: Row(
            children: [
              Icon(Icons.arrow_forward, size: 16),
              SizedBox(width: 8),
              Text(S.enterWordHorizontal),
            ],
          ),
        ),
        PopupMenuItem<void>(
          onTap: () => _promptWordEntry(context, row, col, false),
          child: Row(
            children: [
              Icon(Icons.arrow_downward, size: 16),
              SizedBox(width: 8),
              Text(S.enterWordVertical),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          enabled: false,
          child: Text(
            S.cellLabel('${String.fromCharCode(65 + row)}${col + 1}'),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void _promptWordEntry(
    BuildContext context,
    int row,
    int col,
    bool horizontal,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(horizontal ? S.enterWordHorizontal : S.enterWordVertical),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: S.wordAtPosition(
              '${String.fromCharCode(65 + row)}${col + 1}',
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              ref
                  .read(gameProvider.notifier)
                  .enterWord(row, col, value, horizontal);
            }
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(S.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(gameProvider.notifier)
                    .enterWord(row, col, controller.text, horizontal);
              }
              Navigator.of(ctx).pop();
            },
            child: Text(S.enter),
          ),
        ],
      ),
    );
  }

  void _handleKeyboard(KeyEvent event, int boardSize) {
    if (event is! KeyDownEvent) return;
    if (_focusedRow == null || _focusedCol == null) return;

    setState(() {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          if (_focusedRow! > 0) _focusedRow = _focusedRow! - 1;
        case LogicalKeyboardKey.arrowDown:
          if (_focusedRow! < boardSize - 1) _focusedRow = _focusedRow! + 1;
        case LogicalKeyboardKey.arrowLeft:
          if (_focusedCol! > 0) _focusedCol = _focusedCol! - 1;
        case LogicalKeyboardKey.arrowRight:
          if (_focusedCol! < boardSize - 1) _focusedCol = _focusedCol! + 1;
        case LogicalKeyboardKey.delete:
        case LogicalKeyboardKey.backspace:
          ref
              .read(gameProvider.notifier)
              .setCellLetter(_focusedRow!, _focusedCol!, '');
        case LogicalKeyboardKey.enter:
          _isEditing = true;
          _textController.clear();
        default:
          break;
      }
    });
  }
}

// ─── Custom Painter ─────────────────────────────────────────────────

class _BoardPainter extends CustomPainter {
  final List<List<dynamic>> board;
  final List<List<String>> bonusMap;
  final int boardSize;
  final double cellSize;
  final double headerSize;
  final int? focusedRow;
  final int? focusedCol;
  final bool isDark;
  final Set<(int, int)> userStars;

  _BoardPainter({
    required this.board,
    required this.bonusMap,
    required this.boardSize,
    required this.cellSize,
    required this.headerSize,
    required this.focusedRow,
    required this.focusedCol,
    required this.isDark,
    required this.userStars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellPaint = Paint();
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = isDark
          ? KColors.darkBorder.withValues(alpha: 0.5)
          : KColors.lightBorder;

    // Draw column headers
    for (var c = 0; c < boardSize; c++) {
      _drawText(
        canvas,
        '${c + 1}',
        Offset(headerSize + c * cellSize + cellSize / 2, headerSize / 2),
        isDark ? KColors.darkTextSubtle : KColors.lightTextSubtle,
        10,
      );
    }

    // Draw row headers
    for (var r = 0; r < boardSize; r++) {
      _drawText(
        canvas,
        String.fromCharCode(65 + r),
        Offset(headerSize / 2, headerSize + r * cellSize + cellSize / 2),
        isDark ? KColors.darkTextSubtle : KColors.lightTextSubtle,
        10,
      );
    }

    // Draw cells
    for (var r = 0; r < boardSize; r++) {
      for (var c = 0; c < boardSize; c++) {
        final rect = Rect.fromLTWH(
          headerSize + c * cellSize,
          headerSize + r * cellSize,
          cellSize,
          cellSize,
        );

        final cell = board[r][c];
        final bonus = BonusType.fromCode(bonusMap[r][c]);
        final hasStar = userStars.contains((r, c));

        // Background
        cellPaint.style = PaintingStyle.fill;

        if (cell.isFilled && !cell.isPreview) {
          cellPaint.color = KColors.boardFilled;
        } else if (cell.isPreview) {
          cellPaint.color = KColors.boardPreview.withValues(alpha: 0.8);
        } else if (hasStar) {
          cellPaint.color = KColors.boardStar.withValues(alpha: 0.6);
        } else {
          cellPaint.color = _bonusColor(bonus);
        }

        final rrect = RRect.fromRectAndRadius(
          rect.deflate(1.5),
          const Radius.circular(4),
        );
        canvas.drawRRect(rrect, cellPaint);

        // Border
        if (focusedRow == r && focusedCol == c) {
          borderPaint.color = KColors.darkAccent;
          borderPaint.strokeWidth = 2.5;
        } else if (cell.isJoker && cell.isFilled) {
          borderPaint.color = KColors.boardJokerBorder;
          borderPaint.strokeWidth = 2.0;
        } else {
          borderPaint.color = isDark
              ? KColors.darkBorder.withValues(alpha: 0.4)
              : KColors.lightBorder.withValues(alpha: 0.6);
          borderPaint.strokeWidth = 1.0;
        }
        canvas.drawRRect(rrect, borderPaint);

        // Text
        if (cell.letter.isNotEmpty) {
          final color = cell.isPreview
              ? Colors.white
              : (cell.isFilled ? KColors.boardFilledText : Colors.white);
          _drawText(
            canvas,
            turkceUpper(cell.letter),
            rect.center,
            color,
            cellSize * 0.4,
            fontWeight: FontWeight.w800,
          );
        } else if (hasStar) {
          _drawText(
            canvas,
            '★',
            rect.center,
            KColors.boardStar,
            cellSize * 0.4,
          );
        } else if (bonus != BonusType.none) {
          _drawText(
            canvas,
            _bonusLabel(bonus),
            rect.center,
            Colors.white.withValues(alpha: 0.85),
            cellSize * 0.2,
            fontWeight: FontWeight.w600,
          );
        }
      }
    }
  }

  Color _bonusColor(BonusType bonus) => switch (bonus) {
    BonusType.k3 => KColors.boardK3.withValues(alpha: isDark ? 0.75 : 0.85),
    BonusType.k2 => KColors.boardK2.withValues(alpha: isDark ? 0.75 : 0.85),
    BonusType.h3 => KColors.boardH3.withValues(alpha: isDark ? 0.75 : 0.85),
    BonusType.h2 => KColors.boardH2.withValues(alpha: isDark ? 0.6 : 0.7),
    BonusType.start => KColors.boardStart.withValues(alpha: isDark ? 0.7 : 0.8),
    BonusType.none => isDark ? KColors.darkCardHover : KColors.lightCardHover,
  };

  String _bonusLabel(BonusType bonus) => switch (bonus) {
    BonusType.k3 => S.bonusK3,
    BonusType.k2 => S.bonusK2,
    BonusType.h3 => S.bonusH3,
    BonusType.h2 => S.bonusH2,
    BonusType.start => '★',
    BonusType.none => '',
  };

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    Color color,
    double fontSize, {
    FontWeight fontWeight = FontWeight.w500,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => true;
}
