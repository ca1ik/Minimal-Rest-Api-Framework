/// Localization strings for English and Turkish.
enum AppLanguage { en, tr }

class S {
  S._();

  static AppLanguage _lang = AppLanguage.en;
  static AppLanguage get currentLanguage => _lang;
  static void setLanguage(AppLanguage lang) => _lang = lang;

  // ─── App-level ────────────────────────────────────────────────────
  static String get appTitle => _s('ScrabbleBot', 'Kelimelik Solver');
  static String get brandName => _s('ScrabbleBot Pro', 'Kelimelik Pro');

  // ─── Sidebar / Navigation ────────────────────────────────────────
  static String get navGame => _s('Game', 'Oyun');
  static String get navDashboard => _s('Dashboard', 'Dashboard');
  static String get navGameBoard => _s('Game Board', 'Oyun Tahtası');
  static String get navAnalytics => _s('Analytics', 'Analiz');
  static String get navTools => _s('Tools', 'Araçlar');
  static String get navDictionary => _s('Dictionary', 'Sözlük');
  static String get navLetterSwap => _s('Letter Swap', 'Harf Değişim');
  static String get navOpponentAnalysis =>
      _s('Opponent Analysis', 'Rakip Analizi');
  static String get navSettings => _s('Settings', 'Ayarlar');
  static String get searchHint => _s('Search...', 'Ara...');

  // ─── Game Screen ─────────────────────────────────────────────────
  static String get gameBoard => _s('Game Board', 'Oyun Tahtası');
  static String get classic15 => _s('15×15 Classic', '15×15 Klasik');
  static String get quick9 => _s('9×9 Quick', '9×9 5\'lik');
  static String get myLetters => _s('My Letters', 'Elimdeki Harfler');
  static String get jokerHint => _s('Use * for joker', 'Joker için * kullanın');
  static String get enterLetters => _s('Enter letters...', 'Harfleri girin...');
  static String get calculating => _s('Calculating...', 'Hesaplanıyor...');
  static String get findMoves => _s('Find Moves', 'Hamle Bul');
  static String get opponentAnalysisF6 =>
      _s('Opponent Analysis (F6)', 'Rakip Analizi (F6)');
  static String get resetBoard =>
      _s('Reset Board (Ctrl+Del)', 'Tahtayı Sıfırla (Ctrl+Del)');
  static String get playSelectedMove =>
      _s('Play Selected Move', 'Seçili Hamleyi Oyna');

  // ─── Dashboard Screen ────────────────────────────────────────────
  static String get dashboard => _s('Dashboard', 'Dashboard');
  static String get dashboardSubtitle => _s(
    'Your ScrabbleBot game statistics',
    'Kelimelik Pro oyun istatistiklerin',
  );
  static String get dictionarySize => _s('Dictionary Size', 'Sözlük Boyutu');
  static String get totalWords => _s('Total words', 'Toplam Türkçe kelime');
  static String get active => _s('Active', 'Aktif');
  static String get movesFound => _s('Moves Found', 'Bulunan Hamleler');
  static String get lastSearchResult =>
      _s('Last search result', 'Son arama sonucu');
  static String get highestScore => _s('Highest Score', 'En Yüksek Puan');
  static String get bestMoveOnBoard =>
      _s('Best move on current board', 'Mevcut tahtadaki en iyi hamle');
  static String get strong => _s('Strong', 'Güçlü');
  static String get remainingLetters =>
      _s('Remaining Letters', 'Kalan Harfler');
  static String get tilesLeftInBag =>
      _s('Tiles left in bag', 'Torbada kalan harf sayısı');
  static String get scoreDistribution =>
      _s('Score Distribution', 'Puan Dağılımı');
  static String get first30Chart =>
      _s('Score chart of first 30 moves', 'İlk 30 hamlenin puan grafiği');
  static String get goToGameBoard => _s(
    'Go to the game board to find moves',
    'Hamle bulmak için oyun tahtasına geçin',
  );
  static String get topMoves => _s('Top Moves', 'En İyi Hamleler');
  static String get top10 => _s('Top 10', 'İlk 10');
  static String get noMovesCalculated =>
      _s('No moves calculated yet', 'Henüz hamle hesaplanmadı');

