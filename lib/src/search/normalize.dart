/// Folds a string for the default and `:contains` searches, R4B 3.1.1.4.8:
/// "This search is insensitive to casing and included combining characters,
/// like accents or other diacritical marks. Punctuation and non-significant
/// whitespace (e.g. repeated space characters, tab vs space) should also be
/// ignored."
///
/// So: lower-cased; precomposed accented letters folded to their base by
/// the table below; combining marks (U+0300–U+036F, the diacritics a
/// decomposed `é` is written with) dropped; punctuation turned to a space;
/// runs of whitespace collapsed to one space and the ends trimmed. Public
/// because BOTH sides have to fold identically: the value going into the
/// index and the value coming in on a query. Fold one and not the other and an
/// accented name becomes unfindable.
String normalizeSearchString(String input) {
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    if (rune >= 0x300 && rune <= 0x36F) {
      continue;
    }
    buffer.write(_foldAccents[rune] ?? String.fromCharCode(rune));
  }
  // Punctuation becomes a space, not nothing, so `Jose-Maria` and
  // `Jose Maria` fold alike and a name's words stay separable; the section
  // leaves a phone number's dashes to the server's discretion ("a server
  // might remove all spaces and - characters"), and this treats them the
  // same as any other punctuation.
  return buffer
      .toString()
      .replaceAll(_punctuation, ' ')
      .replaceAll(_whitespaceRun, ' ')
      .trim();
}

/// Unicode punctuation. Structural, so case-sensitive on purpose.
final RegExp _punctuation = RegExp(r'\p{P}', unicode: true);

/// One or more whitespace characters of any kind.
final RegExp _whitespaceRun = RegExp(r'\s+');

/// Lower-case accented letters mapped to their base letter.
///
/// Built from the Latin-1 Supplement and Latin Extended-A blocks. Only the
/// lower-case forms are needed because the input is lower-cased first.
const _foldAccents = <int, String>{
  0xE0: 'a',
  0xE1: 'a',
  0xE2: 'a',
  0xE3: 'a',
  0xE4: 'a',
  0xE5: 'a',
  0xE6: 'ae',
  0xE7: 'c',
  0xE8: 'e',
  0xE9: 'e',
  0xEA: 'e',
  0xEB: 'e',
  0xEC: 'i',
  0xED: 'i',
  0xEE: 'i',
  0xEF: 'i',
  0xF0: 'd',
  0xF1: 'n',
  0xF2: 'o',
  0xF3: 'o',
  0xF4: 'o',
  0xF5: 'o',
  0xF6: 'o',
  0xF8: 'o',
  0xF9: 'u',
  0xFA: 'u',
  0xFB: 'u',
  0xFC: 'u',
  0xFD: 'y',
  0xFF: 'y',
  0xFE: 'th',
  0xDF: 'ss',
  0x101: 'a',
  0x103: 'a',
  0x105: 'a',
  0x107: 'c',
  0x109: 'c',
  0x10B: 'c',
  0x10D: 'c',
  0x10F: 'd',
  0x111: 'd',
  0x113: 'e',
  0x115: 'e',
  0x117: 'e',
  0x119: 'e',
  0x11B: 'e',
  0x11D: 'g',
  0x11F: 'g',
  0x121: 'g',
  0x123: 'g',
  0x125: 'h',
  0x127: 'h',
  0x129: 'i',
  0x12B: 'i',
  0x12D: 'i',
  0x12F: 'i',
  0x131: 'i',
  0x133: 'ij',
  0x135: 'j',
  0x137: 'k',
  0x13A: 'l',
  0x13C: 'l',
  0x13E: 'l',
  0x140: 'l',
  0x142: 'l',
  0x144: 'n',
  0x146: 'n',
  0x148: 'n',
  0x14B: 'n',
  0x14D: 'o',
  0x14F: 'o',
  0x151: 'o',
  0x153: 'oe',
  0x155: 'r',
  0x157: 'r',
  0x159: 'r',
  0x15B: 's',
  0x15D: 's',
  0x15F: 's',
  0x161: 's',
  0x163: 't',
  0x165: 't',
  0x167: 't',
  0x169: 'u',
  0x16B: 'u',
  0x16D: 'u',
  0x16F: 'u',
  0x171: 'u',
  0x173: 'u',
  0x175: 'w',
  0x177: 'y',
  0x17A: 'z',
  0x17C: 'z',
  0x17E: 'z',
};
