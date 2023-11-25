import 'dart:convert';
import 'dart:typed_data';

import 'package:sylt_parser/src/enums.dart';

class Utility {
  static List<int> languageStringToBytes(String languageString) {
    return languageString.codeUnits;
  }

  static String languageStringFromBytes(int byte1, int byte2, int byte3) {
    return String.fromCharCode(byte1) +
        String.fromCharCode(byte2) +
        String.fromCharCode(byte3);
  }

  static List<int> stringToBytes(
    String input,
    TextEncoding textEncoding, {
    bool nullTerminated = true,
  }) {
    List<int> bytes = [];

    List<int> codeUnits = input.codeUnits;

    // For single byte encoding just use the codepoints trimmed to 1 byte
    // if [TextEncoding.unicode] is used we transform the data to 2 bytes per
    // character instead
    List<int> textBytes = textEncoding == TextEncoding.iso8859_1
        ? codeUnits
        : Uint16List.fromList(codeUnits).buffer.asUint8List();

    bytes.addAll(textBytes);

    if (nullTerminated) {
      bytes.add(0);
      if (textEncoding == TextEncoding.unicode) {
        bytes.add(0);
      }
    }

    return bytes;
  }

  static String stringFromBytes(List<int> bytes, TextEncoding textEncoding,
      {bool nullTerminated = true}) {
    if (nullTerminated) {
      int nullTerminationBytes = textEncoding == TextEncoding.iso8859_1 ? 1 : 2;
      bytes = bytes.sublist(0, bytes.length - nullTerminationBytes);
    }

    if (textEncoding == TextEncoding.iso8859_1) {
      return utf8.decode(bytes);
    } else {
      return String.fromCharCodes(
          Uint8List.fromList(bytes).buffer.asUint16List());
    }
  }

  static int fromSyncEncoding(int i1, int i2, int i3, int i4) {
    return i1 << 21 | i2 << 14 | i3 << 7 | i4;
  }

  static int fourBytesToInt(int b1, int b2, int b3, int b4) {
    return b1 << 24 | b2 << 16 | b3 << 8 | b4;
  }

  static List<int> intToFourBytes(int number) {
    int byte1 = number >> 24;
    int byte2 = (number >> 16) & 255;
    int byte3 = (number >> 8) & 255;
    int byte4 = number & 255;

    return [byte1, byte2, byte3, byte4];
  }

  static String timestampInMsToString(int timeStampInMilliSeconds) {
    int timeStampInSeconds = timeStampInMilliSeconds ~/ 1000;
    int timeStampInMinutes = timeStampInSeconds ~/ 60;

    String milliSeconds =
        (timeStampInMilliSeconds % 1000).toString().padLeft(3, '0');
    String seconds = (timeStampInSeconds % 60).toString().padLeft(2, '0');
    String minutes = (timeStampInMinutes % 60).toString().padLeft(2, '0');
    String formattedTimeStamp = '$minutes:$seconds,$milliSeconds';

    return formattedTimeStamp;
  }
}
