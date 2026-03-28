import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/turkish_string.dart';
import '../providers/game_provider.dart';

/// Dictionary search & management screen.
class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? KColors.darkBorder : KColors.lightBorder;
    final dictionary = ref.watch(dictionaryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            S.dictionary,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            S.dictSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? KColors.darkTextSubtle : KColors.lightTextSubtle,
            ),
          ),
          const SizedBox(height: 16),

          // Search bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? KColors.darkCard : KColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: S.searchWord,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) =>
                        setState(() => _query = turkceLower(v.trim())),
                    onSubmitted: (v) =>
                        setState(() => _query = turkceLower(v.trim())),
                  ),
                ),
                const SizedBox(width: 12),
                dictionary.when(
                  data: (words) {
                    final found = _query.isNotEmpty && words.contains(_query);
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _query.isEmpty
                          ? const SizedBox.shrink()
                          : Container(
                              key: ValueKey(found),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (found
                                            ? KColors.darkAccentGreen
                                            : KColors.darkAccentRed)
                                        .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      (found
                                              ? KColors.darkAccentGreen
                                              : KColors.darkAccentRed)
                                          .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    found
                                        ? Icons.check_circle_outline
                                        : Icons.cancel_outlined,
                                    size: 16,
                                    color: found
                                        ? KColors.darkAccentGreen
                                        : KColors.darkAccentRed,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    found ? S.valid : S.notFound,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: found
                                          ? KColors.darkAccentGreen
                                          : KColors.darkAccentRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    );
                  },
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => const Icon(Icons.error_outline, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats + results
          Expanded(
            child: dictionary.when(
              data: (words) {
                final filtered =
                    _query.isEmpty
                          ? <String>[]
                          : words.where((w) => w.contains(_query)).toList()
                      ..sort();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats
                    SizedBox(
                      width: 240,
                      child: Column(
                        children: [
                          _statCard(
                            context,
                            S.totalWordCount,
                            '${words.length}',
                            Icons.menu_book_rounded,
                            KColors.darkAccentBlue,
                          ),
                          const SizedBox(height: 10),
                          _statCard(
                            context,
                            S.matching,
                            _query.isEmpty ? '-' : '${filtered.length}',
                            Icons.filter_alt_rounded,
                            KColors.darkAccentGreen,
                          ),
                          const SizedBox(height: 10),
                          _statCard(
                            context,
                            S.avgLength,
                            words.isEmpty
                                ? '-'
                                : (words.fold<int>(0, (s, w) => s + w.length) /
                                          words.length)
                                      .toStringAsFixed(1),
                            Icons.straighten_rounded,
                            KColors.darkAccentYellow,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Filtered results
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? KColors.darkCard : KColors.lightCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: _query.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_rounded,
                                      size: 48,
                                      color: isDark
                                          ? KColors.darkTextSubtle
                                          : KColors.lightTextSubtle,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      S.typeToSearch,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: isDark
                                                ? KColors.darkTextSubtle
                                                : KColors.lightTextSubtle,
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            : filtered.isEmpty
                            ? Center(
                                child: Text(
                                  S.noMatchingWord(_query),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? KColors.darkTextSubtle
                                        : KColors.lightTextSubtle,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filtered.length,
                                padding: const EdgeInsets.all(8),
                                itemBuilder: (_, i) {
                                  final word = filtered[i];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 2),
                                    decoration: BoxDecoration(
                                      color: i.isEven
                                          ? Colors.transparent
                                          : (isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.02,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.02,
                                                  )),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: ListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      leading: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: KColors.darkAccentBlue
                                            .withValues(alpha: 0.15),
                                        child: Text(
                                          '${word.length}',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: KColors.darkAccentBlue,
                                              ),
                                        ),
                                      ),
                                      title: Text(
                                        word,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.2,
                                            ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.content_copy,
                                          size: 16,
                                        ),
                                        tooltip: S.copy,
                                        onPressed: () {}, // clipboard
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(S.dictLoadError('$e'))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? KColors.darkCard : KColors.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? KColors.darkBorder : KColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? KColors.darkTextSubtle
                      : KColors.lightTextSubtle,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
