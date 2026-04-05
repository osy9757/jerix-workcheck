import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../models/workplace_config_model.dart';

/// 근무지 설정 원격 데이터소스
///
/// Dio를 직접 사용하여 workplace config API를 호출한다.
@lazySingleton
class WorkplaceRemoteDataSource {
  final Dio _dio;

  const WorkplaceRemoteDataSource(this._dio);

  /// 활성화된 인증 방법 + 설정값 일괄 조회
  Future<WorkplaceConfigModel> getConfig() async {
    final response = await _dio.get(ApiConstants.workplaceConfig);
    return WorkplaceConfigModel.fromJson(response.data);
  }
}
