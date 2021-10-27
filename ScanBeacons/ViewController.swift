//
//  ViewController.swift
//  ScanBeacons
//
//  Created by Wei-Cheng Ling on 2021/9/28.
//

import Cocoa
import WebKit


class ViewController: NSViewController, WKNavigationDelegate {
    
    @IBOutlet var webView : WKWebView!
    @IBOutlet var scanButton : NSButton!
    @IBOutlet var progressIndicator : NSProgressIndicator!
    
    private let bleScanner = BLEScanner()
    private var webViewIsReady = false
    
    private var beacons = [String:[String:Any]]()
    private var beaconIDs = [String]()
    
    private var isScanning = false
    private var firstTime = true
    
    
    // MARK: - viewLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        progressIndicator.isHidden = true
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        print(">> viewDidAppear()")
        
        if firstTime {
            firstTime = false
            print(">> FirstTime")
            webView.loadHTMLString(TableHTML, baseURL: nil)
            bleScanner.begin() { [weak self] (isReady) in
                print("BLE Ready: \(isReady)")
                if isReady {
                    self?.startScan()
                } else {
                    self?.showBluetoothState()
                }
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    // MARK: - Scan
    
    func showProgressIndicator() {
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
    }
    
    func hideProgressIndicator() {
        progressIndicator.isHidden = true
        progressIndicator.stopAnimation(nil)
    }
    
    
    func stopScan() {
        bleScanner.stopScan()
        isScanning = false
        scanButton.title = "Scan"
        hideProgressIndicator()
    }
    
    func startScan() {
        if !bleScanner.isReady {
            showBluetoothState()
            return
        }
        
        clearTable()
        
        isScanning = true
        scanButton.title = "Stop"
        showProgressIndicator()
        print("Scanning Beacons...\n")
        
        bleScanner.scan() { [weak self] (device, advertisementData, rssi) in
            guard let self = self else { return }
            guard let advData = advertisementData["kCBAdvDataManufacturerData"] as? Data else { return }
            
            let (isBeacon, beaconInfo) = self.bleScanner.isBeacon(advData: advData)
            
            if isBeacon == false {
                return
            }
            if let beaconInfo = beaconInfo {
                print(">>> Device: '\(device.name ?? "")' (\(device.identifier.uuidString)) , RSSI: \(rssi)")
                print("    \(beaconInfo)\n\n")
                var dict = [String:Any]()
                dict["date"] = Date()
                dict["proximityUUID"] = beaconInfo.proximityUUID
                dict["major"] = beaconInfo.major
                dict["minor"] = beaconInfo.minor
                dict["measuredPower"] = beaconInfo.measuredPower
                dict["rssi"] = rssi
                dict["name"] = device.name ?? ""
                self.beacons[device.identifier.uuidString] = dict
                if !self.beaconIDs.contains(device.identifier.uuidString) {
                    self.beaconIDs.append(device.identifier.uuidString)
                }
                
                // Update Beacon table
                self.updateTable()
            }
        }
    }
    
    func clearTable() {
        if webViewIsReady == false { return }
        
        webView.evaluateJavaScript("table_removeAllRows()") { (result, error) in
            print("\(String(describing: result)), \(String(describing: error))")
        }
    }
    
    func updateTable() {
        if webViewIsReady == false { return }
        
        
        print("> bids: \(beaconIDs)")
        print("> beacons: \(beacons)")
        print("> \(CurrentTimeString())\n")
        
        let array = beaconArray()
        guard let json = JsonString(from: array) else { return }
        
        webView.evaluateJavaScript("table_addRows(\(json))") { (result, error) in
            print("\(String(describing: result)), \(String(describing: error))")
        }
    }
    
    
    // MARK: - Alert
    
    func showBluetoothState() {
        let (isOK, msg) = bleScanner.checkState()
        if !isOK {
            showErrorAlert(messageText: "Bluetooth State", informativeText: "\(msg).")
        }
    }
    
    func showErrorAlert(messageText: String, informativeText: String) {
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.alertStyle = .warning
        
        alert.beginSheetModal(for: self.view.window!, completionHandler: { modalResponse in
            print("modalResponse: \(modalResponse)")
        })
    }
    
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewIsReady = true
    }
    
    
    // MARK: - IBAction
    
    @IBAction func pressedZoomInButton(_ sender: NSButton) {
        webView.pageZoom += 0.1
    }
    
    @IBAction func pressedZoomOutButton(_ sender: NSButton) {
        webView.pageZoom -= 0.1
    }
    
    @IBAction func pressedScanButton(_ sender: NSButton) {
        if isScanning {
            stopScan()
        } else {
            startScan()
        }
    }
    
    
    // MARK: - Other
    
    func beaconArray() -> [[String:Any]] {
        var array = [[String:Any]]()
        for bid in beaconIDs {
            if let b = beacons[bid] {
                var copyOfItem = b
                copyOfItem.removeValue(forKey: "date")
                array.append(copyOfItem)
            }
        }
        return array
    }
    
    /*
    func sortedBeaconArray() -> [[String:Any]] {
        var array = Array(beacons.values)
        array.sort() { (e1, e2) in
            let date1 = e1["date"] as! Date
            let date2 = e2["date"] as! Date
            return date1 < date2
        }
        
        var results = [[String:Any]]()
        for item in array {
            var copyOfItem = item
            copyOfItem.removeValue(forKey: "date")
            results.append(copyOfItem)
        }
        return results
    }*/
    
}

