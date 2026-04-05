import 'package:permission_handler/permission_handler.dart';

import '../../../verification/domain/verification_method.dart';

/// 개별 권한 항목의 상태 엔티티
///
/// 앱에서 필요한 권한 하나의 정보와 현재 허용 상태를 담음.
class PermissionItem {
  /// 시스템 권한 식별자
  final Permission permission;

  /// 다이얼로그에 표시할 권한 이름 (예: '위치 (필수)')
  final String title;

  /// 권한 용도 설명 (예: '내 위치 정보 활용')
  final String description;

  /// 권한 아이콘 SVG 에셋 경로
  final String iconAsset;

  /// 현재 권한 허용 상태
  final PermissionStatus status;

  /// 이 권한을 필요로 하는 인증 방법 목록
  final List<VerificationMethod> requiredBy;

  const PermissionItem({
    required this.permission,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.status,
    required this.requiredBy,
  });

  /// 권한이 허용된 상태인지 여부
  bool get isGranted => status.isGranted;

  /// 상태만 변경한 새 인스턴스 반환
  PermissionItem copyWith({PermissionStatus? status}) {
    return PermissionItem(
      permission: permission,
      title: title,
      description: description,
      iconAsset: iconAsset,
      status: status ?? this.status,
      requiredBy: requiredBy,
    );
  }
}
