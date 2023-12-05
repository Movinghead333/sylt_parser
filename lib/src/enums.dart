/// The [TextEncoding] determines how the text is encoded within the mp3 file.
///
/// The [TextEncoding] can be one byte per character which is indicated
/// by [TextEndcoding.iso8859_1] or two bytes per character when
/// [TextEncoding.unicode] is used.
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

/// The [TimestampFormat] determines how the timestap byte data is to be
/// interpreted.
///
/// The option [TimestampFormat.absTime32BitMpegFrames] indicates that the
/// timestamp is 4 bytes wide an stores the offset in time-units of mpeg frames.
/// The option [TimestampFormat.absTime32BitMilliseconds] also uses 4 bytes for
/// storing a timestamp but uses milliseconds as a unit instead.
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

/// The [ContentType] serves as a means to more clearly describe the data stored
/// within the SYLT-frame.
///
/// This enums defines all content types described within the mp3 standard.
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