  // ─── Dictionary Screen ───────────────────────────────────────────
  static String get dictionary => _s('Dictionary', 'Sözlük');
  static String get dictSubtitle => _s(
    'Search, verify, and manage words',
    'Kelime ara, kontrol et ve sözlüğü yönet',
  );
  static String get searchWord => _s('Search word...', 'Kelime ara...');
  static String get valid => _s('Valid', 'Geçerli');
  static String get notFound => _s('Not Found', 'Bulunamadı');
  static String get totalWordCount => _s('Total Words', 'Toplam Kelime');
  static String get matching => _s('Matching', 'Eşleşen');
  static String get avgLength => _s('Avg Length', 'Ortalama Uzunluk');
  static String get typeToSearch =>
      _s('Type above to search words', 'Kelime aramak için yukarıya yazın');
  static String noMatchingWord(String q) =>
      _s('No words matching "$q"', '"$q" ile eşleşen kelime yok');
  static String get copy => _s('Copy', 'Kopyala');
  static String dictLoadError(String e) =>
      _s('Dictionary load failed: $e', 'Sözlük yüklenemedi: $e');

  // ─── Analytics Screen ────────────────────────────────────────────
  static String get analytics => _s('Analytics', 'Analiz');
  static String get analyticsSubtitle => _s(
    'Statistical analysis of found moves',
    'Bulunan hamlelerin istatistiksel analizi',
  );
  static String get totalMoves => _s('Total Moves', 'Toplam Hamle');
  static String get allFoundMoves =>
      _s('all found moves', 'bulunan tüm hamleler');
  static String get points => _s('pts', 'puan');
  static String get avgScore => _s('Average Score', 'Ortalama Puan');
  static String get perMove => _s('per move', 'hamle başına');
  static String get avgWordLength =>
      _s('Avg Word Length', 'Ort. Kelime Uzunluğu');
  static String get letters => _s('letters', 'harf');
  static String get noMovesFound =>
      _s('No moves found yet', 'Henüz hamle bulunamadı');
  static String get directionDist =>
      _s('Direction Distribution', 'Yön Dağılımı');
  static String get noData => _s('No data', 'Veri yok');
  static String get horizontal => _s('Horizontal', 'Yatay');
  static String get vertical => _s('Vertical', 'Dikey');
  static String get mostUsedLetters =>
      _s('Most Used Letters', 'En Çok Kullanılan Harfler');

  // ─── Settings Screen ─────────────────────────────────────────────
  static String get settings => _s('Settings', 'Ayarlar');
  static String get settingsSubtitle => _s(
    'Theme, game type, and app settings',
    'Tema, oyun tipi ve uygulama ayarları',
  );
  static String get theme => _s('Theme', 'Tema');
  static String get gameType => _s('Game Type', 'Oyun Tipi');
  static String get classicBoard => _s('Classic (15×15)', 'Klasik (15×15)');
  static String get classicDesc =>
      _s('Standard Scrabble board', 'Standart Kelimelik tahtası');
  static String get quickBoard => _s('Quick (9×9)', '5\'lik (9×9)');
  static String get quickDesc => _s('Fast game mode', 'Hızlı oyun modu');
  static String get language => _s('Language', 'Dil');
  static String get english => _s('English', 'İngilizce');
  static String get turkish => _s('Turkish', 'Türkçe');
  static String get about => _s('About', 'Hakkında');
  static String get application => _s('Application', 'Uygulama');
  static String get version => _s('Version', 'Sürüm');
  static String get platform => _s('Platform', 'Platform');
  static String get engine => _s('Engine', 'Motor');
  static String get aboutDesc => _s(
    'Advanced move finder for Scrabble. '
        'Calculates all valid moves and ranks them by score.',
    'Kelimelik (Scrabble) oyunu için gelişmiş hamle bulucu. '
        'Tüm geçerli hamleleri hesaplar ve puan sırasına göre listeler.',
  );
  static String get keyboardShortcuts =>
      _s('Keyboard Shortcuts', 'Kısayol Tuşları');
  static String get scFindMoves => _s('Find Moves', 'Hamle Bul');
  static String get scReset => _s('Reset', 'Sıfırla');
  static String get scPlay => _s('Play', 'Oyna');
  static String get scNavigate => _s('Navigate', 'Gezin');
  static String get scDeleteLetter => _s('Delete Letter', 'Harf Sil');

