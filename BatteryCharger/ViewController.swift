//
//  ViewController.swift
//  BatteryCharger
//
//  Created by Martin Vytrhlík on 18/06/16.
//  Copyright © 2016 vytick. All rights reserved.
//

import SnapKit
import FontAwesomeKit
import AudioToolbox
import Firebase

class ViewController: UIViewController {

    fileprivate weak var batteryImageView: UIImageView!
    fileprivate weak var chargingView: UIView!
    fileprivate weak var hintView: UIView!
    fileprivate weak var fullLabel: UILabel!
    fileprivate weak var percentLabel: UILabel!
    
    fileprivate var maxChargingWidth: CGFloat = 243
    fileprivate var state: Int = 0
    fileprivate var shakeTimer: Timer?
    fileprivate var vibrationCountDown: Int = 1
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        
        let batteryImageView = UIImageView(image: UIImage(named: "battery"))
        batteryImageView.contentMode = .scaleAspectFit
        batteryImageView.tintColor = .green
        view.addSubview(batteryImageView)
        batteryImageView.snp.makeConstraints() {make in
            make.center.equalTo(view)
            make.width.height.equalTo(300)
        }
        self.batteryImageView = batteryImageView
        
        let chargingView = UIView()
        chargingView.backgroundColor = .green
        batteryImageView.addSubview(chargingView)
        chargingView.snp.makeConstraints() {make in
            make.left.equalTo(batteryImageView).offset(25)
            make.width.equalTo(233)
            make.centerY.equalTo(batteryImageView)
            make.height.equalTo(120)
        }
        self.chargingView = chargingView
        
        let fullLabel = UILabel()
        fullLabel.font = UIFont.boldSystemFont(ofSize: 25)
        fullLabel.text = "Charging finished!"
        batteryImageView.addSubview(fullLabel)
        fullLabel.snp.makeConstraints() {make in
            make.centerY.equalTo(0)
            make.centerX.equalTo(-7)
        }
        self.fullLabel = fullLabel
        fullLabel.isHidden = true
        
        let percentLabel = UILabel()
        percentLabel.font = UIFont.boldSystemFont(ofSize: 25)
        batteryImageView.addSubview(percentLabel)
        percentLabel.snp.makeConstraints() {make in
            make.centerY.equalTo(0)
            make.centerX.equalTo(-7)
        }
        self.percentLabel = percentLabel
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setDataFromSystem),
            name: NSNotification.Name.UIApplicationWillEnterForeground,
            object: nil
        )
    }
    
    func setDataFromSystem() {
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        self.state = Int((UIDevice.current.batteryLevel < 0 ? 0 : UIDevice.current.batteryLevel)*100)
        updateState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setDataFromSystem()
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        if motion == .motionShake {
            guard shakeTimer == nil else { return }
            shakeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateState), userInfo: nil, repeats: true)
        }
    }
    
    override func motionCancelled(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            cancelStateUpdate(withUpdate: true)
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            cancelStateUpdate(withUpdate: false)
        }
    }
    
    func cancelStateUpdate(withUpdate: Bool) {
        
        if withUpdate {
            updateState()
        }
        shakeTimer?.invalidate()
    }
    
    func updateState() {
        guard state < 100 else { return }
        
        let delta = 1
        state += delta
        setBatteryState(state)
        vibrationCountDown -= delta
        if vibrationCountDown <= 0 {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            vibrationCountDown = 1
        }
        if state >= 100 {
            batteryIsFull()
        }
        FIRAnalytics.logEvent(withName: "increaseBattery", parameters: [
            "percentage": state as NSObject
            ])
    }

    func setBatteryState(_ percent: Int) {
        var w: CGFloat = maxChargingWidth/100 * CGFloat(percent)
        w = w < 1 ? 1 : w
        w = w > maxChargingWidth ? maxChargingWidth : w
        chargingView.snp.remakeConstraints() {make in
            make.left.equalTo(batteryImageView).offset(20)
            make.width.equalTo(w)
            make.centerY.equalTo(batteryImageView)
            make.height.equalTo(125)
        }
        
        view.backgroundColor = UIColor(white: CGFloat(percent)/100, alpha: 1)
        setColorForPercent(percent)
        setPercentLabel(percent)
    }
    
    func setPercentLabel(_ percent: Int) {
        percentLabel.text = "\(percent)%"
    }

    func setColorForPercent(_ percent: Int) {
        batteryImageView.tintColor = getColorForPercent(percent)
        chargingView.backgroundColor = getColorForPercent(percent)
    }
    
    func getColorForPercent(_ percent: Int) -> UIColor {
        
        if percent <= 20 {
            return .red
        }
        else if percent <= 50 {
            return .yellow
        }
        else {
            return .green
        }
    }
    
    func batteryIsFull() {
        AudioServicesPlaySystemSound (1031)
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
}

