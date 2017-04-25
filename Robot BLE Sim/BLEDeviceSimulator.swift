//
//  BLEDeviceSimulator.swift
//  Robot BLE Sim
//
//  Created by Steven Knodl on 4/2/17.
//  Copyright © 2017 Steve Knodl. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol SimulatorLoggingDelegate : class {
    func logMessage(_ logString: String)
}

class BLEDeviceSimulator : NSObject, CBPeripheralManagerDelegate {
    
    private let peripheralManager: CBPeripheralManager
    
    var loggingDelegate: SimulatorLoggingDelegate? = nil
    
    private lazy var services = RobotDevice.robotDeviceServices()
    private var servicesMap = [CBUUID : CharacteristicHandler]()
    private var serviceUUIDList = [CBUUID]()
    
    override init() {
        self.peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
        super.init()
        self.peripheralManager.delegate = self
    }
    
    func startAdvertising() {
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : serviceUUIDList])
        loggingDelegate?.logMessage("Started advertising")
    }
    
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
        loggingDelegate?.logMessage("Stopped advertising")
    }
    
    //MARK: - CBPeripherialManagerDelegate
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        loggingDelegate?.logMessage("Update state: \(peripheral.state.rawValue)")
        
        guard case .poweredOn = peripheral.state else { return }
        loggingDelegate?.logMessage("Powered on")
        
        // Build up services
        serviceUUIDList.removeAll()
        for service in services {
            serviceUUIDList.append(service.UUID)
            var characteristicList = [CBMutableCharacteristic]()
            for characteristic in service.characteristics {
                characteristicList.append(CBMutableCharacteristic(type: characteristic.UUID, properties: characteristic.properties, value: nil, permissions: characteristic.permissions))
                servicesMap[characteristic.UUID] = characteristic
            }
            let newService = CBMutableService(type: service.UUID, primary: true)
            newService.characteristics = characteristicList
            peripheralManager.add(newService)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        if let characteristic = servicesMap[request.characteristic.uuid] {
            let result = characteristic.value()
            switch result {
            case .success(let data):
                request.value = data
                peripheral.respond(to: request, withResult: .success)
                loggingDelegate?.logMessage("Read request - \(characteristic.name) value: \(hexString(forData: data))")
            case .failure(let error):
                peripheral.respond(to: request, withResult: error)
                loggingDelegate?.logMessage("Read request - \(characteristic.name) error: \(error.rawValue)")
            }
        } else {
            peripheral.respond(to: request, withResult: .unlikelyError)
            loggingDelegate?.logMessage("Read request - unknown characteristic:  \(request.characteristic.uuid.uuidString)")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        for request in requests {
            if let characteristic = servicesMap[request.characteristic.uuid] {
                let result = characteristic.setValue(data: request.value ?? Data())
                switch result {
                case .success:
                    peripheral.respond(to: request, withResult: .success)
                    loggingDelegate?.logMessage("Write request - \(characteristic.name) value: \(hexString(forData: request.value ?? Data()))")
                default:
                    peripheral.respond(to: request, withResult: result)
                    loggingDelegate?.logMessage("Write request - \(characteristic.name) error: \(result.rawValue)")
                }
            } else {
                peripheral.respond(to: request, withResult: .unlikelyError)
                loggingDelegate?.logMessage("Write request - unknown characteristic:  \(request.characteristic.uuid.uuidString)")
            }
        }
        
    }
    
    func hexString(forData data: Data) -> String {
        return [UInt8](data).reduce("") { (partialString: String, byte: UInt8) -> String in
            partialString + " " + String(format: "0x%02X", byte)
        }
    }
    
}
