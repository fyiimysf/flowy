enum CyclePhase {
  menstrual('Menstrual', '🌑'),
  follicular('Follicular', '🌱'),
  ovulation('Ovulation', '🌕'),
  luteal('Luteal', '🍂');

  final String name;
  final String icon;

  const CyclePhase(this.name, this.icon);

  String get displayName => '$icon $name';
}

enum Mood {
  happy('😊', 'Happy'),
  neutral('😐', 'Neutral'),
  sad('😢', 'Sad'),
  angry('😡', 'Angry'),
  tired('😴', 'Tired'),
  energetic('💪', 'Energetic');

  final String emoji;
  final String label;

  const Mood(this.emoji, this.label);

  static Mood fromEmoji(String emoji) {
    return Mood.values.firstWhere(
      (m) => m.emoji == emoji,
      orElse: () => Mood.neutral,
    );
  }
}
