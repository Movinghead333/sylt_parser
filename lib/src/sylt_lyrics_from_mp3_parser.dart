import 'package:sylt_parser/src/enums.dart';

import 'exceptions.dart';
import 'sylt_lyrics_data.dart';
import 'utility.dart';

/// This class provides static functionality for parsing the SYLT data within
/// mp3 files into an object containing the time-coded lyrcis data.
class SyltLyricsFromMp3Parser {
  /// Parses the time-coded lyrics data within an mp3 file represented as a byte
  /// list.
  ///
  /// The whole file is search for the startdata that indicates the beginning
  /// of a SYLT frame. When the starting offset is found the data in the frame
  /// is parsed into a [SyltLyricsData] object.
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

  /// Determine the byte offset where the sylt header starts
  static int _findSyltFrameStartingOffset(List<int> mp3Bytes) {
    int s = 83; // S
    int y = 89; // Y
    int l = 76; // L
    int t = 84; // T

    int? syltHeaderStartingOffset;

    for (int i = 0; i < mp3Bytes.length - 3; i++) {
      if (mp3Bytes[i] == s &&
          mp3Bytes[i + 1] == y &&
          mp3Bytes[i + 2] == l &&
          mp3Bytes[i + 3] == t) {
        syltHeaderStartingOffset = i;
        break;
      }
    }

    if (syltHeaderStartingOffset == null) {
      throw NoSyltFrameFoundException();
    }

    return syltHeaderStartingOffset;
  }
}
