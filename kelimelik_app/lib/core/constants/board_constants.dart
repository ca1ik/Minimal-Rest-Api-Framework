/// Board layout constants.
/// Contains bonus layouts, letter scores, and letter counts for Scrabble.
library;

import '../l10n/app_strings.dart';

/// Bonus cell types
enum BonusType {
  none('__'),
  h2('H2'), // Harf x2
  h3('H3'), // Harf x3
  k2('K2'), // Kelime x2
  k3('K3'), // Kelime x3
  start('START');

  const BonusType(this.code);
  final String code;

  static BonusType fromCode(String code) => switch (code) {
    'H2' => BonusType.h2,
    'H3' => BonusType.h3,
    'K2' => BonusType.k2,
    'K3' => BonusType.k3,
    'START' => BonusType.start,
    _ => BonusType.none,
  };
}

/// Standard 15x15 Kelimelik board bonus layout
const List<List<String>> bonusLayoutKlasik = [
  [
    '__',
    '__',
    'K3',
    '__',
    '__',
    'H2',
    '__',
    '__',
    '__',
    'H2',
    '__',
    '__',
    'K3',
    '__',
    '__',
  ],
  [
    '__',
    'H3',
    '__',
    '__',
    '__',
    '__',
    'H2',
    '__',
    'H2',
    '__',
    '__',
    '__',
    '__',
    'H3',
    '__',
  ],
  [
    'K3',
    '__',
    '__',
    '__',
    '__',
    '__',
    '__',
    'K2',
    '__',
    '__',
    '__',
    '__',
    '__',
    '__',
    'K3',
  ],
  [
    '__',
    '__',
    '__',
    'K2',
    '__',
    '__',
    '__',
    '__',
    '__',
    '__',
    '__',
    'K2',
    '__',
    '__',
    '__',
  ],
  [
    '__',
    '__',
    '__',
    '__',
    'H3',
    '__',
    '__',
    '__',
    '__',
    '__',
    'H3',
    '__',
    '__',
    '__',
    '__',
  ],
  [
    'H2',
    '__',
    '__',
    '__',
    '__',
    'H2',
    '__',
    '__',
    '__',
    'H2',
    '__',
    '__',
    '__',
    '__',
    'H2',
  ],
  [
    '__',
    'H2',
    '__',
    '__',
    '__',
    '__',
    'H2',
    '__',
    'H2',
    '__',
    '__',
    '__',
    '__',
    'H2',
    '__',
  ],
  [
    '__',
    '__',
    'K2',
    '__',
    '__',
    '__',
    '__',
    'START',
    '__',
    '__',
    '__',
    '__',
    'K2',
    '__',
    '__',
  ],
  [
    '__',
    'H2',
    '__',
    '__',
    '__',
    '__',
    'H2',
    '__',
    'H2',
    '__',
    '__',
    '__',
    '__',
    'H2',
    '__',
  ],
  [
    'H2',
    '__',
    '__',
    '__',
    '__',
    'H2',
    '__',
    '__',
    '__',
    'H2',
    '__',
    '__',
    '__',
    '__',
    'H2',
  ],
  [
    '__',
    '__',
    '__',
    '__',
    'H3',
    '__',
    '__',
    '__',
    '__',
    '__',
    'H3',
    '__',
    '__',
    '__',
    '__',
  ],
  [
    '__',
    '__',
    '__',
    'K2',
    '__',
    '__',
    '__',
    '__',
    '__',
    '__',
    '__',
    'K2',
    '__',
    '__',
    '__',
  ],
  [
    'K3',
    '__',
    '__',
    '__',
    '__',
    '__',
    '__',
    'K2',
    '__',
    '__',
    '__',
    '__',
    '__',
    '__',
    'K3',
  ],
  [
    '__',
    'H3',
    '__',
    '__',
    '__',
    '__',
    'H2',
    '__',
    'H2',
    '__',
    '__',
    '__',
    '__',
    'H3',
    '__',
  ],
  [
    '__',
    '__',
    'K3',
    '__',
    '__',
    'H2',
    '__',
    '__',
    '__',
    'H2',
    '__',
    '__',
    'K3',
    '__',
    '__',
  ],
];

