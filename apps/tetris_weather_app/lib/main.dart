import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const TetrisWeatherApp());
}

class TetrisWeatherApp extends StatelessWidget {
  const TetrisWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFB84C);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tetris Weather',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: Color(0xFF56E6A5),
          surface: Color(0xFF0F172B),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A1021),
        fontFamily: 'SF Pro Display',
      ),
      home: const SunnyWeatherPage(),
    );
  }
}

class SunnyWeatherPage extends StatefulWidget {
  const SunnyWeatherPage({super.key});

  @override
  State<SunnyWeatherPage> createState() => _SunnyWeatherPageState();
}

class _SunnyWeatherPageState extends State<SunnyWeatherPage> {
  final _boardKey = GlobalKey<_TetrisBoardState>();
  int _clearedLines = 0;

  void _handleCleared(int total) {
    setState(() {
      _clearedLines = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFB84C);
    const highlight = Color(0xFF56E6A5);
    const background = Color(0xFF0A1021);
    const secondary = Color(0xFF16233C);
    final temps = <double>[17, 19, 23, 27, 30, 31, 28, 24];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B1226),
              Color(0xFF0A172F),
              Color(0xFF0C1C3B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boardHeight = max(360.0, constraints.maxHeight * 0.48);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Header(accent: accent, highlight: highlight),
                      const SizedBox(height: 12),
                      const Text(
                        '晴朗 · 方块轻盈落下，自动消行代表稳态天气',
                        style: TextStyle(
                          color: Color(0xFF9BB2D9),
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TemperatureCard(
                        temps: temps,
                        accent: accent,
                        background: secondary,
                      ),
                      const SizedBox(height: 12),
                      const _SunriseSunsetRow(
                        accent: accent,
                        background: secondary,
                        highlight: highlight,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: boardHeight,
                        child: _BoardSection(
                          accent: accent,
                          secondary: secondary,
                          background: background,
                          clearedLines: _clearedLines,
                          boardKey: _boardKey,
                          onCleared: _handleCleared,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.accent,
    required this.highlight,
  });

  final Color accent;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '莫斯科',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.94),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _BlockChip(label: '晴天', color: accent),
                  const SizedBox(width: 6),
                  _BlockChip(label: '平稳', color: highlight),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Today is clean · 12月 · 轻风 2m/s',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: 14,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _BlockSun(),
      ],
    );
  }
}

class _BoardSection extends StatelessWidget {
  const _BoardSection({
    required this.accent,
    required this.secondary,
    required this.background,
    required this.clearedLines,
    required this.boardKey,
    required this.onCleared,
  });

