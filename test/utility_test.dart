import 'package:sylt_parser/src/enums.dart';
import 'package:sylt_parser/src/utility.dart';
import 'package:test/test.dart';

void main() {
  group('Utility:', () {
    test('stringFromBytes() test 1', () {
      // Arrange
      // Create nullTerminated string with basic characters resulting in a utf8
      // conforming string
      List<int> bytes = [...'Hello World'.codeUnits, 0];

      // Act
      String parsedString =
          Utility.stringFromBytes(bytes, TextEncoding.iso8859_1);

      //Assert
      expect(parsedString, 'Hello World');
    });
  });
}
