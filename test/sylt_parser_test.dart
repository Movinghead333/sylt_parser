import 'package:sylt_parser/src/enums.dart';
import 'package:sylt_parser/src/sylt_lyrics_data.dart';
import 'package:sylt_parser/src/utility.dart';
import 'package:test/test.dart';

void main() {
  group('SyltLyricsData:', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('toBytes() returns correct bytes list 1', () {
      // Arrange
      SyltLyricsData syltLyricsData = SyltLyricsData(
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
      expect(bytes.length, 10 + 6 + 2 * 11 + numLyricsBytes);
    });
  });

  // group('A group of tests', () {
  //   final awesome = Awesome();

  //   setUp(() {
  //     // Additional setup goes here.
  //   });

  //   test('First Test', () {
  //     expect(awesome.isAwesome, isTrue);
  //   });
  // });
}
