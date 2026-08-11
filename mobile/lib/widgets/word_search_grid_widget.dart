import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentsoul_mobile/config/theme.dart';

class WordSearchPuzzleItem {
  final String word;
  final String definition;
  final List<List<int>> path; // [(row, col), ...]

  WordSearchPuzzleItem({
    required this.word,
    required this.definition,
    required this.path,
  });
}

class WordSearchGridWidget extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int xp)? onAwardXp;

  const WordSearchGridWidget({
    super.key,
    this.onComplete,
    this.onAwardXp,
  });

  @override
  State<WordSearchGridWidget> createState() => _WordSearchGridWidgetState();
}

class _WordSearchGridWidgetState extends State<WordSearchGridWidget> {
  static const int numRows = 8;
  static const int numCols = 8;

  final GlobalKey _gridKey = GlobalKey();

  final List<List<String>> _grid = [
    ['F', 'L', 'U', 'E', 'N', 'T', 'X', 'P'],
    ['K', 'S', 'O', 'U', 'L', 'M', 'V', 'R'],
    ['A', 'B', 'C', 'D', 'E', 'F', 'O', 'G'],
    ['H', 'I', 'J', 'K', 'L', 'M', 'I', 'N'],
    ['O', 'P', 'Q', 'R', 'S', 'T', 'C', 'U'],
    ['C', 'L', 'A', 'R', 'I', 'T', 'Y', 'W'],
    ['Y', 'Z', 'A', 'B', 'C', 'D', 'X', 'Y'],
    ['S', 'P', 'E', 'E', 'C', 'H', 'Z', 'Q'],
  ];

  final List<WordSearchPuzzleItem> _puzzleItems = [
    WordSearchPuzzleItem(
      word: 'FLUENT',
      definition: 'Able to express oneself easily, smoothly, and articulately.',
      path: [
        [0, 0],
        [0, 1],
        [0, 2],
        [0, 3],
        [0, 4],
        [0, 5]
      ],
    ),
    WordSearchPuzzleItem(
      word: 'SOUL',
      definition: 'The essence, emotional depth, or true character of speech.',
      path: [
        [1, 1],
        [1, 2],
        [1, 3],
        [1, 4]
      ],
    ),
    WordSearchPuzzleItem(
      word: 'VOICE',
      definition: 'The sound produced in the larynx and uttered through mouth.',
      path: [
        [1, 6],
        [2, 6],
        [3, 6],
        [4, 6],
        [5, 6]
      ],
    ),
    WordSearchPuzzleItem(
      word: 'CLARITY',
      definition: 'The quality of being clear, transparent, and coherent.',
      path: [
        [5, 0],
        [5, 1],
        [5, 2],
        [5, 3],
        [5, 4],
        [5, 5],
        [5, 6]
      ],
    ),
    WordSearchPuzzleItem(
      word: 'SPEECH',
      definition: 'The expression of thoughts and feelings by spoken words.',
      path: [
        [7, 0],
        [7, 1],
        [7, 2],
        [7, 3],
        [7, 4],
        [7, 5]
      ],
    ),
  ];

  final Set<String> _foundWords = {};
  final Set<String> _foundCells = {}; // "r_c"
  final Set<String> _revealedHints = {};
  final List<List<int>> _selectedPath = [];

