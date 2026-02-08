part of '../../home/tab_grades.dart';

class _CourseCard extends StatelessWidget {
  final GradeCourse course;
  final VoidCallback onTap;

  const _CourseCard({required this.course, required this.onTap});

  bool _hasGrade() {
    final g = course.grade;
    return g != null &&
        g.trim().isNotEmpty &&
        g.trim() != '—' &&
        g.trim() != '-';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final any = _hasGrade();
    final grade = course.grade?.trim();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    course.courseName,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 10),
                if (any && grade != null)
                  _Badge(text: grade)
                else
                  Text(
                    '—',
                    style: t.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

