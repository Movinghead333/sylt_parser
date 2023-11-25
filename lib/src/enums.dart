enum TextEncoding {
  iso8859_1(rawByte: 0),
  unicode(rawByte: 1);

  final int rawByte;

  const TextEncoding({required this.rawByte});

  static fromRawByte(int rawByte) {
    switch (rawByte) {
      case 0:
        return TextEncoding.iso8859_1;
      case 1:
        return TextEncoding.unicode;
      default:
        throw ArgumentError();
    }
  }
}

enum TimestampFormat {
  absTime32BitMpegFrames(rawByte: 1),
  absTime32BitMilliseconds(rawByte: 2);

  final int rawByte;

  const TimestampFormat({required this.rawByte});

  static fromRawByte(int rawByte) {
    switch (rawByte) {
      case 1:
        return TimestampFormat.absTime32BitMpegFrames;
      case 2:
        return TimestampFormat.absTime32BitMilliseconds;
      default:
        throw ArgumentError();
    }
  }
}

enum ContentType {
  other(
    rawByte: 0,
    description: 'other',
  ),
  lyrics(
    rawByte: 1,
    description: 'lyrics',
  ),
  textTranscription(
    rawByte: 2,
    description: 'text transcription',
  ),
  movementOrPartName(
    rawByte: 3,
    description: 'movement/part name (e.g. "Adagio")',
  ),
  events(
    rawByte: 4,
    description: 'events (e.g. "Don Quijote enters the stage")',
  ),
  chord(
    rawByte: 5,
    description: 'chord (e.g. "Bb F Fsus")',
  ),
  triviaOrPopUpInformation(
    rawByte: 6,
    description: 'trivia/"pop up" information',
  );

  final int rawByte;
  final String description;

  const ContentType({required this.rawByte, required this.description});

  static fromRawByte(int rawByte) {
    switch (rawByte) {
      case 0:
        return ContentType.other;
      case 1:
        return ContentType.lyrics;
      case 2:
        return ContentType.textTranscription;
      case 3:
        return ContentType.movementOrPartName;
      case 4:
        return ContentType.events;
      case 5:
        return ContentType.chord;
      case 6:
        return ContentType.triviaOrPopUpInformation;
      default:
        throw ArgumentError();
    }
  }
}