  final Color accent;
  final Color secondary;
  final Color background;
  final int clearedLines;
  final GlobalKey<_TetrisBoardState> boardKey;
  final ValueChanged<int> onCleared;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: secondary.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Tetris 晴空场',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.94),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 10),
              _BlockChip(label: '轻松消行', color: accent),
              const SizedBox(width: 8),
              const _BlockChip(label: '手动可控', color: Colors.white24),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: AspectRatio(
              aspectRatio: 10 / 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        background.withOpacity(0.8),
                        background.withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: TetrisBoard(
                    key: boardKey,
                    accent: accent,
                    onLinesCleared: onCleared,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '今日已消行：$_lineLabel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 12),
              _BlockChip(
                label: '阳光加速',
                color: Colors.white.withOpacity(0.14),
              ),
              const Spacer(),
              Icon(Icons.bolt, color: accent, size: 18),
              const SizedBox(width: 4),
              Text(
                '体感 27°C',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ControlRow(accent: accent, boardKey: boardKey),
        ],
      ),
    );
  }

  String get _lineLabel => clearedLines == 0 ? '准备中' : '$clearedLines 行';
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({
    required this.accent,
    required this.boardKey,
  });

  final Color accent;
  final GlobalKey<_TetrisBoardState> boardKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ControlButton(
          icon: Icons.chevron_left,
          label: '左移',
          onTap: () => boardKey.currentState?.moveLeft(),
        ),
        _ControlButton(
          icon: Icons.rotate_right,
          label: '旋转',
          onTap: () => boardKey.currentState?.rotate(),
        ),
        _ControlButton(
          icon: Icons.chevron_right,
          label: '右移',
          onTap: () => boardKey.currentState?.moveRight(),
        ),
        _ControlButton(
          icon: Icons.arrow_downward,
          label: '下落',
          onTap: () => boardKey.currentState?.softDrop(),
        ),
        _ControlButton(
          icon: Icons.flash_on,
          label: '直落',
          highlight: accent,
          onTap: () => boardKey.currentState?.hardDrop(),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ?? Colors.white.withOpacity(0.8);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TemperatureCard extends StatelessWidget {
  const _TemperatureCard({
    required this.temps,
    required this.accent,
    required this.background,
  });

  final List<double> temps;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final maxTemp = temps.reduce(max).toStringAsFixed(0);
    final minTemp = temps.reduce(min).toStringAsFixed(0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '体感 27°C',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const _BlockChip(label: '干爽', color: Colors.white24),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '温度曲线：$minTemp~$maxTemp°C · 晴空曲线平滑',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              _MiniLegend(accent: accent),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: CustomPaint(
              painter: _TemperatureCurvePainter(
                temps: temps,
                accent: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLegend extends StatelessWidget {
  const _MiniLegend({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _LegendRow(color: accent, label: '晴朗升温'),
        const SizedBox(height: 6),
        const _LegendRow(color: Colors.white38, label: '方块堆叠速度'),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.78),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SunriseSunsetRow extends StatelessWidget {
  const _SunriseSunsetRow({
    required this.accent,
    required this.background,
    required this.highlight,
  });

  final Color accent;
  final Color background;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SunTile(
            title: '日出',
            time: '06:32',
            accent: accent,
            background: background,
            icon: Icons.east,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SunTile(
            title: '日落',
            time: '18:21',
            accent: highlight,
            background: background,
            icon: Icons.west,
          ),
        ),
      ],
    );
  }
}

class _SunTile extends StatelessWidget {
  const _SunTile({
    required this.title,
    required this.time,
    required this.accent,
    required this.background,
    required this.icon,
  });

  final String title;
  final String time;
  final Color accent;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          _BlockIcon(accent: accent, icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.94),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Tetris view · 平稳上升',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockIcon extends StatelessWidget {
  const _BlockIcon({
    required this.accent,
    required this.icon,
  });

  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withOpacity(0.6)),
      ),
      child: Icon(icon, color: accent),
    );
  }
}

class TetrisBoard extends StatefulWidget {
  const TetrisBoard({
    super.key,
    required this.accent,
    this.onLinesCleared,
  });

  final Color accent;
  final ValueChanged<int>? onLinesCleared;

  @override
  State<TetrisBoard> createState() => _TetrisBoardState();
}

class _TetrisBoardState extends State<TetrisBoard> {
  static const int _boardWidth = 10;
  static const int _boardHeight = 16;

