class RecordedNoteStorage {
  static final List<RecordedNote> _recordedNotes = [];
  static int? startTime;
  static int? endTime;

  static List<RecordedNote> get recordedNotes => _recordedNotes;

  static void addNote(RecordedNote note) {
    _recordedNotes.add(note);
  }

  static void clear() {
    _recordedNotes.clear();
    startTime = null;
    endTime = null;
  }
}

class RecordedNote {
  String filePath;
  int timeStarted;
  int timeEnded;

  RecordedNote({
    required this.filePath,
    required this.timeStarted,
    required this.timeEnded,
  });

  // Конструктор для создания пустой ноты
  RecordedNote.empty()
      : filePath = "",
        timeStarted = 0,
        timeEnded = 0;

  // Сеттеры для поэтапного задания значений
  void setFilePath(String path) {
    filePath = path;
  }

  void setTimeStarted(int time) {
    timeStarted = time;
  }

  void setTimeEnded(int time) {
    timeEnded = time;
  }

  int get duration => timeEnded - timeStarted;
}
