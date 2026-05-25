# WorkCheck Admin Web 접속 및 테스트 안내

WorkCheck 관리자 페이지를 실행하고, 인증 설정과 출퇴근 기록 조회가 정상 동작하는지 확인하는 절차입니다.

## 1. 실행 전 확인

- Docker Desktop 또는 Docker Engine이 실행 중이어야 합니다.
- 아래 명령은 레포 루트(`/Users/osy/Desktop/projects/jerix-workCheck`)에서 실행합니다.
- 관리자 웹은 Docker 실행 기준 `http://localhost:3002`로 접속합니다.
- API 서버는 호스트 기준 `http://localhost:8081`로 노출됩니다.

## 2. 전체 서비스 실행

```bash
docker-compose up --build
```

백그라운드 실행이 필요하면 다음 명령을 사용합니다.

```bash
docker-compose up --build -d
```

컨테이너 상태를 확인합니다.

```bash
docker-compose ps
```

정상 상태 예시:

- `workcheck-db`: `5433->5432`
- `workcheck-api`: `8081->8080`
- `workcheck-web`: `3002->80`

## 3. 관리자 페이지 접속

브라우저에서 다음 주소로 접속합니다.

```text
http://localhost:3002
```

현재 `admin_web/lib/main.dart`는 MVP 시연용으로 로그인 화면을 거치지 않고 대시보드에 바로 진입합니다. 화면 왼쪽 사이드바에서 다음 메뉴를 테스트할 수 있습니다.

| 메뉴 | 확인할 내용 |
| --- | --- |
| 인증 설정 | 근무지별 인증 방식 ON/OFF, GPS/WiFi/NFC/Beacon/QR 설정값 수정 |
| 인증 프리셋 | 자주 쓰는 인증 설정 프리셋 조회 및 적용 |
| 출퇴근 기록 | 날짜 범위 기준 출퇴근 기록 조회 |

## 4. 관리자 로그인 API 확인

화면에서는 로그인 절차가 우회되어 있지만, 관리자 로그인 API와 테스트 계정은 준비되어 있습니다.

| 항목 | 값 |
| --- | --- |
| username | `admin` |
| password | `admin1234` |
| 보조 계정 | `testadmin` / `admin1234` |

API로 로그인 동작을 확인합니다.

```bash
curl -X POST http://localhost:8081/api/v1/admin/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin1234"}'
```

응답에 `token`과 `admin` 정보가 포함되면 정상입니다.

## 5. 기본 테스트 순서

### 5.1 인증 설정 조회

1. `http://localhost:3002` 접속
2. 왼쪽 메뉴에서 `인증 설정` 선택
3. 근무지 목록이 표시되는지 확인
4. 근무지를 선택해 활성화된 인증 방법과 설정값이 표시되는지 확인

정상 기준:

- 본사와 종합테스트센터는 여러 인증 방식이 활성화되어 있습니다.
- 각 인증 방법에는 `targets`, `qr_codes`, `gps_targets`, `nfc_targets`, `beacon_targets` 같은 설정값이 표시됩니다.

### 5.2 인증 설정 변경

1. `인증 설정`에서 테스트할 근무지를 선택
2. 인증 방식 토글을 ON/OFF로 변경
3. 설정값 편집 다이얼로그에서 값을 수정
4. 저장 후 화면을 새로고침해 변경값이 유지되는지 확인

추천 테스트:

- GPS 반경(`radius_meters`)을 크게 변경해 모바일 앱 GPS 테스트를 쉽게 만듭니다.
- WiFi `ssid`를 현재 연결된 WiFi 이름으로 변경합니다.
- NFC `tag_id`를 실제 태그 UID로 변경합니다.
- Beacon `uuid`, `major`, `minor`, `rssi_threshold` 값을 실제 비콘 값으로 변경합니다.

### 5.3 인증 프리셋 확인

1. 왼쪽 메뉴에서 `인증 프리셋` 선택
2. NFC, WiFi, Beacon, GPS, QR 프리셋 목록이 표시되는지 확인
3. 프리셋 값을 인증 설정에 적용할 수 있는지 확인