  bool _isGameOver = false;
  bool _isDragging = false;
  int _secondsLeft = 90;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        _finishGame();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_isGameOver) return;
    _isDragging = true;
    setState(() {
      _selectedPath.clear();
    });
    _updatePointerPosition(event.position);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isGameOver || !_isDragging) return;
    _updatePointerPosition(event.position);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_isGameOver) return;
    _isDragging = false;
    _checkSelectedWord();
  }

  void _updatePointerPosition(Offset globalPosition) {
    final RenderBox? renderBox =
        _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset localPosition = renderBox.globalToLocal(globalPosition);
    final Size size = renderBox.size;

    final double cellWidth = size.width / numCols;
    final double cellHeight = size.height / numRows;

    final int col =
        (localPosition.dx / cellWidth).floor().clamp(0, numCols - 1);
    final int row =
        (localPosition.dy / cellHeight).floor().clamp(0, numRows - 1);

    if (!_selectedPath.any((p) => p[0] == row && p[1] == col)) {
      setState(() {
        _selectedPath.add([row, col]);
      });
    }
  }

  void _toggleCellTap(int row, int col) {
    if (_isGameOver) return;
    setState(() {
      final existsIndex =
          _selectedPath.indexWhere((p) => p[0] == row && p[1] == col);
      if (existsIndex != -1) {
        _selectedPath.removeAt(existsIndex);
      } else {
        _selectedPath.add([row, col]);
      }
      _checkSelectedWord();
    });
  }

  void _checkSelectedWord() {
    if (_selectedPath.isEmpty) return;

    final selectedStr =
        _selectedPath.map((p) => _grid[p[0]][p[1]]).join().toUpperCase();
    final reversedStr = selectedStr.split('').reversed.join();

    bool matched = false;
    for (final item in _puzzleItems) {
      if (_foundWords.contains(item.word)) continue;

      if (selectedStr == item.word || reversedStr == item.word) {
        matched = true;
        _foundWords.add(item.word);
        for (final p in item.path) {
          _foundCells.add('${p[0]}_${p[1]}');
        }

        if (widget.onAwardXp != null) {
          widget.onAwardXp!(10);
        }

        if (_foundWords.length == _puzzleItems.length) {
          _timer?.cancel();
          _finishGame();
        }
        break;
      }
    }

    if (matched) {
      setState(() {
        _selectedPath.clear();
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedPath.clear();
    });
  }

  void _finishGame() {
    setState(() {
      _isGameOver = true;
    });
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  bool _isCellSelected(int row, int col) {
    return _selectedPath.any((p) => p[0] == row && p[1] == col);
  }

  bool _isCellFound(int row, int col) {
    return _foundCells.contains('${row}_$col');
  }

  String _getWordHint(String word) {
    if (word.length <= 2) return word;
    final start = word[0];
    final end = word[word.length - 1];
    final blanks = '_' * (word.length - 2);
    return '$start $blanks $end (${word.length} letters)';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final headingColor = isDark ? AppTheme.textMain : AppTheme.textMainLight;
    final subtitleColor = isDark ? AppTheme.textMuted : AppTheme.textMutedLight;

    final currentWordText =
        _selectedPath.map((p) => _grid[p[0]][p[1]]).join();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: AppTheme.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${_secondsLeft}s',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: headingColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  currentWordText.isNotEmpty
                      ? 'Selected: $currentWordText'
                      : 'Found ${_foundWords.length} / ${_puzzleItems.length}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                TextButton(
                  onPressed: _clearSelection,
                  child: Text(
                    'Clear',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: subtitleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Raw Pointer Listener for Smooth Drag & Tap Grid Selection
          Listener(
            key: _gridKey,
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: numRows * numCols,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: numCols,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemBuilder: (context, index) {
                    final row = index ~/ numCols;
                    final col = index % numCols;
                    final letter = _grid[row][col];
                    final isSelected = _isCellSelected(row, col);
                    final isFound = _isCellFound(row, col);

                    Color cellBg = isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white;
                    Color borderCol = isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1);
                    Color textColor = headingColor;

                    if (isFound) {
                      cellBg = Colors.green.withOpacity(0.25);
                      borderCol = Colors.green;
                      textColor = Colors.green;
                    } else if (isSelected) {
                      cellBg = AppTheme.primary.withOpacity(0.35);
                      borderCol = AppTheme.primary;
                      textColor = AppTheme.primary;
                    }

                    return GestureDetector(
                      onTap: () => _toggleCellTap(row, col),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        decoration: BoxDecoration(
                          color: cellBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: borderCol,
                              width: isSelected || isFound ? 2 : 1),
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 1-Line Definitions Checklist
          Text(
            'Drag or tap grid letters to find definitions:',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 10),

          ..._puzzleItems.map((item) {
            final isDone = _foundWords.contains(item.word);
            final isHintRevealed = _revealedHints.contains(item.word);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDone ? Colors.green.withOpacity(0.12) : cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDone
                      ? Colors.green.withOpacity(0.4)
                      : borderColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isDone
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isDone ? Colors.green : subtitleColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isDone) ...[
                              Text(
                                item.word,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  '${item.word.length} letters',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ] else if (isHintRevealed) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppTheme.primary.withOpacity(0.25),
                                  ),
                                ),
                                child: Text(
                                  'Hint: ${_getWordHint(item.word)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ] else ...[
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _revealedHints.add(item.word);
                                  });
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.amber.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('💡',
                                          style: TextStyle(fontSize: 11)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Show Hint',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.definition,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: isDone ? headingColor : subtitleColor,
                            height: 1.3,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
