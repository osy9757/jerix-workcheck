import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// WorkCheck 관리자 웹 공통 UI 컴포넌트 (스타일 전용, 로직 없음)
/// - PageHeader / AppCard / StatusBadge / EmptyState / SectionLabel

/// 페이지 상단 헤더 (타이틀 + 보조 설명 + 우측 액션)
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AdminColors.textSub,
                  ),
                ),
              ],
            ],
          ),
        ),
        // 우측 액션 버튼들 (간격 8 고정)
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          actions[i],
        ],
      ],
    );
  }
}

/// 흰 카드 컨테이너 (radius 14 + 미세 보더 + 낮은 그림자)
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AdminTokens.cardPadding),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(AdminTokens.radiusCard),
        border: Border.all(color: AdminColors.border),
        boxShadow: AdminTokens.cardShadow,
      ),
      padding: padding,
      child: child,
    );
  }
}

/// 상태 배지 톤
enum BadgeTone { success, warn, danger, neutral }

/// pill형 상태 배지 (예: 정상/대기/거부)
class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeTone tone;

  const StatusBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    // 톤별 (텍스트색, 배경색)
    final (Color fg, Color bg) = switch (tone) {
      BadgeTone.success => (AdminColors.primaryDark, AdminColors.primarySoft),
      BadgeTone.warn => (AdminColors.warnDark, AdminColors.warnSoft),
      BadgeTone.danger => (AdminColors.dangerDark, AdminColors.dangerSoft),
      BadgeTone.neutral => (AdminColors.textSub, AdminColors.surfaceAlt),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999), // pill
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 빈 목록 상태 (아이콘 + 메시지)
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AdminColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: AdminColors.textSub),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AdminColors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 섹션 구분 라벨 (대문자 캡션 스타일)
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AdminColors.textSub,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