시드 데이터에는 다음 프리셋이 포함됩니다.

- NFC 태그 2개
- 회사 WiFi
- 비콘 2개
- GPS 위치 2개
- QR 코드 여러 개

### 5.4 출퇴근 기록 조회

1. 왼쪽 메뉴에서 `출퇴근 기록` 선택
2. 날짜 범위를 선택
3. 조회 결과 테이블이 표시되는지 확인

앱에서 출근/퇴근을 한 뒤 다시 조회하면 기록이 추가되어야 합니다.

## 6. 모바일 앱과 함께 테스트

관리자 웹에서 설정을 바꾼 뒤 모바일 앱에서 해당 인증 방식으로 출퇴근을 시도합니다.

앱 테스트 계정:

| 회사코드 | 사번 | 비밀번호 | 주요 인증 방식 |
| --- | --- | --- | --- |
| `jerix` | `11` | `1111` | GPS |
| `jerix` | `12` | `1111` | GPS_QR |
| `jerix` | `21` | `1111` | WiFi |
| `jerix` | `22` | `1111` | WiFi_QR |
| `jerix` | `31` | `1111` | NFC |
| `jerix` | `32` | `1111` | NFC_GPS |
| `jerix` | `41` | `1111` | Beacon |
| `jerix` | `43` | `1111` | Beacon_GPS |

테스트 흐름:

1. 관리자 웹에서 대상 근무지의 인증 설정을 실제 테스트 환경에 맞게 수정
2. 모바일 앱에서 해당 계정으로 로그인
3. 출근 또는 퇴근 버튼 선택
4. 인증 성공/실패 결과 확인
5. 관리자 웹 `출퇴근 기록`에서 기록 생성 여부 확인

## 7. 로그 확인

API 로그를 실시간으로 확인합니다.

```bash
docker-compose logs -f api
```

최근 로그만 확인합니다.

```bash
docker-compose logs api --tail=50
```

DB 데이터가 들어갔는지 확인합니다.

```bash
docker-compose exec db psql -U workcheck -d workcheck -c "SELECT id, name, code FROM companies;"
```

출퇴근 기록을 직접 확인합니다.

```bash
docker-compose exec db psql -U workcheck -d workcheck -c "SELECT id, user_id, type, status, recorded_at FROM attendance_records ORDER BY recorded_at DESC LIMIT 10;"
```

## 8. 데이터 초기화

시드 데이터부터 다시 테스트해야 하면 볼륨을 삭제하고 재실행합니다.

```bash
docker-compose down -v
docker-compose up --build
```

주의: `down -v`는 로컬 DB 볼륨을 삭제하므로, 테스트 중 생성한 출퇴근 기록과 수정한 설정값도 모두 초기화됩니다.

## 9. 문제 해결

| 증상 | 확인할 내용 |
| --- | --- |
| `http://localhost:3002` 접속 불가 | `docker-compose ps`에서 `workcheck-web`이 실행 중인지 확인 |
| 화면은 뜨지만 데이터가 비어 있음 | `workcheck-api`, `workcheck-db` 상태와 API 로그 확인 |
| API 요청 실패 | 관리자 웹은 `/api/v1` 상대 경로를 사용하므로 Docker Nginx 프록시가 필요 |
| 설정 변경 후 앱에 반영되지 않음 | 앱을 재로그인하거나 설정 화면에서 서버 데이터를 다시 불러오기 |
| DB 시드가 반영되지 않음 | 기존 볼륨이 남아 있을 수 있으므로 `docker-compose down -v` 후 재실행 |

## 10. 로컬 Flutter 개발 실행 시 주의

`flutter run -d chrome`으로 관리자 웹만 직접 실행하면 `/api/v1` 요청이 Flutter 개발 서버로 향해 API 프록시가 동작하지 않습니다. 현재 설정 기준으로는 Docker Compose로 `web` 서비스를 실행하는 방식이 가장 간단합니다.

Flutter 개발 서버로 작업해야 한다면 별도 프록시를 두거나, `ApiService`의 base URL 전략을 개발 환경에 맞게 조정해야 합니다.
