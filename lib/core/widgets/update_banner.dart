import 'package:flutter/material.dart';

import '../cache/cached_repository.dart';

class UpdateBanner<T> extends StatelessWidget {
  const UpdateBanner({
    super.key,
    required this.repo,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 0),
  });

  final CachedRepository<T> repo;
  final EdgeInsets padding;

  String _fmt(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final updatedAt = repo.updatedAt;
    final err = repo.lastError;

    // Если нет вообще ничего (ни обновления, ни ошибок) — не показываем баннер.
    if (updatedAt == null && err == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    final bool isError = err != null;

    final String title = isError
        ? 'Не удалось обновить'
        : 'Обновлено';

    final String subtitle = updatedAt != null
        ? 'Кеш от ${_fmt(updatedAt)}'
        : 'Кеша пока нет';

    return Padding(
      padding: padding,
      child: Material(
        elevation: 0,
        color: isError
            ? theme.colorScheme.errorContainer.withOpacity(0.35)
            : theme.colorScheme.surfaceVariant.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                isError ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.textTheme.labelMedium?.color?.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (repo.loading) ...[
                const SizedBox(width: 10),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