/// 9x9 "5'lik" board bonus layout
const List<List<String>> bonusLayout5lik = [
  ['K3', '__', '__', '__', 'H3', '__', '__', '__', 'K3'],
  ['__', 'K2', '__', 'H2', '__', 'H2', '__', 'K2', '__'],
  ['__', '__', 'H3', '__', '__', '__', 'H3', '__', '__'],
  ['__', 'H2', '__', '__', '__', '__', '__', 'H2', '__'],
  ['H3', '__', '__', '__', 'START', '__', '__', '__', 'H3'],
  ['__', 'H2', '__', '__', '__', '__', '__', 'H2', '__'],
  ['__', '__', 'H3', '__', '__', '__', 'H3', '__', '__'],
  ['__', 'K2', '__', 'H2', '__', 'H2', '__', 'K2', '__'],
  ['K3', '__', '__', '__', 'H3', '__', '__', '__', 'K3'],
];

/// Turkish letter scores for Kelimelik
const Map<String, int> harfPuanlari = {
  'a': 1,
  'b': 3,
  'c': 4,
  'ç': 4,
  'd': 3,
  'e': 1,
  'f': 7,
  'g': 5,
  'ğ': 8,
  'h': 5,
  'ı': 2,
  'i': 1,
  'j': 10,
  'k': 1,
  'l': 1,
  'm': 2,
  'n': 1,
  'o': 2,
  'ö': 7,
  'p': 5,
  'r': 1,
  's': 2,
  'ş': 4,
  't': 1,
  'u': 2,
  'ü': 3,
  'v': 7,
  'y': 3,
  'z': 4,
};

/// Turkish letter counts in the tile bag (total 104 + 2 jokers)
const Map<String, int> harfSayilari = {
  'A': 12,
  'B': 2,
  'C': 2,
  'Ç': 2,
  'D': 2,
  'E': 8,
  'F': 1,
  'G': 1,
  'Ğ': 1,
  'H': 1,
  'I': 4,
  'İ': 7,
  'J': 1,
  'K': 7,
  'L': 7,
  'M': 4,
  'N': 5,
  'O': 3,
  'Ö': 1,
  'P': 1,
  'R': 6,
  'S': 3,
  'Ş': 2,
  'T': 5,
  'U': 3,
  'Ü': 2,
  'V': 1,
  'Y': 2,
  'Z': 2,
  '*': 2,
};

/// Turkish alphabet order for sorting
const List<String> turkceAlfabe = [
  'a',
  'b',
  'c',
  'ç',
  'd',
  'e',
  'f',
  'g',
  'ğ',
  'h',
  'ı',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'ö',
  'p',
  'r',
  's',
  'ş',
  't',
  'u',
  'ü',
  'v',
  'y',
  'z',
];

// ═══════════════════════════════════════════════════════════════════
// English Scrabble constants
// ═══════════════════════════════════════════════════════════════════

/// English letter scores (standard Scrabble)
const Map<String, int> englishLetterScores = {
  'a': 1, 'b': 3, 'c': 3, 'd': 2, 'e': 1, 'f': 4, 'g': 2,
  'h': 4, 'i': 1, 'j': 8, 'k': 5, 'l': 1, 'm': 3, 'n': 1,
  'o': 1, 'p': 3, 'q': 10, 'r': 1, 's': 1, 't': 1, 'u': 1,
  'v': 4, 'w': 4, 'x': 8, 'y': 4, 'z': 10,
};

/// English letter counts in the tile bag (total 98 + 2 blanks)
const Map<String, int> englishLetterCounts = {
  'A': 9, 'B': 2, 'C': 2, 'D': 4, 'E': 12, 'F': 2, 'G': 3,
  'H': 2, 'I': 9, 'J': 1, 'K': 1, 'L': 4, 'M': 2, 'N': 6,
  'O': 8, 'P': 2, 'Q': 1, 'R': 6, 'S': 4, 'T': 6, 'U': 4,
  'V': 2, 'W': 2, 'X': 1, 'Y': 2, 'Z': 1, '*': 2,
};

/// English alphabet order
const List<String> englishAlphabet = [
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
  'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
];

// ═══════════════════════════════════════════════════════════════════
// Language-aware accessors
// ═══════════════════════════════════════════════════════════════════

/// Returns the letter scores for the current language.
Map<String, int> get activeLetterScores =>
    S.currentLanguage == AppLanguage.en ? englishLetterScores : harfPuanlari;

/// Returns the letter counts for the current language.
Map<String, int> get activeLetterCounts =>
    S.currentLanguage == AppLanguage.en ? englishLetterCounts : harfSayilari;

/// Returns the alphabet for the current language.
List<String> get activeAlphabet =>
    S.currentLanguage == AppLanguage.en ? englishAlphabet : turkceAlfabe;

/// Dictionary asset path for the current language.
String get activeDictionaryPath =>
    S.currentLanguage == AppLanguage.en
        ? 'Assets/english_dict.txt'
        : 'Assets/sozluk.txt';
