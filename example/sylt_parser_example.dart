import 'package:sylt_parser/sylt_parser.dart';

void main() {
  // Create a sample SyltLyricsData object and convert it to bytes. This list of
  // bytes would normally be loaded from an mp3 file.
  List<int> mp3Bytes = SyltLyricsData(
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
  ).toBytes();

  // Parse the list of bytes coming from the mp3 file.
  // The library searches for the SYLT-frame within the ID3 tag and parses it,
  // if one such frame is found.
  SyltLyricsData lyricsData =
      SyltLyricsFromMp3Parser.parseMp3BytesToSyltLyricsData(mp3Bytes);

  // The intermediate data can be parsed to either LRC or SRT lyrics formats:
  String lrcLyrics = lyricsData.toLrc();
  print('LRC lyrics:\n$lrcLyrics');

  String srtLyrics = lyricsData.toSrt();
  print('SRT lyrics:\n$srtLyrics');
}
