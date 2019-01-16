//
//  ViewController.swift
//  Hoping
//
//  Created by hyc on 2019/1/3.
//  Copyright © 2019 HYC. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var reset: NSMenuItem!
    @IBOutlet weak var hopingProgress: NSProgressIndicator!
    @IBOutlet var myMenu: NSMenu!
    @IBOutlet weak var myLabel: NSTextField!
    var ConfigPlist:NSDictionary?
    lazy var font = NSFont()
    var timer: Timer?
    let dateFormatter = DateFormatter()
    let daydateFormatter = DateFormatter()
    var totaltime = 0
    var liberateTimeStr = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        let file = Bundle.main.path(forResource:"Config", ofType: "plist")
        ConfigPlist = NSDictionary(contentsOfFile: file!)
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        daydateFormatter.dateFormat = "yyyy/MM/dd"
        liberateTimeStr = String(format: "%@ %@:00",daydateFormatter.string(from: Date()), ConfigPlist?["LiberateTime"] as! String)
        self.calctotaltime()
        if (self.totaltime < 0){
            self.startLocalNotification(title: "回家吧", info: "现在已经是下班时间了")
        }
        self.myLabel.isHidden = true
        let color = UserDefaults.standard.colorForKey(key: "procresscolor")
        if (color != nil){
            self.hopingProgress.setCustomColor(UserDefaults.standard.colorForKey(key: "procresscolor"))
        }else{
            self.hopingProgress.setCustomColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        }
        let settingNotification = Notification.Name(rawValue: "SETTING")
        NotificationCenter.default.addObserver(self, selector: #selector(self.setting(notice:)), name: settingNotification, object: nil)
        let colorNotification = Notification.Name(rawValue: "COLOR")
        NotificationCenter.default.addObserver(self, selector: #selector(self.setcolor(notice:)), name: colorNotification, object: nil)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            let daydate = self.daydateFormatter.string(from: Date())
            if UserDefaults.standard.string(forKey:daydate) == nil{
                UserDefaults.standard.set("true", forKey: daydate)
                self.liberateTimeStr = String(format: "%@ %@:00",self.daydateFormatter.string(from: Date()), self.ConfigPlist?["LiberateTime"] as! String)
                self.calctotaltime()
            }
            let elapsed = Date().timeIntervalSince(self.dateFormatter.date(from: self.liberateTimeStr)!)
            let timeInterval = -Int(elapsed)
            self.hopingProgress.doubleValue = 100 - Double(timeInterval)/Double(self.totaltime)*100
            if timeInterval >= 0 && timeInterval < 3600*9 {
                self.reset.isHidden = false
                self.myLabel.stringValue = self.calcTime(alltime: timeInterval)
                if (self.hopingProgress.doubleValue == 100){
                    sleep(1)
                    self.startLocalNotification(title: "喝杯水吧", info: "一天工作辛苦了")
                }
            }else{
                self.reset.isHidden = true
                self.myLabel.stringValue = "下班时间"
                self.hopingProgress.doubleValue = 0
            }
            
        }
    }
    
    @objc func setting(notice: Notification) {
        DispatchQueue.main.async(execute: {
            autoreleasepool {
                if ((notice.name).rawValue == "SETTING") == true {
                    let file = Bundle.main.path(forResource:"Config", ofType: "plist")
                    self.ConfigPlist = NSDictionary(contentsOfFile: file!)
                    self.liberateTimeStr = String(format: "%@ %@:00",self.daydateFormatter.string(from: Date()), self.ConfigPlist?["LiberateTime"] as! String)
                    self.calctotaltime()
                }
            }
        })
    }
    
    @objc func setcolor(notice: Notification) {
        DispatchQueue.main.async(execute: {
            autoreleasepool {
                if ((notice.name).rawValue == "COLOR") == true {
                    self.hopingProgress.setCustomColor(UserDefaults.standard.colorForKey(key: "procresscolor"))
                }
            }
        })
    }

    func calcTime(alltime:Int) -> String {
        let hour = alltime/3600
        let min = (alltime - hour * 3600)/60
        let second = alltime % 60
        return String(format: "%.2d:%.2d:%.2d", hour,min,second)
    }
    
    
    override func rightMouseDown(with event: NSEvent) {
        let eventLocation = event.locationInWindow
        let center = hopingProgress.convert(eventLocation, from: nil)
        self.myMenu.popUp(positioning: nil, at: center, in: self.view)
    }
    
    override func mouseDown(with event: NSEvent) {
        self.myLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.myLabel.isHidden = true
        }
        
    }
    
    func calctotaltime() {
        totaltime = -Int(Date().timeIntervalSince(self.dateFormatter.date(from: self.liberateTimeStr)!))
    }
    
    @IBAction func Reset(_ sender: NSMenuItem) {
       self.calctotaltime()
    }
    
    func startLocalNotification(title:String,info:String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.hasActionButton = false
        //notification.actionButtonTitle = "Fighting"
        notification.otherButtonTitle = "好的"
        notification.informativeText = info
        notification.deliveryDate = Date()
        notification.setValue(NSImage(named:"kaola"), forKey: "_identityImage")
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.scheduleNotification(notification)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    @objc func userNotificationCenter(_ center: NSUserNotificationCenter, didDismissAlert notification: NSUserNotification){
        //NSApp.terminate(self)
    }
}

extension ViewController: NSUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        //print("didDeliver notification \(notification)")
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        print("ccc")
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}
