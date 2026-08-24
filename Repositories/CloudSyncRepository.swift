import Foundation
import FirebaseDatabase
import FirebaseStorage

struct KeyValidationResult {
    let isValid: Bool
    let message: String?
    let permissions: String
    let autoGpx: Bool
    let canSync: Bool

    init(isValid: Bool, message: String? = nil, permissions: String = "FULL", autoGpx: Bool = false, canSync: Bool = true) {
        self.isValid = isValid
        self.message = message
        self.permissions = permissions
        self.autoGpx = autoGpx
        self.canSync = canSync
    }
}

class CloudSyncRepository {
    static let shared = CloudSyncRepository()

    private var dbRef: DatabaseReference? {
        return Database.database().reference()
    }

    private var storageRef: StorageReference? {
        return Storage.storage().reference()
    }

    private var keyListenerHandle: DatabaseHandle?

    private func sanitizeKey(_ input: String) -> String {
        return input.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "#", with: "_")
            .replacingOccurrences(of: "$", with: "_")
            .replacingOccurrences(of: "[", with: "_")
            .replacingOccurrences(of: "]", with: "_")
            .replacingOccurrences(of: "/", with: "-")
    }

    func verifyActivationKey(key: String, deviceId: String, userInfo: [String: String]? = nil) async -> KeyValidationResult {
        do {
            let snapshot = try await dbRef?.child("ActivationKeys").child(key).getData()
            guard let snapshot = snapshot, snapshot.exists() else {
                return KeyValidationResult(isValid: false, message: "Mã Key không tồn tại!")
            }

            let data = snapshot.value as? [String: Any] ?? [:]
            let expiry = data["expiryTimestamp"] as? Int64 ?? 0
            let active = data["isActive"] as? Bool ?? false
            let perms = data["permissions"] as? String ?? "FULL"
            let boundId = data["deviceId"] as? String ?? ""
            let autoGpx = data["autoGpx"] as? Bool ?? false
            let canSync = data["canSync"] as? Bool ?? true

            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            let dateStr = df.string(from: Date(timeIntervalSince1970: TimeInterval(Double(expiry) / 1000.0)))

            if !active { return KeyValidationResult(isValid: false, message: "Key bị khóa!") }
            if Int64(Date().timeIntervalSince1970 * 1000) > expiry {
                return KeyValidationResult(isValid: false, message: "Key hết hạn (\(dateStr))!")
            }

            // Info matching logic
            if let info = userInfo {
                let rName = data["registeredName"] as? String ?? ""
                let rEmail = data["registeredEmail"] as? String ?? ""
                if !rName.isEmpty && rName != info["name"] { return KeyValidationResult(isValid: false, message: "Họ tên không khớp!") }
                if !rEmail.isEmpty && rEmail != info["email"] { return KeyValidationResult(isValid: false, message: "Email không khớp!") }
            }

            if boundId.isEmpty {
                if let info = userInfo {
                    let updates = [
                        "deviceId": deviceId,
                        "registeredName": info["name"] ?? "",
                        "registeredEmail": info["email"] ?? "",
                        "registeredPhone": info["phone"] ?? "",
                        "registeredUnit": info["unit"] ?? "",
                        "registeredDept": info["dept"] ?? ""
                    ]
                    try await dbRef?.child("ActivationKeys").child(key).updateChildValues(updates)
                    return KeyValidationResult(isValid: true, message: dateStr, permissions: perms, autoGpx: autoGpx, canSync: canSync)
                } else {
                    return KeyValidationResult(isValid: false, message: "Thiếu thông tin đăng ký!")
                }
            } else if boundId != deviceId {
                return KeyValidationResult(isValid: false, message: "Key đã dùng trên thiết bị khác!")
            }

            return KeyValidationResult(isValid: true, message: dateStr, permissions: perms, autoGpx: autoGpx, canSync: canSync)
        } catch {
            return KeyValidationResult(isValid: false, message: "Lỗi kết nối: \(error.localizedMessage)")
        }
    }

    func monitorKeyChanges(key: String, onStatusChanged: @escaping (Bool, String, String) -> Void) {
        stopKeyMonitoring()
        keyListenerHandle = dbRef?.child("ActivationKeys").child(key).observe(.value) { snapshot in
            guard snapshot.exists(), let data = snapshot.value as? [String: Any] else { return }

            let isActive = data["isActive"] as? Bool ?? false
            let perms = data["permissions"] as? String ?? "FULL"
            let expiry = data["expiryTimestamp"] as? Int64 ?? 0

            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            let dateStr = df.string(from: Date(timeIntervalSince1970: TimeInterval(Double(expiry) / 1000.0)))

            onStatusChanged(isActive, perms, dateStr)
        }
    }

    func stopKeyMonitoring() {
        if let handle = keyListenerHandle {
            dbRef?.removeObserver(withHandle: handle)
            keyListenerHandle = nil
        }
    }

    func updatePersonnelInfo(user: [String: String], registrationKey: String, permissions: String, canSync: Bool) async {
        guard let name = user["name"] else { return }
        let sOfficer = sanitizeKey(name)
        let data: [String: Any] = [
            "name": name,
            "phone": user["phone"] ?? "",
            "email": user["email"] ?? "",
            "unit": user["unit"] ?? "",
            "department": user["dept"] ?? "",
            "registrationKey": registrationKey,
            "lastActive": Int64(Date().timeIntervalSince1970 * 1000),
            "permissions": permissions,
            "canSync": canSync
        ]
        try? await dbRef?.child("GlobalOfficers").child(sOfficer).setValue(data)
    }

    func syncPatrol(user: [String: String], patrol: [String: Any], cm: Double, province: String, zone: Int) async -> Bool {
        guard let unit = user["unit"], let name = user["name"] else { return false }
        let sUnit = sanitizeKey(unit)
        let sName = sanitizeKey(name)
        let timestamp = patrol["discoveryTime"] as? Int64 ?? Int64(Date().timeIntervalSince1970 * 1000)

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateStr = df.string(from: Date(timeIntervalSince1970: TimeInterval(Double(timestamp) / 1000.0)))

        let path = "Units/\(sUnit)/\(sName)/Surveys/\(dateStr)/Patrols/\(patrol["id"] ?? UUID().uuidString)"

        var data = patrol
        data["coordSystem"] = "VN2000 - \(province) (KTT \(cm), Múi \(zone))"
        data["department"] = user["dept"] ?? ""

        do {
            try await dbRef?.child(path).setValue(data)
            return true
        } catch {
            return false
        }
    }

    func syncWaypoint(user: [String: String], wp: [String: Any], cm: Double, province: String, zone: Int) async -> Bool {
        guard let unit = user["unit"], let name = user["name"] else { return false }
        let sUnit = sanitizeKey(unit)
        let sName = sanitizeKey(name)
        let timestamp = wp["timestamp"] as? Int64 ?? Int64(Date().timeIntervalSince1970 * 1000)

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateStr = df.string(from: Date(timeIntervalSince1970: TimeInterval(Double(timestamp) / 1000.0)))

        let path = "Units/\(sUnit)/\(sName)/Surveys/\(dateStr)/Waypoints/\(wp["id"] ?? UUID().uuidString)"

        var data = wp
        data["coordSystem"] = "VN2000 - \(province) (KTT \(cm), Múi \(zone))"
        data["department"] = user["dept"] ?? ""

        do {
            try await dbRef?.child(path).setValue(data)
            return true
        } catch {
            return false
        }
    }

    func syncTrack(user: [String: String], trk: [String: Any], cm: Double, province: String, zone: Int) async -> Bool {
        guard let unit = user["unit"], let name = user["name"] else { return false }
        let sUnit = sanitizeKey(unit)
        let sName = sanitizeKey(name)
        let startTime = trk["startTime"] as? Int64 ?? Int64(Date().timeIntervalSince1970 * 1000)

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateStr = df.string(from: Date(timeIntervalSince1970: TimeInterval(Double(startTime) / 1000.0)))

        let path = "Units/\(sUnit)/\(sName)/Surveys/\(dateStr)/Tracks/\(trk["id"] ?? UUID().uuidString)"

        var data = trk
        data["coordSystem"] = "VN2000 - \(province) (KTT \(cm), Múi \(zone))"
        data["department"] = user["dept"] ?? ""

        do {
            try await dbRef?.child(path).setValue(data)
            return true
        } catch {
            return false
        }
    }

    func syncPolygon(user: [String: String], p: [String: Any], cm: Double, province: String, zone: Int) async -> Bool {
        guard let unit = user["unit"], let name = user["name"] else { return false }
        let sUnit = sanitizeKey(unit)
        let sName = sanitizeKey(name)
        let timestamp = p["timestamp"] as? Int64 ?? Int64(Date().timeIntervalSince1970 * 1000)

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateStr = df.string(from: Date(timeIntervalSince1970: TimeInterval(Double(timestamp) / 1000.0)))

        let path = "Units/\(sUnit)/\(sName)/Surveys/\(dateStr)/Polygons/\(p["id"] ?? UUID().uuidString)"

        var data = p
        data["coordSystem"] = "VN2000 - \(province) (KTT \(cm), Múi \(zone))"
        data["centralMeridian"] = cm
        data["province"] = province
        data["department"] = user["dept"] ?? ""

        do {
            try await dbRef?.child(path).setValue(data)
            return true
        } catch {
            return false
        }
    }

    func syncDailyJournal(user: [String: String], journal: [String: Any], cm: Double, province: String, zone: Int) async -> Bool {
        guard let unit = user["unit"], let name = user["name"], let dateStr = journal["date"] as? String else { return false }
        let sUnit = sanitizeKey(unit)
        let sName = sanitizeKey(name)

        let path = "Units/\(sUnit)/\(sName)/Surveys/\(dateStr)/DailyJournal"

        var data = journal
        data["coordSystem"] = "VN2000 - \(province) (KTT \(cm), Múi \(zone))"
        data["department"] = user["dept"] ?? ""

        do {
            try await dbRef?.child(path).setValue(data)
            return true
        } catch {
            return false
        }
    }

    func uploadSurveyPhoto(localPath: String, remotePath: String) async -> String? {
        let fileURL = URL(fileURLWithPath: localPath)
        let ref = storageRef?.child(remotePath)
        do {
            _ = try await ref?.putFile(from: fileURL)
            let downloadURL = try await ref?.downloadURL()
            return downloadURL?.absoluteString
        } catch {
            print("Upload failed: \(error)")
            return nil
        }
    }
}
