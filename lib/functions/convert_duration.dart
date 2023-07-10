String convertDuration(int duration) {
  final minutes = Duration(milliseconds: duration).inMinutes;
  final seconds = Duration(milliseconds: duration).inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