  // ─── Opponent Analysis Screen ────────────────────────────────────
  static String get opponentAnalysis =>
      _s('Opponent Analysis', 'Rakip Analizi');
  static String get opponentSubtitle => _s(
    'Possible moves based on remaining tiles in the bag',
    'Torbadaki harflere göre rakibin yapabileceği hamleler',
  );
  static String get bagStatus => _s('Bag Status', 'Torba Durumu');
  static String tilesRemaining(int n) =>
      _s('$n tiles remaining', '$n taş kaldı');
  static String get findOpponentMoves =>
      _s('Find Opponent Moves', 'Rakip Hamleleri Bul');
  static String get runOpponentAnalysis => _s(
    'Run opponent analysis to\nsee possible moves',
    'Rakip analizi çalıştırarak\nolası hamleleri görün',
  );
  static String get possibleOpponentMoves =>
      _s('Possible Opponent Moves', 'Olası Rakip Hamleleri');
  static String bestNMoves(int n) => _s('Best $n moves', 'En iyi $n hamle');

  // ─── Letter Swap Screen ──────────────────────────────────────────
  static String get letterSwap => _s('Letter Swap', 'Harf Değişim');
  static String get letterSwapSubtitle => _s(
    'Select which letters you want to swap',
    'Hangi harfleri değiştirmek istediğinizi seçin',
  );
  static String get enterHandFirst => _s(
    'First enter your letters on the Game Board',
    'Önce Oyun Tahtası\'nda elinizdeki harfleri girin',
  );
  static String get yourLetters => _s('Your Letters', 'Elinizdeki Harfler');
  static String get tapToSwap => _s(
    'Tap the letters you want to swap',
    'Değiştirmek istediğiniz harfleri tıklayın',
  );
  static String get swapAnalysis => _s('Swap Analysis', 'Değişim Analizi');
  static String lettersSelected(int n) =>
      _s('$n letters selected', '$n harf seçili');
  static String get selectLettersToSwap => _s(
    'Select the letters you want to swap',
    'Değiştirmek istediğiniz harfleri seçin',
  );
  static String get discardedLetters =>
      _s('Discarded letters', 'Atılan harfler');
  static String get lostPoints => _s('Lost points', 'Kaybedilen puan');
  static String get tilesInBag => _s('Tiles in bag', 'Torbadaki taş sayısı');
  static String get bagAvgValue => _s('Bag avg value', 'Torbada ort. değer');
  static String swapNote(int count, String avg) => _s(
    'Note: After swapping, you will draw $count new tiles from the bag. '
        'Average tile value in the bag is $avg points.',
    'Not: Değişimden sonra torbadan $count yeni harf çekeceksiniz. '
        'Torbadaki ortalama harf değeri $avg puandır.',
  );

  // ─── Board Widget ────────────────────────────────────────────────
  static String get removeStar => _s('Remove Star', 'Yıldızı Kaldır');
  static String get addStar => _s('Add Star (+25)', 'Yıldız Ekle (+25)');
  static String get removeJoker => _s('Remove Joker', 'Joker Kaldır');
  static String get markJoker => _s('Mark as Joker', 'Joker İşaretle');
  static String get enterWordHorizontal =>
      _s('Enter Word Horizontally', 'Yatay Kelime Gir');
  static String get enterWordVertical =>
      _s('Enter Word Vertically', 'Dikey Kelime Gir');
  static String cellLabel(String pos) => _s('Cell $pos', 'Hücre $pos');
  static String get cancel => _s('Cancel', 'İptal');
  static String get enter => _s('Enter', 'Gir');
  static String wordAtPosition(String pos) =>
      _s('Word at position $pos...', '$pos konumuna kelime...');

