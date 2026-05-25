import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// GPS 좌표 + 반경(m)을 지도에서 픽업하는 다이얼로그.
///
/// - flutter_map(OpenStreetMap 타일) 사용. API 키 불필요, Flutter Web 호환.
/// - 지도 탭/드래그로 마커 위치 변경
/// - 반경(m) 슬라이더로 CircleLayer 시각화
/// - 검색은 미구현(MVP). 좌표 직접 입력 필드도 제공
///
/// 사용 예:
/// ```dart
/// final picked = await showDialog<GpsPickResult>(
///   context: context,
///   builder: (_) => const GpsPickerDialog(initialLat: 37.5665, initialLng: 126.9780),
/// );
/// ```
class GpsPickerDialog extends StatefulWidget {
  /// 다이얼로그 초기 위도 (없으면 서울 시청)
  final double? initialLat;

  /// 다이얼로그 초기 경도
  final double? initialLng;

  /// 초기 반경(m). 0/null 이면 기본 100m
  final int? initialRadiusMeters;

  const GpsPickerDialog({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialRadiusMeters,
  });

  @override
  State<GpsPickerDialog> createState() => _GpsPickerDialogState();
}

class _GpsPickerDialogState extends State<GpsPickerDialog> {
  static const LatLng _defaultCenter = LatLng(37.5665, 126.9780); // 서울시청
  static const Color _primary = Color(0xFF2DDAA9);

  late LatLng _marker;
  late int _radiusMeters;

  final TextEditingController _latCtrl = TextEditingController();
  final TextEditingController _lngCtrl = TextEditingController();
  final TextEditingController _radiusCtrl = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    final lat = widget.initialLat;
    final lng = widget.initialLng;
    _marker = (lat != null && lng != null)
        ? LatLng(lat, lng)
        : _defaultCenter;
    _radiusMeters = widget.initialRadiusMeters != null &&
            widget.initialRadiusMeters! > 0
        ? widget.initialRadiusMeters!
        : 100;
    _latCtrl.text = _marker.latitude.toStringAsFixed(6);
    _lngCtrl.text = _marker.longitude.toStringAsFixed(6);
    _radiusCtrl.text = _radiusMeters.toString();
  }

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  /// 지도 탭 시 마커 위치 갱신
  void _onMapTap(TapPosition pos, LatLng latLng) {
    setState(() {
      _marker = latLng;
      _latCtrl.text = latLng.latitude.toStringAsFixed(6);
      _lngCtrl.text = latLng.longitude.toStringAsFixed(6);
    });
  }

  /// 위도/경도 텍스트 변경 시 마커 동기화 (유효한 값일 때만)
  void _onCoordsChanged() {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null) return;
    if (lat.abs() > 90 || lng.abs() > 180) return;
    final next = LatLng(lat, lng);
    if (next.latitude == _marker.latitude &&
        next.longitude == _marker.longitude) {
      return;
    }
    setState(() => _marker = next);
    _mapController.move(next, _mapController.camera.zoom);
  }

  /// 반경 텍스트 변경 시 동기화
  void _onRadiusChanged() {
    final r = int.tryParse(_radiusCtrl.text.trim());
    if (r == null || r <= 0) return;
    if (r == _radiusMeters) return;
    setState(() => _radiusMeters = r);
  }

  /// 슬라이더 변경 시 텍스트 동기화
  void _onSliderChanged(double v) {
    final r = v.round();
    setState(() {
      _radiusMeters = r;
      _radiusCtrl.text = r.toString();
    });
  }

  void _onConfirm() {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    final r = int.tryParse(_radiusCtrl.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위도/경도가 유효하지 않습니다')),
      );
      return;
    }
    Navigator.pop(
      context,
      GpsPickResult(
        latitude: lat,
        longitude: lng,
        radiusMeters: (r != null && r > 0) ? r : _radiusMeters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.location_on, color: _primary),
          const SizedBox(width: 8),
          const Text('지도에서 GPS 좌표 선택'),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'OSM',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 720,
        height: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 안내
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '지도를 탭하거나 좌표를 직접 입력하세요. 슬라이더로 반경을 조절합니다.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            // 지도
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _marker,
                    initialZoom: 15,
                    minZoom: 3,
                    maxZoom: 18,
                    onTap: _onMapTap,
                  ),
                  children: [
                    // OpenStreetMap 타일
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.workcheck.admin_web',
                      maxNativeZoom: 19,
                    ),
                    // 반경 원
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _marker,
                          radius: _radiusMeters.toDouble(),
                          useRadiusInMeter: true,
                          color: _primary.withOpacity(0.18),
                          borderColor: _primary,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    // 마커
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _marker,
                          width: 40,
                          height: 40,
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 좌표 + 반경 입력
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    decoration: const InputDecoration(
                      labelText: '위도',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (_) => _onCoordsChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lngCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    decoration: const InputDecoration(
                      labelText: '경도',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (_) => _onCoordsChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _radiusCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '반경 (m)',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (_) => _onRadiusChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 슬라이더
            Row(
              children: [
                const Icon(Icons.radio_button_unchecked,
                    size: 16, color: Colors.grey),
                Expanded(
                  child: Slider(
                    value: _radiusMeters.clamp(10, 2000).toDouble(),
                    min: 10,
                    max: 2000,
                    divisions: 199,
                    label: '${_radiusMeters}m',
                    activeColor: _primary,
                    onChanged: _onSliderChanged,
                  ),
                ),
                Text('${_radiusMeters}m',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check, size: 18),
          label: const Text('이 위치 사용'),
          onPressed: _onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// 지도 픽업 결과
class GpsPickResult {
  final double latitude;
  final double longitude;
  final int radiusMeters;

  const GpsPickResult({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });
}
