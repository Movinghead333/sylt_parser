import 'enums.dart';
import 'utility.dart';

class SyltLyricsData {
  final TextEncoding textEncoding;
  final String language;
  final TimestampFormat timestampFormat;
  final ContentType contentType;
  final String contentDescriptor;
  final List<(String, int)> lyricsLines;

  SyltLyricsData({
    required this.textEncoding,
    required this.language,
    required this.timestampFormat,
    required this.contentType,
    required this.contentDescriptor,
    required this.lyricsLines,
  });

  SyltLyricsData copyWith({
    TextEncoding? textEncoding,
    String? language,
    TimestampFormat? timestampFormat,
    ContentType? contentType,
    String? contentDescriptor,
    List<(String, int)>? lyricsLines,
  }) {
    return SyltLyricsData(
        textEncoding: textEncoding ?? this.textEncoding,
        language: language ?? this.language,
        timestampFormat: timestampFormat ?? this.timestampFormat,
        contentType: contentType ?? this.contentType,
        contentDescriptor: contentDescriptor ?? this.contentDescriptor,
        lyricsLines: lyricsLines ?? this.lyricsLines);
  }

  List<int> toBytes() {
    int s = 83; // S
    int y = 89; // Y
    int l = 76; // L
    int t = 84; // T

    List<int> frameHeaderIdBytes = [s, y, l, t];
    List<int> frameHeaderSizeBytes = [0, 0, 0, 0];
    List<int> frameHeaderFlagsBytes = [0, 0];

    List<int> contentDescriptorBytes =
        Utility.stringToBytes(contentDescriptor, textEncoding);

    List<int> lyricsBytes = [];

    for ((String, int) lineData in lyricsLines) {
      lyricsBytes.addAll(Utility.stringToBytes(lineData.$1, textEncoding));
      lyricsBytes.addAll(Utility.intToFourBytes(lineData.$2));
    }

    int frameSize = 6 + contentDescriptorBytes.length + lyricsBytes.length;
    frameHeaderSizeBytes = Utility.intToFourBytes(frameSize);

    return [
      ...frameHeaderIdBytes,
      ...frameHeaderSizeBytes,
      ...frameHeaderFlagsBytes,
      textEncoding.rawByte,
      ...Utility.languageStringToBytes(language),
      timestampFormat.rawByte,
      contentType.rawByte,
      ...contentDescriptorBytes,
      ...lyricsBytes,
    ];
  }

  /// Convert to format
  /// 1\r\n00:00:01,000 --> 00:00:29,950\r\nHere goes the lyrics\r\n\r\n...
  static String syltLyricsToSrtLyrics(List<String> syltLyrics) {
    int counter = 1;
    String lastTimestamp = '00:00:00,000';
    String lyrics = '';
    for (String line in syltLyrics) {
      String timeStamp = '00:${line.substring(1, 10)}';
      String text = line.substring(12, line.length);
      String newLine =
          '$counter\r\n$lastTimestamp --> $timeStamp\r\n$text\r\n\r\n';
      lyrics += newLine;

      lastTimestamp = timeStamp;
      counter++;
    }

    return lyrics;
  }

  String toLrc() {
    String lyrics = '';

    for ((String, int) lineData in lyricsLines) {
      String timestamp = Utility.timestampInMsToString(lineData.$2);
      lyrics += '[$timestamp]: ${lineData.$1}\n';
    }

    return lyrics;
  }

  String toSrt() {
    String lyrics = '';

    for (int i = 0; i < lyricsLines.length; i++) {
      String timestamp = Utility.timestampInMsToString(lyricsLines[i].$2);

      String nextTimestamp = '';
      if (i + 1 == lyricsLines.length) {
        nextTimestamp = Utility.timestampInMsToString(
            lyricsLines[lyricsLines.length - 1].$2);
      } else {
        nextTimestamp = Utility.timestampInMsToString(lyricsLines[i + 1].$2);
      }

      String newLine =
          '${i + 1}\r\n00:$timestamp --> 00:$nextTimestamp\r\n${lyricsLines[i].$1}\r\n\r\n';
      lyrics += newLine;
    }

    return lyrics;
  }
}
