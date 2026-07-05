/// Human-friendly relative timestamps — no external packages needed.
class DateTimeHelper {
  DateTimeHelper._();

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    // Older than a week — show a short date.
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final sameYear = dateTime.year == now.year;
    if (sameYear) {
      return '${months[dateTime.month - 1]} ${dateTime.day}';
    }
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }
}