  late List<List<Color?>> _board;
  late Tetromino _current;
  late int _pieceX;
  late int _pieceY;
  int _cleared = 0;
  Timer? _timer;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _resetBoard();
    _spawnPiece();
    _timer = Timer.periodic(const Duration(milliseconds: 620), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get clearedLines => _cleared;

  void moveLeft() => _tryMove(-1, 0);

  void moveRight() => _tryMove(1, 0);

  void rotate() => _rotatePiece();

  void softDrop() => _stepDown();

  void hardDrop() {
    final landingY = _landingY();
    setState(() {
      _pieceY = landingY;
    });
    _mergePiece();
  }

  void _tick() {
    if (!mounted) return;
    _stepDown();
  }

  void _resetBoard() {
    _board = List.generate(
      _boardHeight,
      (_) => List<Color?>.filled(_boardWidth, null),
    );
  }

  void _spawnPiece() {
    final palette = [
      widget.accent,
      const Color(0xFFFF8E3C),
      const Color(0xFFFFC857),
      const Color(0xFFFF9E80),
    ];
    final shapes = Tetromino.sunnyShapes(palette);
    _current = shapes[_random.nextInt(shapes.length)];
    _pieceX = (_boardWidth - _current.size) ~/ 2;
    _pieceY = -1;

    if (!_canPlace(_current, _pieceX, _pieceY)) {
      _resetBoard();
    }
    setState(() {});
  }

  void _stepDown() {
    if (!_tryMove(0, 1)) {
      _mergePiece();
    }
  }

  bool _tryMove(int dx, int dy) {
    final newX = _pieceX + dx;
    final newY = _pieceY + dy;
    if (!_canPlace(_current, newX, newY)) {
      return false;
    }
    setState(() {
      _pieceX = newX;
      _pieceY = newY;
    });
    return true;
  }

  void _rotatePiece() {
    final rotated = _current.rotated();
    if (_canPlace(rotated, _pieceX, _pieceY)) {
      setState(() {
        _current = rotated;
      });
    }
  }

  bool _canPlace(Tetromino piece, int x, int y) {
    for (final cell in piece.blocks) {
      final px = x + cell.x;
      final py = y + cell.y;
      if (px < 0 || px >= _boardWidth) return false;
      if (py >= _boardHeight) return false;
      if (py >= 0 && _board[py][px] != null) return false;
    }
    return true;
  }

  void _mergePiece() {
    for (final cell in _current.blocks) {
      final px = _pieceX + cell.x;
      final py = _pieceY + cell.y;
      if (py >= 0 && py < _boardHeight) {
        _board[py][px] = _current.color;
      }
    }
    final cleared = _clearLines();
    if (cleared > 0 && widget.onLinesCleared != null) {
      widget.onLinesCleared!(_cleared);
    }
    _spawnPiece();
  }

  int _clearLines() {
    var cleared = 0;
    for (int y = _boardHeight - 1; y >= 0; y--) {
      if (_board[y].every((color) => color != null)) {
        _board.removeAt(y);
        _board.insert(
          0,
          List<Color?>.filled(_boardWidth, null),
        );
        cleared++;
        y++;
      }
    }
    _cleared += cleared;
    return cleared;
  }

  int _landingY() {
    var testY = _pieceY;
    while (_canPlace(_current, _pieceX, testY + 1)) {
      testY++;
    }
    return testY;
  }

  @override
  Widget build(BuildContext context) {
    final ghostY = _landingY();
    return GestureDetector(
      onTap: rotate,
      onDoubleTap: hardDrop,
      child: CustomPaint(
        painter: _TetrisBoardPainter(
          board: _board,
          piece: _current,
          pieceX: _pieceX,
          pieceY: _pieceY,
          ghostY: ghostY,
          accent: widget.accent,
        ),
      ),
    );
  }
}

class _TetrisBoardPainter extends CustomPainter {
  _TetrisBoardPainter({
    required this.board,
    required this.piece,
    required this.pieceX,
    required this.pieceY,
    required this.ghostY,
    required this.accent,
  });

  final List<List<Color?>> board;
  final Tetromino piece;
  final int pieceX;
  final int pieceY;
  final int ghostY;
  final Color accent;

  static const int _boardWidth = 10;
  static const int _boardHeight = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _boardWidth;
    final paint = Paint();

    // Grid background
    paint.color = Colors.white.withOpacity(0.04);
    for (int x = 0; x <= _boardWidth; x++) {
      final dx = x * cell;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }
    for (int y = 0; y <= _boardHeight; y++) {
      final dy = y * cell;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }

    // Ghost projection
    for (final block in piece.blocks) {
      final x = (pieceX + block.x) * cell;
      final y = (ghostY + block.y) * cell;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, cell, cell),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = accent.withOpacity(0.18)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = accent.withOpacity(0.28)
          ..style = PaintingStyle.stroke,
      );
    }

    // Settled blocks
    for (int y = 0; y < _boardHeight; y++) {
      for (int x = 0; x < _boardWidth; x++) {
        final color = board[y][x];
        if (color == null) continue;
        _drawBlock(canvas, cell, x, y, color);
      }
    }

    // Active piece
    for (final block in piece.blocks) {
      final x = pieceX + block.x;
      final y = pieceY + block.y;
      if (y < 0) continue;
      _drawBlock(canvas, cell, x, y, piece.color);
    }
  }

  void _drawBlock(
    Canvas canvas,
    double cell,
    int x,
    int y,
    Color color,
  ) {
    final rect = Rect.fromLTWH(
      x * cell,
      y * cell,
      cell,
      cell,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
    final blockPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color,
          Color.alphaBlend(Colors.white.withOpacity(0.2), color),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRRect(rrect, blockPaint);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white.withOpacity(0.12)
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _TetrisBoardPainter oldDelegate) {
    return board != oldDelegate.board ||
        piece != oldDelegate.piece ||
        pieceX != oldDelegate.pieceX ||
        pieceY != oldDelegate.pieceY ||
        ghostY != oldDelegate.ghostY;
  }
}

