import 'package:sylt_parser/src/enums.dart';
import 'package:sylt_parser/src/sylt_lyrics_data.dart';
import 'package:sylt_parser/src/sylt_lyrics_from_mp3_parser.dart';
import 'package:test/test.dart';

void main() {
  group('SyltLyricsFromMp3Parser:', () {
    SyltLyricsData sampleSyltLyricsData = SyltLyricsData(
      textEncoding: TextEncoding.iso8859_1,
      language: 'eng',
      timestampFormat: TimestampFormat.absTime32BitMilliseconds,
      contentType: ContentType.lyrics,
      contentDescriptor: 'Content Descriptor',
      lyricsLines: [
        ('This', 500),
        ('is', 1000),
        ('test', 1500),
        ('lyrics', 2000),
      ],
    );

    test('parseMp3BytesToSyltLyricsData parses bytes correctly 1', () {
      // Arrange
      List<int> syltFrameBytes = sampleSyltLyricsData.toBytes();

      // Act
      SyltLyricsData parsedSyltLyricsData =
          SyltLyricsFromMp3Parser.parseMp3BytesToSyltLyricsData(syltFrameBytes);

      // Assert
      expect(parsedSyltLyricsData.textEncoding, TextEncoding.iso8859_1);
      expect(parsedSyltLyricsData.language, 'eng');
      expect(parsedSyltLyricsData.timestampFormat,
          TimestampFormat.absTime32BitMilliseconds);
      expect(parsedSyltLyricsData.contentType, ContentType.lyrics);
      expect(parsedSyltLyricsData.contentDescriptor, 'Content Descriptor');
      expect(parsedSyltLyricsData.lyricsLines, [
        ('This', 500),
        ('is', 1000),
        ('test', 1500),
        ('lyrics', 2000),
      ]);
    });

    test('parseMp3BytesToSyltLyricsData parses bytes correctly 2', () {
      // Arrange
      SyltLyricsData syltLyricsData =
          sampleSyltLyricsData.copyWith(textEncoding: TextEncoding.unicode);
      List<int> syltFrameBytes = syltLyricsData.toBytes();

      // Act
      SyltLyricsData parsedSyltLyricsData =
          SyltLyricsFromMp3Parser.parseMp3BytesToSyltLyricsData(syltFrameBytes);

      // Assert
      expect(parsedSyltLyricsData.textEncoding, TextEncoding.unicode);
      expect(parsedSyltLyricsData.language, 'eng');
      expect(parsedSyltLyricsData.timestampFormat,
          TimestampFormat.absTime32BitMilliseconds);
      expect(parsedSyltLyricsData.contentType, ContentType.lyrics);
      expect(parsedSyltLyricsData.contentDescriptor, 'Content Descriptor');
      expect(parsedSyltLyricsData.lyricsLines, [
        ('This', 500),
        ('is', 1000),
        ('test', 1500),
        ('lyrics', 2000),
      ]);
    });
  });
}
