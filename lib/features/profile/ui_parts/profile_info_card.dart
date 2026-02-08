part of '../../home/tab_profile.dart';

class _ProfileInfoCard extends StatelessWidget {
  final UserProfile? profile;
  final Future<void> Function(String text) onCopyRecordBook;

  const _ProfileInfoCard({
    required this.profile,
    required this.onCopyRecordBook,
  });

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final cs = Theme.of(context).colorScheme;

    if (p == null) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: const [
              _SkeletonTile(),
              SizedBox(height: 8),
              _SkeletonTile(),
              SizedBox(height: 8),
              _SkeletonTile(),
            ],
          ),
        ),
      );
    }

    if (p.fields.isEmpty) {
      return Card(
        elevation: 0,
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Text('Нет данных (проверь, открывается ли user/edit.php)'),
        ),
      );
    }

    final email = p.email;

    // Профиль/направление — как раньше, но без лишнего дублирования.
    final prof = p.profileEdu;
    final spec = p.specialty;

    String? profileLine;
    final parts = <String>[];
    if (prof != null && prof.trim().isNotEmpty) parts.add(prof.trim());
    if (spec != null && spec.trim().isNotEmpty) {
      if (parts.isEmpty ||
          parts.first.toLowerCase() != spec.trim().toLowerCase()) {
        parts.add(spec.trim());
      }
    }
    if (parts.isNotEmpty) profileLine = parts.join(' • ');

    // ✅ ТОЛЬКО то, что не дублируется под ФИО
    final recordBook = p.recordBook;

    final items = <Widget>[
      _InfoTile(icon: Icons.email_outlined, title: 'Почта', value: email),
      _InfoTile(
        icon: Icons.school_outlined,
        title: 'Профиль / направление',
        value: profileLine,
      ),
      _CopyTile(
        icon: Icons.confirmation_number_outlined,
        title: '№ зачётной книжки',
        value: recordBook,
        onCopy: recordBook == null ? null : () => onCopyRecordBook(recordBook),
      ),
    ].whereType<Widget>().toList();

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            ..._withDividers(
              items,
              Divider(
                color: cs.outlineVariant.withValues(alpha: 0.35),
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> children, Widget divider) {
    final out = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      out.add(children[i]);
      if (i != children.length - 1) out.add(divider);
    }
    return out;
  }
}

