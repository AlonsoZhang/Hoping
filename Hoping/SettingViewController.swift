//
//  SettingViewController.swift
//  Hoping
//
//  Created by hyc on 2019/1/5.
//  Copyright © 2019 HYC. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController {
    
    @IBOutlet weak var login: NSButton!
    @IBOutlet weak var datePicker: NSDatePicker!
    @IBOutlet weak var endTime: NSTextField!

    var ConfigPlist:NSDictionary?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let file = Bundle.main.path(forResource:"Config", ofType: "plist")
        ConfigPlist = NSDictionary(contentsOfFile: file!)
        endTime.stringValue = ConfigPlist?["LiberateTime"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        datePicker.dateValue =  dateFormatter.date(from: endTime.stringValue) ?? Date()
        datePicker.timeZone = TimeZone.current
        var result = 0
        if UserDefaults.standard.object(forKey: "autoLaunch")  != nil {
            result = UserDefaults.standard.object(forKey: "autoLaunch") as! Bool ? 1 : 0
        }
        login.state = NSControl.StateValue(rawValue: result)
        //datePicker.timeZone = TimeZone(identifier:"Asia/Shanghai")
    }
    
    @IBAction func changeTime(_ sender: NSDatePicker) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: datePicker.dateValue)
        endTime.stringValue = String(format: "%.2d:%.2d", components.hour!,components.minute!)
        ConfigPlist?.setValue(endTime.stringValue, forKey: "LiberateTime")
        let file = Bundle.main.path(forResource:"Config", ofType: "plist")
        ConfigPlist?.write(toFile: file!, atomically: false)
        let notificationName = Notification.Name(rawValue: "SETTING")
        NotificationCenter.default.post(name: notificationName, object: self, userInfo: nil)
    }
    
    @IBAction func checkLogin(_ sender: NSButton) {
        print(login.state.rawValue)
        let autoLaunch = login.state.rawValue == 1 ? true :false
        launchAtStartup(on: autoLaunch)
        UserDefaults.standard.set(autoLaunch, forKey:"autoLaunch")
    }
    
    @IBAction func progressbarColor(_ sender: NSButton) {
        let colorpanel = NSColorPanel.shared
        colorpanel.setAction(#selector(changeTextColor(_:)))
        colorpanel.setTarget(self)
        colorpanel.orderFront(nil)
    }
    
    @objc func changeTextColor(_ sender: NSColorPanel){
        let color = sender.color;
        UserDefaults.standard.setColor(color: color, forKey: "procresscolor")
        let notificationName = Notification.Name(rawValue: "COLOR")
        NotificationCenter.default.post(name: notificationName, object: self, userInfo: nil)
    }
    
    @IBAction func quit(_ sender: NSButton) {
        NSApp.terminate(self)
    }

    func launchAtStartup(on: Bool) {
        let appPath = Bundle.main.bundlePath
        if on {
            LoginServiceKit.addLoginItems(at: appPath)
        } else {
            LoginServiceKit.removeLoginItems(at: appPath)
        }
    }
    
}


extension UserDefaults {
    func colorForKey(key: String) -> NSColor? {
        if let colorData = data(forKey: key),
            let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData)
        {
            return color
        } else {
            return nil
        }
    }
    
    // But why an Option<UIColor> here?
    func setColor(color: NSColor?, forKey key: String) {
        if let color = color,
            let colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
        {
            set(colorData, forKey: key)
        }
    }
}
