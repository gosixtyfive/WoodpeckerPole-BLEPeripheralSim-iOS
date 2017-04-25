//
//  RobotServicesDefinitions.swift
//  Robot BLE Sim
//
//  Created by Steven Knodl on 4/3/17.
//  Copyright © 2017 Steve Knodl. All rights reserved.
//

import Foundation
import CoreBluetooth


enum RobotDevice {
    enum ControlService {
        static let UUID = CBUUID(string: "C700604B-2757-49A0-B02A-6A8C061BBC1E")
        enum CharacteristicUUIDs {
            static let motorControl = CBUUID(string: "C82B4753-2D94-47DF-B2FF-09099F2B0E39")
            static let robotPosition = CBUUID(string: "AD123765-A421-4F80-BE1B-62DEEB854141")
            static let latchPosition = CBUUID(string: "675CF627-6CC0-4810-AFDB-B6AA3F7183C5")
            static let launcherPosition = CBUUID(string: "434D078D-7903-44D0-A3B5-7E87884B80ED")
            static let batteryVoltage = CBUUID(string: "33DFD573-ABF9-4707-9E34-29E2011C231E")
        }
    }
    
    static func robotDeviceServices() -> [ServiceHandlers] {
        return [ServiceHandlers(UUID: RobotDevice.ControlService.UUID, characteristics: controlServiceCharacteristics())]
    }
    
    private static func controlServiceCharacteristics() -> [CharacteristicHandler] {
        let motorControl = CharacteristicHandler(name: "Motor Control", UUID: RobotDevice.ControlService.CharacteristicUUIDs.motorControl, properties: [.read, .write], permissions: [.readable, .writeable])
        let robotPosition = CharacteristicHandler(name: "Robot Position", UUID: RobotDevice.ControlService.CharacteristicUUIDs.robotPosition, properties: [.read, .notify], permissions: [.readable])
        let latchPosition = CharacteristicHandler(name: "Latch Position", UUID: RobotDevice.ControlService.CharacteristicUUIDs.latchPosition, properties: [.read, .write], permissions: [.readable, .writeable])
        let launcherPosition = CharacteristicHandler(name: "Launcher Position", UUID: RobotDevice.ControlService.CharacteristicUUIDs.launcherPosition, properties: [.read, .write], permissions: [.readable, .writeable])
        let batteryVoltage = CharacteristicHandler(name: "Battery Voltage", UUID: RobotDevice.ControlService.CharacteristicUUIDs.batteryVoltage, properties: [.read, .notify], permissions: [.readable])
        
        return [motorControl, robotPosition, latchPosition, launcherPosition, batteryVoltage]
    }
}

let handlers = RobotDevice.robotDeviceServices

struct ServiceHandlers {
    let UUID: CBUUID
    let characteristics: [CharacteristicHandler]
}

class CharacteristicHandler {
    let name: String
    let UUID: CBUUID
    let properties: CBCharacteristicProperties
    let permissions: CBAttributePermissions
    private var internalValue : Data = Data()
    
    init(name: String, UUID: CBUUID, properties: CBCharacteristicProperties, permissions: CBAttributePermissions) {
        self.name = name
        self.UUID = UUID
        self.properties = properties
        self.permissions = permissions
    }
    
    func setValue(data: Data) -> CBATTError.Code {
        internalValue = data
        return .success
    }
    
    func value() -> Result<Data, CBATTError.Code> {
        return Result.success(internalValue)
    }
}





