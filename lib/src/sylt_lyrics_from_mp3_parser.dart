import 'package:sylt_parser/src/enums.dart';

import 'sylt_lyrics_data.dart';
import 'utility.dart';

class SyltLyricsFromMp3Parser {
  static SyltLyricsData parseMp3BytesToSyltLyricsData(List<int> mp3Bytes) {
    int syltFrameStartingOffset = _findSyltFrameStartingOffset(mp3Bytes);

    int cursor = syltFrameStartingOffset;
    cursor += 4; // Move to frame size offset
    int frameSize = Utility.fourBytesToInt(
      mp3Bytes[cursor],
      mp3Bytes[cursor + 1],
      mp3Bytes[cursor + 2],
      mp3Bytes[cursor + 3],
    );

    // Add 10 for the 10 bytes of frame header not accounted in the frameSize
    int frameEnd = syltFrameStartingOffset + 10 + frameSize;

    // for (int i = syltFrameStartingOffset; i < frameEnd; i++) {
    //   debugPrint(mp3Bytes[i].toString());
    //   debugPrint(
    //       'C${i.toString().padLeft(3, ' ')}: (${String.fromCharCode(mp3Bytes[i])}) or ${mp3Bytes[i]}');
    // }

    cursor += 4; // Skip frame size
    cursor += 2; // Skip frame header flags

    TextEncoding textEncoding = TextEncoding.fromRawByte(mp3Bytes[cursor]);
    cursor += 1; // Skip text encoding

    String languageString = Utility.languageStringFromBytes(
      mp3Bytes[cursor],
      mp3Bytes[cursor + 1],
      mp3Bytes[cursor + 2],
    );
    cursor += 3; // Skip language code

    TimestampFormat timestampFormat =
        TimestampFormat.fromRawByte(mp3Bytes[cursor]);
    cursor += 1; // Skip time stamp format

    ContentType contentType = ContentType.fromRawByte(mp3Bytes[cursor]);
    cursor += 1; // Skip content type

    // Skip all chars of the content descriptor string until we find the null
    // termination character
    String contentDescriptor = '';
    while (mp3Bytes[cursor] != 0) {
      contentDescriptor += String.fromCharCode(mp3Bytes[cursor]);
      cursor++;
      if (textEncoding == TextEncoding.unicode) {
        cursor++;
      }
    }
    cursor++; // Skip content descriptor string null termination character
    if (textEncoding == TextEncoding.unicode) {
      cursor++;
    }

    List<(String, int)> lyricsLines = [];
    List<int> currentLineBytes = [];
    while (cursor < frameEnd) {
      if (mp3Bytes[cursor] == 0 &&
          (textEncoding == TextEncoding.iso8859_1 ||
              mp3Bytes[cursor + 1] == 0)) {
        cursor++; // Skip lyrics line null termination character
        if (textEncoding == TextEncoding.unicode) {
          cursor++;
        }
        for (int i = 0; i < 4; i++) {
          currentLineBytes.add(mp3Bytes[cursor]);
          cursor++;
        }
        lyricsLines.add(_lyricsLineFromBytes(
          currentLineBytes,
          textEncoding,
          nullTerminated: false,
        ));
        currentLineBytes = [];
      } else {
        currentLineBytes.add(mp3Bytes[cursor]);
        cursor++;
        if (textEncoding == TextEncoding.unicode) {
          currentLineBytes.add(mp3Bytes[cursor]);
          cursor++;
        }
      }
    }

    return SyltLyricsData(
        textEncoding: textEncoding,
        language: languageString,
        timestampFormat: timestampFormat,
        contentType: contentType,
        contentDescriptor: contentDescriptor,
        lyricsLines: lyricsLines);
  }

  static (String, int) _lyricsLineFromBytes(
    List<int> bytes,
    TextEncoding textEncoding, {
    bool nullTerminated = true,
  }) {
    List<int> textBytes = bytes.sublist(0, bytes.length - 4);

    String lyricsLine = Utility.stringFromBytes(
      textBytes,
      textEncoding,
      nullTerminated: nullTerminated,
    );

    List<int> timestampBytes = bytes.sublist(bytes.length - 4);
    int timestamp = Utility.fourBytesToInt(
      timestampBytes[0],
      timestampBytes[1],
      timestampBytes[2],
      timestampBytes[3],
    );

    return (lyricsLine, timestamp);
  }

  static String _lineDataToLrcString(List<int> lineData) {
    int l = lineData.length;
    int timeStampInMs = Utility.fourBytesToInt(
        lineData[l - 4], lineData[l - 3], lineData[l - 2], lineData[l - 1]);

    String text = '';
    for (int i = 0; i < l - 4; i++) {
      text += String.fromCharCode(lineData[i]);
    }

    int timeStampInSeconds = timeStampInMs ~/ 1000;
    int timeStampInMinutes = timeStampInSeconds ~/ 60;

    String milliSeconds = (timeStampInMs % 1000).toString().padLeft(3, '0');
    String seconds = (timeStampInSeconds % 60).toString().padLeft(2, '0');
    String minutes = (timeStampInMinutes % 60).toString().padLeft(2, '0');
    String formattedTimeStamp = '[$minutes:$seconds,$milliSeconds]';

    return '$formattedTimeStamp: $text';
  }

  /// Determine the byte offset where the sylt header starts
  static int _findSyltFrameStartingOffset(List<int> mp3Bytes) {
    int s = 83; // S
    int y = 89; // Y
    int l = 76; // L
    int t = 84; // T

    int syltHeaderStartingOffset = -1;

    for (int i = 0; i < mp3Bytes.length - 3; i++) {
      if (mp3Bytes[i] == s &&
          mp3Bytes[i + 1] == y &&
          mp3Bytes[i + 2] == l &&
          mp3Bytes[i + 3] == t) {
        syltHeaderStartingOffset = i;
        break;
      }
    }

    return syltHeaderStartingOffset;
  }
}
