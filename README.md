A library for parsing timecoded lyrics data from SYLT-frames encoded in mp3 files. (SYnchronized Lyrics/Text)

## Features

- Parse mp3 as byte list into an intermediate `SyltLyricsData` object.
- Export the `SyltLyricsData` as SRT or LRC lyrics text.

## Getting started

- Add the package to your `pubspec.yaml`.
- No further configuration is required.

## Usage

```dart
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
// import 'dart:io';
// List<int> mp3Bytes = List<int> mp3Bytes = File('path/to/my/file.mp3').readAsBytesSync();

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
```

## Additional information

- This package has mainly been developed to be used with my fork of the `christian_lyrics` package (https://github.com/Movinghead333/christian_lyrics). That package requires SRT lyrics for its functionality. These lyrics can be saved in a SYLT frame within the mp3. The `sylt_parser` package can then load the lyrics from the `.mp3` files directly. Both of those packages are used in my app `Flow Lyrix` (https://github.com/Movinghead333/flow_lyrix) which was developed as a replacement for MiniLyrics which does not seem to be working on newer Android versions.
- If you have any problems with the package, then feel free to file an issue.
- If you have feature request and suggestions, then file a pull-request.
