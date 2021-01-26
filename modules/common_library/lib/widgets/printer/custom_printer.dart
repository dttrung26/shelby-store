import 'dart:convert';
import 'package:logger/logger.dart';

class AnsiColor {
  /// ANSI Control Sequence Introducer, signals the terminal for new settings.
  static const ansiEsc = '\x1B[';

  /// Reset all colors and options for current SGRs to terminal defaults.
  static const ansiDefault = '${ansiEsc}0m';

  final int fg;
  final int bg;
  final bool color;

  AnsiColor.none()
      : fg = null,
        bg = null,
        color = false;

  AnsiColor.fg(this.fg)
      : bg = null,
        color = true;

  AnsiColor.bg(this.bg)
      : fg = null,
        color = true;

  @override
  String toString() {
    if (fg != null) {
      return '${ansiEsc}38;5;${fg}m';
    } else if (bg != null) {
      return '${ansiEsc}48;5;${bg}m';
    }
    return '';
  }

  String call(String msg) {
    if (color) {
      return '${this}$msg$ansiDefault';
    } else {
      return msg;
    }
  }

  AnsiColor toFg() => AnsiColor.fg(bg);

  AnsiColor toBg() => AnsiColor.bg(fg);

  /// Defaults the terminal's foreground color without altering the background.
  String get resetForeground => color ? '${ansiEsc}39m' : '';

  /// Defaults the terminal's background color without altering the foreground.
  String get resetBackground => color ? '${ansiEsc}49m' : '';

  static int grey(double level) => 232 + (level.clamp(0.0, 1.0) * 23).round();
}

class CustomPrinter extends LogPrinter {
  static final levelColors = {
    Level.verbose: AnsiColor.fg(AnsiColor.grey(0.5)),
    Level.debug: AnsiColor.none(),
    Level.info: AnsiColor.fg(12),
    Level.warning: AnsiColor.fg(208),
    Level.error: AnsiColor.fg(196),
    Level.wtf: AnsiColor.fg(199),
  };

  static final levelEmojis = {
    Level.verbose: '',
    Level.debug: '🐛 ',
    Level.info: '💡 ',
    Level.warning: '⚠️ ',
    Level.error: '⛔ ',
    Level.wtf: '👾 ',
  };

  static final stackTraceRegex = RegExp(r'#[0-9]+[\s]+(.+) \(([^\s]+)\)');

  static DateTime _startTime;

  final int lineLength;

  final bool printTime;

  CustomPrinter({this.lineLength = 120, this.printTime = false}) {
    _startTime ??= DateTime.now();
  }

  @override
  void log(LogEvent event) {
    final messageStr = stringifyMessage(event.message);

    String stackTraceStr;

    final errorStr = event.error?.toString();

    String timeStr;
    if (printTime) {
      timeStr = getTime();
    }

    formatAndPrint(event.level, messageStr, timeStr, errorStr, stackTraceStr);
  }

  String formatStackTrace(StackTrace stackTrace, int methodCount) {
    final lines = stackTrace.toString().split('\n');

    final formatted = <String>[];
    var count = 0;
    for (final line in lines) {
      final match = stackTraceRegex.matchAsPrefix(line);
      if (match != null) {
        if (match.group(2).startsWith('package:logger')) {
          continue;
        }
        final newLine = '#$count   ${match.group(1)} (${match.group(2)})';
        formatted.add(newLine.replaceAll('<anonymous closure>', '()'));
        if (++count == methodCount) {
          break;
        }
      } else {
        formatted.add(line);
      }
    }

    if (formatted.isEmpty) {
      return null;
    } else {
      return formatted.join('\n');
    }
  }

  String getTime() {
    String _threeDigits(int n) {
      if (n >= 100) {
        return '$n';
      }
      if (n >= 10) {
        return '0$n';
      }
      return '00$n';
    }

    String _twoDigits(int n) {
      if (n >= 10) {
        return '$n';
      }
      return '0$n';
    }

    final now = DateTime.now();
    final h = _twoDigits(now.hour);
    final min = _twoDigits(now.minute);
    final sec = _twoDigits(now.second);
    final ms = _threeDigits(now.millisecond);
    final timeSinceStart = now.difference(_startTime).toString();
    return '$h:$min:$sec.$ms (+$timeSinceStart)';
  }

  String stringifyMessage(dynamic message) {
    if (message is Map || message is Iterable) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(message);
    } else {
      return message.toString();
    }
  }

  AnsiColor _getLevelColor(Level level) {
    return levelColors[level];
  }

  AnsiColor _getErrorColor(Level level) {
    if (level == Level.wtf) {
      return levelColors[Level.wtf].toBg();
    } else {
      return levelColors[Level.error].toBg();
    }
  }

  String _getEmoji(Level level) {
    return levelEmojis[level];
  }

  void formatAndPrint(Level level, String message, String time, String error,
      String stacktrace) {
    final color = _getLevelColor(level);

    if (error != null) {
      final errorColor = _getErrorColor(level);
      for (final line in error.split('\n')) {
        println(errorColor(line));
      }
    }

    if (stacktrace != null) {
      for (final line in stacktrace.split('\n')) {
        println('$color$line');
      }
    }

    if (time != null) {
      println(color('$time'));
    }

    final emoji = _getEmoji(level);
    for (final line in message.split('\n')) {
      println(color('$emoji$line'));
    }
  }
}
