import 'package:sylt_parser/src/enums.dart';
import 'package:sylt_parser/src/sylt_lyrics_data.dart';
import 'package:sylt_parser/src/utility.dart';
import 'package:test/test.dart';

void main() {
  group('SyltLyricsData:', () {
    SyltLyricsData sampleSyltLyricsData = SyltLyricsData(
      textEncoding: TextEncoding.iso8859_1,
      language: 'eng',
      timestampFormat: TimestampFormat.absTime32BitMilliseconds,
      contentType: ContentType.lyrics,
      contentDescriptor: 'MiniLyrics',
      lyricsLines: [
        ('Hey', 255),
        ('Hey', 500),
        ('Hey', 512),
      ],
    );

    test('toBytes() returns correct bytes list 1', () {
      // Arrange
      SyltLyricsData syltLyricsData = sampleSyltLyricsData.copyWith();

      // Act
      List<int> bytes = syltLyricsData.toBytes();

      // Assert
      expect(bytes.length, 10 + 6 + 11 + 24);
      List<int> frameHeaderBytes = [83, 89, 76, 84, 0, 0, 0, 41, 0, 0];
      List<int> frameConfigBytes = [
        TextEncoding.iso8859_1.rawByte,
        ...Utility.languageStringToBytes('eng'),
        TimestampFormat.absTime32BitMilliseconds.rawByte,
        ContentType.lyrics.rawByte,
        ...Utility.stringToBytes('MiniLyrics', TextEncoding.iso8859_1)
      ];
      List<int> lyricsBytes = [
        ...Utility.stringToBytes('Hey', TextEncoding.iso8859_1),
        ...Utility.intToFourBytes(255),
        ...Utility.stringToBytes('Hey', TextEncoding.iso8859_1),
        ...Utility.intToFourBytes(500),
        ...Utility.stringToBytes('Hey', TextEncoding.iso8859_1),
        ...Utility.intToFourBytes(512),
      ];

      expect(bytes.sublist(0, 10), frameHeaderBytes);
      expect(bytes.sublist(10, 27), frameConfigBytes);
      expect(bytes.sublist(27), lyricsBytes);
    });

    test('toBytes() returns correct bytes list 2', () {
      // Arrange
      SyltLyricsData syltLyricsData = SyltLyricsData(
        textEncoding: TextEncoding.unicode,
        language: 'eng',
        timestampFormat: TimestampFormat.absTime32BitMilliseconds,
        contentType: ContentType.lyrics,
        contentDescriptor: 'MiniLyrics',
        lyricsLines: [
          ('Hey', 255),
          ('Hey', 500),
          ('Hey', 512),
        ],
      );

      // Act
      List<int> bytes = syltLyricsData.toBytes();

      // Assert
      int numLyricsBytes = 3 * (2 * 4 + 4);
      int numBytes = 10 + 6 + 2 * 11 + numLyricsBytes;
      expect(bytes.length, numBytes);
      List<int> frameHeaderBytes = [
        83,
        89,
        76,
        84,
        0,
        0,
        0,
        numBytes - 10,
        0,
        0
      ];
      List<int> frameConfigBytes = [
        TextEncoding.unicode.rawByte,
        ...Utility.languageStringToBytes('eng'),
        TimestampFormat.absTime32BitMilliseconds.rawByte,
        ContentType.lyrics.rawByte,
        ...Utility.stringToBytes('MiniLyrics', TextEncoding.unicode)
      ];
      List<int> lyricsBytes = [
        ...Utility.stringToBytes('Hey', TextEncoding.unicode),
        ...Utility.intToFourBytes(255),
        ...Utility.stringToBytes('Hey', TextEncoding.unicode),
        ...Utility.intToFourBytes(500),
        ...Utility.stringToBytes('Hey', TextEncoding.unicode),
        ...Utility.intToFourBytes(512),
      ];

      expect(bytes.sublist(0, 10), frameHeaderBytes);
      expect(bytes.sublist(10, 38), frameConfigBytes);
      expect(bytes.sublist(38), lyricsBytes);
    });

    test('toLrc() returns correct result 1', () {
      // Arrange

      // Act
      String srtLyrics = sampleSyltLyricsData.toLrc();

      // Assert
      String expectedResult = '[00:00,255]: Hey\n'
          '[00:00,500]: Hey\n'
          '[00:00,512]: Hey\n';
      expect(srtLyrics, expectedResult);
    });

    test('toSrt() returns correct result 1', () {
      // Arrange

      // Act
      String srtLyrics = sampleSyltLyricsData.toSrt();

      // Assert
      String expectedResult =
          '1\r\n00:00:00,255 --> 00:00:00,500\r\nHey\r\n\r\n'
          '2\r\n00:00:00,500 --> 00:00:00,512\r\nHey\r\n\r\n'
          '3\r\n00:00:00,512 --> 00:00:00,512\r\nHey\r\n\r\n';
      expect(srtLyrics, expectedResult);
    });
  });
}
