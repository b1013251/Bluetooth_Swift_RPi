//
//  ViewController.swift
//  BLEMonster
//
//  Created by kouki on 2017/05/06.
//  Copyright © 2017年 kouki. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var serviceUUID: CBUUID!
    var characteristicUUID: CBUUID!
    var manager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    var characteristic: CBCharacteristic!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var receiveMessageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.serviceUUID = CBUUID(string: "ec00")
        self.characteristicUUID = CBUUID(string: "ec0e")
        self.manager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.startButton.isEnabled = true
        }
        print("state: \(central.state.hashValue)")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Found Peripheral Device")
        self.peripheral = peripheral
        self.peripheral.delegate = self
        
        self.manager.connect(peripheral, options: nil)
        self.manager.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Did Connected")
        self.peripheral.discoverServices([self.serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Connect failed..")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if(error != nil) {
            print("there is Error caused when discovering Services")
            return
        }
        
        let services: NSArray! = peripheral.services! as NSArray
        print("Services Count: \(services.count)")
        
        for service in services as! [CBService] {
            if service.uuid.isEqual(self.serviceUUID) {
                self.peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("there is Error caused when discovering Characteristics")
            return
        }
        let characteristics: NSArray = service.characteristics! as NSArray
        for c in characteristics as! [CBCharacteristic] {
            if c.uuid.isEqual(self.characteristicUUID) {
                self.characteristic = c
                
                self.peripheral.setNotifyValue(true, for: self.characteristic)
                
                sendMessageButton.isEnabled = true
                receiveMessageButton.isEnabled = true
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("there is Error caused when reading Value")
            return
        }
        let data = String(data: characteristic.value!, encoding: .utf8)
        print(data!)
    }
    
    @IBAction func pushStart(_ sender: Any) {
        print("pushStart")
        self.startButton.isEnabled = false
        self.manager.scanForPeripherals(withServices: [self.serviceUUID], options: nil)
    }
    
    @IBAction func pushSendMessage(_ sender: Any) {
        print("pushSendMessage")
        
        //self.peripheral.readValue(for: self.characteristic)
        self.peripheral.writeValue("for iPhone".data(using: String.Encoding.utf8)!, for: self.characteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
    @IBAction func pushReceiveMessage(_ sender: Any) {
        print("pushReceiveMessage")
        self.peripheral.readValue(for: self.characteristic)
    }
    
    @IBAction func pushStop(_ sender: Any) {
        self.startButton.isEnabled = true
        self.peripheral.setNotifyValue(false, for: self.characteristic)
        self.manager.cancelPeripheralConnection(self.peripheral)
    }
    
}

