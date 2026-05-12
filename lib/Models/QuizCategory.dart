class QuizCategory {
  static const String all = 'all';
  static const String history = 'history';
  static const String teams = 'teams';
  static const String players = 'players';

  static const List<String> values = [history, teams, players];
  static const List<String> filters = [all, history, teams, players];

  static String label(String category) {
    switch (category) {
      case history:
        return 'History';
      case teams:
        return 'Teams';
      case players:
        return 'Players';
      case all:
        return 'All';
      default:
        return 'General';
    }
  }
}
