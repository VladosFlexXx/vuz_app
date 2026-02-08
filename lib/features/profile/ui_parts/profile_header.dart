part of '../../home/tab_profile.dart';

class _ProfileHeader extends StatelessWidget {
  final UserProfile? profile;

  final DateTime? updatedAt;
  final bool hasError;
  final bool loading;
  final String Function(DateTime dt) fmtTime;

  const _ProfileHeader({
    required this.profile,
    required this.updatedAt,
    required this.hasError,
    required this.loading,
    required this.fmtTime,
  });

  String _subtitleLine(UserProfile p) {
    final parts = <String>[];
    final group = p.group;
    final level = p.level;
    final eduForm = p.eduForm;

    if (group != null && group.trim().isNotEmpty) parts.add(group.trim());
    if (level != null && level.trim().isNotEmpty) parts.add(level.trim());
    if (eduForm != null && eduForm.trim().isNotEmpty) parts.add(eduForm.trim());

    return parts.isEmpty ? 'Профиль ЭИОС' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (p == null) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: const [
              Row(
                children: [
                  _SkeletonCircle(size: 52),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonLine(width: 220, height: 18),
                        SizedBox(height: 8),
                        _SkeletonLine(width: 160, height: 13),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _SkeletonLine(width: double.infinity, height: 10),
            ],
          ),
        ),
      );
    }

    final updateText = (updatedAt != null) ? fmtTime(updatedAt!) : null;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: (p.avatarUrl != null)
                      ? NetworkImage(p.avatarUrl!)
                      : null,
                  child: (p.avatarUrl == null)
                      ? const Icon(Icons.person_outline, size: 28)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.fullName,
                        style: t.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitleLine(p),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // тонкая строка статуса обновления
            if (updateText != null || hasError) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    hasError ? Icons.warning_amber_rounded : Icons.sync,
                    size: 18,
                    color: hasError
                        ? cs.error.withValues(alpha: 0.85)
                        : cs.onSurface.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasError
                          ? 'Не удалось обновить'
                          : 'Обновлено: $updateText',
                      style: t.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface.withValues(alpha: 0.78),
                      ),
                    ),
                  ),
                  if (loading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