  // ─── Board Bonus Labels ──────────────────────────────────────────
  static String get bonusK3 => _s('W×3', 'K×3');
  static String get bonusK2 => _s('W×2', 'K×2');
  static String get bonusH3 => _s('L×3', 'H×3');
  static String get bonusH2 => _s('L×2', 'H×2');

  // ─── Results Table ───────────────────────────────────────────────
  static String get results => _s('Results', 'Sonuçlar');
  static String get enterLettersToFind =>
      _s('Enter letters to find moves', 'Hamle bulmak için harfleri girin');
  static String get colWord => _s('Word', 'Kelime');
  static String get colScore => _s('Score', 'Puan');
  static String get colDirection => _s('Dir', 'Yön');
  static String get colLetters => _s('Ltrs', 'Harf');
  static String get colBonus => _s('Bonus', 'Bonus');

  // ─── Remaining Letters Widget ────────────────────────────────────
  // (reuses remainingLetters getter above)

  // ─── AI Chat Widget ──────────────────────────────────────────────
  static String get aiName => _s('ScrabbleBot AI', 'Kelimelik AI');
  static String get aiOnline => _s('ONLINE', 'ONLINE');
  static String get aiInputHint =>
      _s('Type a command or question...', 'Komut veya soru yazın...');
  static String get aiWelcome => _s(
    'Hello! I\'m your ScrabbleBot AI assistant. You can ask me about the game '
        'or give commands.\n\n'
        'Example commands:\n'
        '• "Write ES at 7,7 horizontally"\n'
        '• "Clear the board"\n'
        '• "Find moves"\n'
        '• "Play the best move"\n'
        '• "Show remaining letters"',
    'Merhaba! Ben Kelimelik AI asistanınızım. Bana kelimelik hakkında soru sorabilir veya '
        'komut verebilirsiniz.\n\n'
        'Örnek komutlar:\n'
        '• "ES kelimesini 7,7\'ye yatay yaz"\n'
        '• "Tahtayı temizle"\n'
        '• "Hamle bul"\n'
        '• "En iyi hamleyi oyna"\n'
        '• "Kalan harfleri göster"',
  );

