//
//  ViewController.swift
//  Robot BLE Sim
//
//  Created by Steven Knodl on 4/2/17.
//  Copyright © 2017 Steve Knodl. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SimulatorLoggingDelegate {

    @IBOutlet weak var advertisingSwitch: UISwitch!
    @IBOutlet weak var activityLogTextView: UITextView!
    
    let bleSimulator = BLEDeviceSimulator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bleSimulator.loggingDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        advertisingSwitch.isOn = false
    }

    func logMessage(_ logString: String) {
        activityLogTextView.append("\(logString)\n")
        if activityLogTextView.text.characters.count > 0 {
            let bottom = NSMakeRange(activityLogTextView.text.characters.count - 1, 1)
            activityLogTextView.scrollRangeToVisible(bottom)
        }
    }
    
    @IBAction func advertisingSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            bleSimulator.startAdvertising()
        } else {
            bleSimulator.stopAdvertising()
        }
    }
}

extension UITextInput {
    func append(_ string : String) {
        let endOfDocument = self.endOfDocument
        if let atEnd = self.textRange(from: endOfDocument, to: endOfDocument) {
            self.replace(atEnd, withText: string)
        }
    }
}
