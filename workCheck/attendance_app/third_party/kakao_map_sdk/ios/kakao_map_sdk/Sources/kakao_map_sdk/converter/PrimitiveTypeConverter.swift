import Foundation

func asBool(_ v: Any) -> Bool {
    v as! Bool
}

// Flutter StandardMessageCodec 은 Dart 숫자를 Int32/Int64/Double NSNumber 로 보내므로
// 직접 캐스트(as!) 대신 NSNumber 경유 변환으로 타입 불일치 크래시를 방지한다.
// (예: Dart double 1.5 → as! UInt 는 EXC_BREAKPOINT 트랩)
func asFloat(_ v: Any) -> Float {
    (v as! NSNumber).floatValue
}

func asDouble(_ v: Any) -> Double {
    (v as! NSNumber).doubleValue
}

func asInt(_ v: Any) -> Int {
    (v as! NSNumber).intValue
}

func asUInt(_ v: Any) -> UInt {
    UInt(bitPattern: (v as! NSNumber).intValue)
}

func asString(_ v: Any) -> String {
    v as! String
}

func asDict(_ v: Any) -> [String: Any] {
    v as! [String: Any]
}

func asDictTyped<T>(_ v: Any, caster: (Any) throws -> T) -> [String: T] {
    let dict = asDict(v)
    var newDict: [String: T] = [:]
    for (k, v) in dict {
        newDict[k] = try! caster(v)
    }
    return newDict
}

func asArray(_ v: Any) -> [Any] {
    return v as! [Any]
}

func asArray<T>(_ v: Any, caster: (Any) throws -> T) -> [T] {
    let list = asArray(v)
    return try! list.map(caster)
}

func castSafty<T>(_ v: Any?, caster: (Any) throws -> T) -> T? {
    if v == nil || v is NSNull {
        return nil
    } else {
        return try! caster(v!)
    }
}
