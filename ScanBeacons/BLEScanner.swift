//
//  BLEScanner.swift
//  ScanBeacons
//
//  Created by Wei-Cheng Ling on 2021/9/28.
//

import Foundation
import CoreBluetooth


struct BeaconInfo {
    let companyID : UInt16    // always 0x004C
    let type : UInt8          // always 0x02
    let dataLength : UInt8    // always 0x15
    let proximityUUID : String
    let major : UInt16
    let minor : UInt16
    let measuredPower : Int8
}


class BLEScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate  {
    
    enum SendDataError: Error {
        case CharacteristicNotFound
    }
    
    public private(set) var isReady = false
    
    private var centralManager : CBCentralManager!
    private var charDictionary = [String: CBCharacteristic]()
    
    private var beginAction : ((_ isReady: Bool) -> Void)?
    private var scanAction  : ((_ device: CBPeripheral, _ advertisementData: [String : Any], _ rssi: NSNumber) -> Void)?
    
    
    // MARK: - Methods
        
    func begin(action: @escaping (_ isReady: Bool) -> Void ) {
        beginAction = action
        
        let queue = DispatchQueue.global()
        
        //- 將觸發 CBCentralManagerDelegate 的：
        //   func centralManagerDidUpdateState(CBCentralManager)
        centralManager = CBCentralManager(delegate: self, queue: queue)
        
        
        // 確認藍牙的授權狀態：
        if centralManager.authorization == .denied || centralManager.authorization == .restricted {
            if let action = beginAction {
                isReady = false
                action(isReady)
            }
        }
    }
    
    func scan(action: @escaping (_ device: CBPeripheral, _ data: [String : Any], _ rssi: NSNumber) -> Void) {
        scanAction = action
        
        //- 將觸發 CBCentralManagerDelegate 的：
        //   func centralManager(CBCentralManager, didDiscover: CBPeripheral,
        //                       advertisementData: [String : Any], rssi: NSNumber)
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
    
    func checkState() -> (Bool, String) {
        switch centralManager.authorization {
        case .notDetermined:
            return (false, "Authorization Not Determined")
        case .restricted:
            return (false, "Authorization Restricted")
        case .denied:
            return (false, "Authorization Denied")
        case .allowedAlways:
            print(".allowedAlways")
        @unknown default:
            break
        }
        
        switch centralManager.state {
        case .poweredOff:
            return (false, "Powered Off")
        case .unknown:
            return (false, "Unknown")
        case .resetting:
            return (false, "Resetting")
        case .unsupported:
            return (false, "Unsupported")
        case .unauthorized:
            return (false, "Unauthorized")
        case .poweredOn:
            return (true, "Powered On")
        @unknown default:
            return (false, "Unknown State")
        }
    }
    
    
    // MARK: - iBeacon
    
    func isBeacon(advData: Data?) -> (Bool, BeaconInfo?) {
        guard let data = advData else { return (false, nil) }
        if data.count != 25 { return (false, nil) }
        
        let companyID = data[0..<2].to_uint16()
        let type = data[2..<3].to_uint8()
        let dataLength = data[3..<4].to_uint8()
        let proximityUUID = data[4..<20].to_uuid()
        let major = data[20..<22].to_uint16().bigEndian
        let minor = data[22..<24].to_uint16().bigEndian
        let measuredPower = data[24..<25].to_int8()
        
//        print("Company ID: \(String(format:"%04X", companyID))")
//        print("Type: \(String(format:"%2X", type))")
//        print("Data Length: \(String(format:"%2X", dataLength))")
//        print("Proximity UUID: \(proximityUUID?.uuidString ?? "")")
//        print("Major: \(major.bigEndian)")
//        print("Minor: \(minor.bigEndian)")
//        print("Measured Power: \(measuredPower)")
        
        let beaconInfo = BeaconInfo(companyID: companyID,
                                    type: type,
                                    dataLength: dataLength,
                                    proximityUUID: proximityUUID?.uuidString ?? "",
                                    major: major,
                                    minor: minor,
                                    measuredPower: measuredPower)
        
        if companyID != 0x004C || type != 0x02 || dataLength != 0x15{
            //print("==> is not Beacon.")
            return (false, beaconInfo)
        } else {
            //print("==> is Beacon.")
            return (true, beaconInfo)
        }
    }
    
    
    // MARK: - CBCentralManager Delegate
        
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isReady = false
        if central.state == .poweredOn {
            isReady = true
        }
        
        if let action = beginAction {
            DispatchQueue.main.async {
                action(self.isReady)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let action = scanAction {
            DispatchQueue.main.async {
                action(peripheral, advertisementData, RSSI)
            }
        }
    }
}


extension Data {
    func hexString() -> String {
        return self.map { String(format:"%02x", $0) }.joined().uppercased()
    }
    
    func to_int8() -> Int8 {
        let value = self.withUnsafeBytes { $0.load(as: Int8.self) }
        return value
    }
    
    func to_uint8() -> UInt8 {
        let value = self.withUnsafeBytes { $0.load(as: UInt8.self) }
        return value
    }
    
    func to_uint16() -> UInt16 {
        let value = self.withUnsafeBytes { $0.load(as: UInt16.self) }
        return value
    }
    
    func to_uuid() -> NSUUID? {
        let bytes = self.withUnsafeBytes { $0.bindMemory(to: UInt8.self).baseAddress }
        if bytes != nil {
            return NSUUID(uuidBytes: bytes)
        }
        return nil
    }
}