class Tetromino {
  Tetromino({
    required this.blocks,
    required this.size,
    required this.color,
  });

  final List<Point<int>> blocks;
  final int size;
  final Color color;

  Tetromino rotated() {
    final rotatedBlocks = blocks
        .map(
          (p) => Point<int>(size - 1 - p.y, p.x),
        )
        .toList();
    return Tetromino(
      blocks: rotatedBlocks,
      size: size,
      color: color,
    );
  }

  static List<Tetromino> sunnyShapes(List<Color> palette) {
    final colors = palette.isEmpty ? [Colors.orange] : palette;
    return [
      Tetromino(
        size: 4,
        color: colors[0],
        blocks: [
          const Point(1, 0),
          const Point(1, 1),
          const Point(1, 2),
          const Point(2, 2),
        ],
      ),
      Tetromino(
        size: 3,
        color: colors[1 % colors.length],
        blocks: [
          const Point(0, 1),
          const Point(1, 1),
          const Point(2, 1),
          const Point(1, 0),
        ],
      ),
      Tetromino(
        size: 2,
        color: colors[2 % colors.length],
        blocks: [
          const Point(0, 0),
          const Point(1, 0),
          const Point(0, 1),
          const Point(1, 1),
        ],
      ),
      Tetromino(
        size: 4,
        color: colors[3 % colors.length],
        blocks: [
          const Point(0, 2),
          const Point(1, 2),
          const Point(2, 2),
          const Point(3, 2),
        ],
      ),
    ];
  }
}

class _TemperatureCurvePainter extends CustomPainter {
  _TemperatureCurvePainter({
    required this.temps,
    required this.accent,
  });

  final List<double> temps;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (temps.isEmpty) return;
    final maxTemp = temps.reduce(max);
    final minTemp = temps.reduce(min);
    final range = max(maxTemp - minTemp, 1);
    final dx = temps.length > 1 ? size.width / (temps.length - 1) : size.width;
    final points = <Offset>[];

    for (int i = 0; i < temps.length; i++) {
      final x = i * dx;
      final normalized = (temps[i] - minTemp) / range;
      final y = size.height - (normalized * (size.height * 0.7)) - 10;
      points.add(Offset(x, y));
    }

    final area = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      area.lineTo(p.dx, p.dy);
    }
    area.lineTo(points.last.dx, size.height);
    area.close();

    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          colors: [
            accent.withOpacity(0.18),
            accent.withOpacity(0.04),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = accent
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (final p in points) {
      final rect = Rect.fromCenter(center: p, width: 14, height: 14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()
          ..color = accent
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TemperatureCurvePainter oldDelegate) {
    return temps != oldDelegate.temps || accent != oldDelegate.accent;
  }
}

class _BlockSun extends StatelessWidget {
  const _BlockSun();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: CustomPaint(
        size: const Size(84, 84),
        painter: _BlockSunPainter(),
      ),
    );
  }
}

class _BlockSunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 7;
    final center = Offset(size.width / 2, size.height / 2);
    const sunColor = Color(0xFFFFB84C);
    const rayColor = Color(0xFFFFD28F);

    void drawBlock(Offset offset, Color color) {
      final rect = Rect.fromCenter(
        center: offset,
        width: cell,
        height: cell,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()..color = color,
      );
    }

    // Core
    drawBlock(center, sunColor);
    drawBlock(center.translate(-cell, 0), sunColor);
    drawBlock(center.translate(cell, 0), sunColor);
    drawBlock(center.translate(0, -cell), sunColor);
    drawBlock(center.translate(0, cell), sunColor);

    // Rays
    drawBlock(center.translate(0, -2 * cell), rayColor);
    drawBlock(center.translate(0, 2 * cell), rayColor);
    drawBlock(center.translate(2 * cell, 0), rayColor);
    drawBlock(center.translate(-2 * cell, 0), rayColor);
    drawBlock(center.translate(cell, -cell), rayColor);
    drawBlock(center.translate(-cell, -cell), rayColor);
    drawBlock(center.translate(cell, cell), rayColor);
    drawBlock(center.translate(-cell, cell), rayColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BlockChip extends StatelessWidget {
  const _BlockChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.opacity > 0.2
              ? Colors.white
              : Colors.white.withOpacity(0.9),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