  // ─── AI Chat Responses ───────────────────────────────────────────
  static String get aiBoardCleared =>
      _s('Board cleared! ✅', 'Tahta temizlendi! ✅');
  static String get aiEnterHandFirst => _s(
    'Enter your hand letters first, then I can find moves.',
    'Önce elinizdeki harfleri girin, sonra hamle bulabilirim.',
  );
  static String get aiSearchStarted => _s(
    'Move search started! 🔍 Results will appear in the table when ready.',
    'Hamle arama başlatıldı! 🔍 Sonuçlar hazır olduğunda tabloda görünecek.',
  );
  static String get aiNoMoves => _s(
    'No moves found yet. Try "find moves" first.',
    'Henüz bulunan hamle yok. Önce "hamle bul" deneyin.',
  );
  static String aiBestPlayed(String word, int score) => _s(
    'Highest scoring move played! 🎯\n$word → $score points',
    'En yüksek puanlı hamle oynandı! 🎯\n$word → $score puan',
  );
  static String get aiSelectedPlayed =>
      _s('Selected move played! ✅', 'Seçili hamle oynandı! ✅');
  static String get aiSelectFirst => _s(
    'First select a move from the results table.',
    'Önce sonuçlar tablosundan bir hamle seçin.',
  );
  static String aiRemainingTiles(int total, String list) =>
      _s('Remaining $total tiles:\n$list', 'Kalan $total taş:\n$list');
  static String aiWordWritten(String word, int row, int col, bool horiz) => _s(
    '"${word.toUpperCase()}" written at ($row,$col) ${horiz ? "horizontally" : "vertically"}! ✅',
    '"${word.toUpperCase()}" kelimesi ($row,$col) konumuna ${horiz ? "yatay" : "dikey"} olarak yazıldı! ✅',
  );
  static String aiHandSet(String letters) => _s(
    'Hand letters set to "${letters.toUpperCase()}"! ✅',
    'El harfleri "${letters.toUpperCase()}" olarak ayarlandı! ✅',
  );
  static String get aiOpponentStarted => _s(
    'Opponent analysis started! 🕵️ Results will appear when ready.',
    'Rakip analizi başlatıldı! 🕵️ Sonuçlar hazır olduğunda görünecek.',
  );
  static String get aiMode5lik => _s(
    'Game mode changed to 9×9 (Quick)! ✅',
    'Oyun modu 9×9 (5\'lik) olarak değiştirildi! ✅',
  );
  static String get aiModeClassic => _s(
    'Game mode changed to 15×15 (Classic)! ✅',
    'Oyun modu 15×15 (Klasik) olarak değiştirildi! ✅',
  );
  static String aiStatusReport(
    int dictSize,
    String boardType,
    int moveCount,
    int bestScore,
    int remaining,
  ) => _s(
    'Status Report:\n'
        '• Dictionary: $dictSize words\n'
        '• Board: $boardType\n'
        '• Moves found: $moveCount\n'
        '• Highest score: $bestScore\n'
        '• Remaining tiles: $remaining',
    'Durum Raporu:\n'
        '• Sözlük: $dictSize kelime\n'
        '• Tahta: $boardType\n'
        '• Bulunan hamle: $moveCount\n'
        '• En yüksek puan: $bestScore\n'
        '• Kalan taş: $remaining',
  );
  static String get aiHelp => _s(
    'Available commands:\n\n'
        '🎮 Game:\n'
        '• "find moves" — Search for moves\n'
        '• "play the best move" — Play #1 move\n'
        '• "clear the board" — Reset\n'
        '• "opponent analysis" — Find opponent moves\n\n'
        '📝 Board:\n'
        '• "write [word] [row],[col] horizontal/vertical"\n'
        '• "set letters [letters]" — Set hand letters\n\n'
        '📊 Info:\n'
        '• "remaining letters" — Bag status\n'
        '• "status" — General statistics\n'
        '• "classic/quick" — Change game mode',
    'Kullanılabilir komutlar:\n\n'
        '🎮 Oyun:\n'
        '• "hamle bul" — Hamle ara\n'
        '• "en iyi hamleyi oyna" — #1 hamleyi oyna\n'
        '• "tahtayı temizle" — Sıfırla\n'
        '• "rakip analizi" — Rakip hamlelerini bul\n\n'
        '📝 Tahta:\n'
        '• "[kelime] [satır],[sütun] yatay/dikey yaz"\n'
        '• "harf gir [harfler]" — El harflerini ayarla\n\n'
        '📊 Bilgi:\n'
        '• "kalan harfler" — Torba durumu\n'
        '• "durum" — Genel istatistik\n'
        '• "klasik/5lik" — Oyun modu değiştir',
  );
  static String get aiUnknown => _s(
    'I didn\'t understand. Type "help" to see available commands. 🤔',
    'Anlamadım. "yardım" yazarak kullanılabilir komutları görebilirsiniz. 🤔',
  );

  // ─── Game Move Direction Display ─────────────────────────────────
  static String get dirHorizontal => _s('H', 'Yatay');
  static String get dirVertical => _s('V', 'Dikey');

  // ─── Error Messages ──────────────────────────────────────────────
  static String get dictLoadFailed =>
      _s('Dictionary could not be loaded', 'Sözlük yüklenemedi');
  static String get enterHandLetters =>
      _s('Please enter your hand letters', 'Lütfen elinizdeki harfleri girin');
  static String solverError(String e) =>
      _s('Solver error: $e', 'Çözüm hatası: $e');

  // ─── Internal helper ─────────────────────────────────────────────
  static String _s(String en, String tr) => _lang == AppLanguage.en ? en : tr;
}
