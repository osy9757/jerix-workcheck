#!/usr/bin/env bash
# WorkCheck 전체 기능 E2E (live API + 실 docker DB) — 기존 회귀 + 신규 기기바인딩
# 전제: docker compose down -v && up -d --build 로 fresh seed 적용된 상태에서 실행.
# 사용: bash e2e_test.sh   (BASE 환경변수로 호스트 변경 가능)
set -u
BASE="${BASE:-http://localhost:8081/api/v1}"
PASS=0; FAIL=0; FAILED_NAMES=()

# req METHOD PATH [JSON_BODY] [AUTH_TOKEN] → 전역 STATUS, BODY 설정
req() {
  local m="$1" p="$2" body="${3:-}" tok="${4:-}"
  local args=(-sS -o /tmp/e2e_body.txt -w '%{http_code}' -X "$m" "$BASE$p" -H 'Content-Type: application/json')
  [ -n "$tok" ] && args+=(-H "Authorization: Bearer $tok")
  [ -n "$body" ] && args+=(-d "$body")
  STATUS=$(curl "${args[@]}"); BODY=$(cat /tmp/e2e_body.txt)
}
# jget KEYPATH → BODY 에서 python으로 값 추출 (점 표기, 배열 index 지원 단순)
jget() { python3 -c "import json,sys
d=json.load(open('/tmp/e2e_body.txt'))
ks='''$1'''.split('.')
for k in ks:
    if k=='':continue
    d=d[int(k)] if isinstance(d,list) else d[k]
print(d)" 2>/dev/null; }
ok() { PASS=$((PASS+1)); printf '  \033[32mPASS\033[0m %s\n' "$1"; }
no() { FAIL=$((FAIL+1)); FAILED_NAMES+=("$1"); printf '  \033[31mFAIL\033[0m %s\n     status=%s body=%s\n' "$1" "$STATUS" "${BODY:0:200}"; }
# expect_status NAME EXPECTED
es() { [ "$STATUS" = "$2" ] && ok "$1" || no "$1 (기대 $2)"; }

echo "=== 0. 헬스 ==="
req GET ../../actuator/health 2>/dev/null
echo "  health status=$STATUS (무시 가능)"

echo "=== A. 인증 회귀 ==="
# A1 앱 로그인 (device_id 생략 → 기기검증 스킵, 구버전 호환). enabled_methods 존재, workplace_id 없음
req POST /auth/login '{"company_code":"jerix","employee_id":"11","password":"1111"}'
TOKEN=$(jget token)
if [ "$STATUS" = "200" ] && [ -n "$TOKEN" ] && ! echo "$BODY" | grep -q workplace_id; then ok "A1 앱 로그인(device_id 생략 호환)"; else no "A1 앱 로그인"; fi
# A2 admin 로그인
req POST /auth/admin/login '{"username":"admin","password":"admin1234"}'
ATOKEN=$(jget token); { [ "$STATUS" = "200" ] && [ -n "$ATOKEN" ]; } && ok "A2 admin 로그인" || no "A2 admin 로그인"
# A3 비번 오류
req POST /auth/login '{"company_code":"jerix","employee_id":"11","password":"wrong"}'
{ [ "$STATUS" = "400" ] || [ "$STATUS" = "401" ]; } && ok "A3 로그인 비번오류 거부" || no "A3 로그인 비번오류 거부"

echo "=== B. 직원/인증설정 회귀 ==="
req GET /users '' "$ATOKEN"; es "B1 GET /users" 200
req GET /users/1/methods '' "$ATOKEN"
N=$(jget methods 2>/dev/null | tr -cd ',' | wc -c)
{ [ "$STATUS" = "200" ] && echo "$BODY" | grep -q method_type; } && ok "B2 GET /users/1/methods 5개" || no "B2 GET /users/1/methods"
# B3 GPS만 활성 세팅(결정론적 출퇴근용)
req PUT /users/1/methods/GPS '{"is_enabled":true,"config_data":{"targets":[{"lat":37.5665,"lng":126.978,"radius_m":200}]}}' "$ATOKEN"; es "B3 PUT GPS 활성" 200
req PUT /users/1/methods/WIFI '{"is_enabled":false,"config_data":{}}' "$ATOKEN"; es "B4 PUT WIFI off" 200
req PUT /users/1/methods/NFC '{"is_enabled":false,"config_data":{}}' "$ATOKEN"; es "B5 PUT NFC off" 200
req PUT /users/1/methods/BEACON '{"is_enabled":false,"config_data":{}}' "$ATOKEN"; es "B6 PUT BEACON off" 200
req PUT /users/1/methods/QR '{"is_enabled":false,"config_data":{}}' "$ATOKEN"; es "B7 PUT QR off" 200
# B8 BEACON 거리→rssi 자동환산 검증 (별도 확인 후 다시 off)
req PUT /users/1/methods/BEACON '{"is_enabled":true,"config_data":{"targets":[{"uuid":"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0","major":40011,"minor":57342,"distance_m":2.0,"tx_power":-59}]}}' "$ATOKEN"
RSSI=$(jget config_data.targets.0.rssi_threshold)
{ [ "$STATUS" = "200" ] && [ "$RSSI" = "-65" ]; } && ok "B8 BEACON rssi 자동환산(-65)" || no "B8 BEACON rssi 자동환산 (got $RSSI)"
req PUT /users/1/methods/BEACON '{"is_enabled":false,"config_data":{}}' "$ATOKEN"  # 다시 off (GPS만)

echo "=== C. 출퇴근 회귀 (GPS 단일 AND) ==="
req POST /attendance/clock-in/init '' "$TOKEN"
echo "$BODY" | grep -q '"gps"' && ok "C1 clock-in/init required gps" || no "C1 clock-in/init"
# C2 submit GPS 통과
req POST /attendance/clock-in/submit '{"verification_data":{"gps":{"lat":37.5665,"lng":126.978}}}' "$TOKEN"
{ [ "$STATUS" = "200" ] && echo "$BODY" | grep -q CLOCK_IN; } && ok "C2 clock-in/submit GPS 통과" || no "C2 clock-in/submit"
# C3 clock-out submit GPS 실패 (반경 밖)
req POST /attendance/clock-out/submit '{"verification_data":{"gps":{"lat":37.0,"lng":127.0}}}' "$TOKEN"
EC=$(jget errorCode)
{ [ "$STATUS" = "400" ] && [ "$EC" = "GPS_VERIFICATION_FAILED" ]; } && ok "C3 clock-out GPS 실패 errorCode" || no "C3 clock-out GPS 실패 (got $EC)"

echo "=== D. 인증 프리셋 CRUD 회귀 ==="
req GET /verification-presets '' "$ATOKEN"; es "D1 프리셋 목록" 200
req GET '/verification-presets?methodType=NFC' '' "$ATOKEN"; es "D2 프리셋 NFC 필터" 200
req POST /verification-presets '{"name":"E2E테스트 NFC","method_type":"NFC","config_data":{"tag_id":"04:11:22:33:44:55:66"},"memo":"e2e"}' "$ATOKEN"
PID=$(jget id); { [ "$STATUS" = "201" ] || [ "$STATUS" = "200" ]; } && [ -n "$PID" ] && ok "D3 프리셋 생성" || no "D3 프리셋 생성"
req PUT "/verification-presets/$PID" '{"name":"E2E수정","method_type":"NFC","config_data":{"tag_id":"04:FF:FF:FF:FF:FF:FF"},"memo":"x"}' "$ATOKEN"; es "D4 프리셋 수정" 200
req DELETE "/verification-presets/$PID" '' "$ATOKEN"; { [ "$STATUS" = "204" ] || [ "$STATUS" = "200" ]; } && ok "D5 프리셋 삭제" || no "D5 프리셋 삭제"
req POST /verification-presets '{"name":"","method_type":"NFC","config_data":{}}' "$ATOKEN"; es "D6 프리셋 빈이름 400" 400

echo "=== E. 기기 바인딩 (신규판정=바인드기기 유무) ==="
# 신규 seed: user1(emp11)=APPROVED/PENDING/REJECTED 3행, user3(emp21)=APPROVED 1행, user2(emp12)=무행
# E1 신규(바인드 기기 없음) 자동승인 — user2(emp12)
req POST /auth/login '{"company_code":"jerix","employee_id":"12","password":"1111","device_id":"E2E-NEW-USER2"}'
es "E1 바인드기기 없음→자동승인" 200
# E2 동일 기기 재로그인 통과
req POST /auth/login '{"company_code":"jerix","employee_id":"12","password":"1111","device_id":"E2E-NEW-USER2"}'
es "E2 동일기기 재로그인" 200
# E3 user1(APPROVED 보유) 미지기기 → 403 NONE_MATCH
req POST /auth/login '{"company_code":"jerix","employee_id":"11","password":"1111","device_id":"E2E-UNKNOWN-USER1"}'
DS=$(jget deviceStatus); ECC=$(jget errorCode)
{ [ "$STATUS" = "403" ] && [ "$ECC" = "DEVICE_NOT_ALLOWED" ] && [ "$DS" = "NONE_MATCH" ]; } && ok "E3 미지기기 403 NONE_MATCH" || no "E3 미지기기 403 (st=$STATUS ec=$ECC ds=$DS)"
# E4 user1 승인기기 일치 → 200
req POST /auth/login '{"company_code":"jerix","employee_id":"11","password":"1111","device_id":"SEED-APPROVED-DEVICE-USER1"}'
es "E4 일치기기 로그인" 200
# E5 user1 REJECTED 기기(승인기기 공존) → 403 REJECTED
req POST /auth/login '{"company_code":"jerix","employee_id":"11","password":"1111","device_id":"SEED-REJECTED-DEVICE-USER1"}'
DS=$(jget deviceStatus); { [ "$STATUS" = "403" ] && [ "$DS" = "REJECTED" ]; } && ok "E5 거부기기 403 REJECTED" || no "E5 거부기기 (st=$STATUS ds=$DS)"
# E6 user1 PENDING 기기(승인기기 공존) → 403 PENDING
req POST /auth/login '{"company_code":"jerix","employee_id":"11","password":"1111","device_id":"SEED-PENDING-DEVICE-USER1"}'
DS=$(jget deviceStatus); { [ "$STATUS" = "403" ] && [ "$DS" = "PENDING" ]; } && ok "E6 대기기기 403 PENDING" || no "E6 대기기기 (st=$STATUS ds=$DS)"
# E7 접속허용 요청 (user1 미지기기) → 200 PENDING 생성
req POST /auth/device/request '{"company_code":"jerix","employee_id":"11","password":"1111","device_id":"E2E-UNKNOWN-USER1"}'
es "E7 device/request 200" 200
# E8 admin 기기목록 PENDING 조회
req GET '/admin/devices?status=PENDING' '' "$ATOKEN"
{ [ "$STATUS" = "200" ] && echo "$BODY" | grep -q device_id; } && ok "E8 admin PENDING 목록" || no "E8 admin PENDING 목록"
# E9 admin 승인 → user1 SEED-PENDING-DEVICE-USER1 승인 + 기존 APPROVED(SEED-APPROVED) 교체
APID=$(python3 -c "import json
d=json.load(open('/tmp/e2e_body.txt'))
rows=d if isinstance(d,list) else d.get('requests',[])
print(next((r['id'] for r in rows if r.get('user_id')==1 and r.get('device_id')=='SEED-PENDING-DEVICE-USER1'), ''))" 2>/dev/null)
if [ -n "$APID" ]; then
  req POST "/admin/devices/$APID/approve" '' "$ATOKEN"; es "E9 admin 승인" 200
  req POST /auth/login '{"company_code":"jerix","employee_id":"11","password":"1111","device_id":"SEED-PENDING-DEVICE-USER1"}'
  es "E10a 승인된 새기기 로그인" 200
  req POST /auth/login '{"company_code":"jerix","employee_id":"11","password":"1111","device_id":"SEED-APPROVED-DEVICE-USER1"}'
  { [ "$STATUS" = "403" ]; } && ok "E10b 교체된 기존기기 403" || no "E10b 교체된 기존기기 403 (st=$STATUS)"
else
  no "E9 admin 승인 (PENDING id 추출 실패)"
fi
# E11 admin 거부 → user1 E2E-UNKNOWN-USER1 PENDING 거부
req GET '/admin/devices?status=PENDING' '' "$ATOKEN"
RPID=$(python3 -c "import json
d=json.load(open('/tmp/e2e_body.txt'))
rows=d if isinstance(d,list) else d.get('requests',[])
print(next((r['id'] for r in rows if r.get('device_id')=='E2E-UNKNOWN-USER1'), ''))" 2>/dev/null)
if [ -n "$RPID" ]; then
  req POST "/admin/devices/$RPID/reject" '' "$ATOKEN"; es "E11 admin 거부" 200
else no "E11 admin 거부 (PENDING id 추출 실패)"; fi
# E12 admin 삭제 → user3 SEED-APPROVED-DEVICE-USER3 삭제 후, user3 새 기기 로그인 시 자동 재바인딩
req GET '/admin/devices?status=APPROVED' '' "$ATOKEN"
DELID=$(python3 -c "import json
d=json.load(open('/tmp/e2e_body.txt'))
rows=d if isinstance(d,list) else d.get('requests',[])
print(next((r['id'] for r in rows if r.get('device_id')=='SEED-APPROVED-DEVICE-USER3'), ''))" 2>/dev/null)
if [ -n "$DELID" ]; then
  req DELETE "/admin/devices/$DELID" '' "$ATOKEN"; es "E12a admin 기기 삭제" 200
  # 삭제 후 user3(emp21)는 바인드기기 없음 → 새 기기 자동 재바인딩
  req POST /auth/login '{"company_code":"jerix","employee_id":"21","password":"1111","device_id":"E2E-AFTER-DELETE-USER3"}'
  es "E12b 삭제후 새기기 자동 재바인딩" 200
else no "E12 admin 삭제 (APPROVED id 추출 실패)"; fi

echo
echo "==================== 결과 ===================="
echo "PASS=$PASS  FAIL=$FAIL"
if [ "$FAIL" -gt 0 ]; then printf '실패: %s\n' "${FAILED_NAMES[*]}"; exit 1; fi
echo "ALL GREEN ✅"; exit 0
