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

class ViewController: UIViewController {

    private weak var batteryImageView: UIImageView!
    private weak var chargingView: UIView!
    private weak var hintView: UIView!
    private weak var fullLabel: UILabel!
    
    private var maxChargingWidth: CGFloat = 233
    private var state: Int = 0
    private var shakeTimer: NSTimer?
    private var vibrationCountDown: Int = 10
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        
        let plusIcon = FAKFontAwesome.batteryEmptyIconWithSize(250)
        let batteryImageView = UIImageView(image: plusIcon.imageWithSize(CGSizeMake(330, 330)).imageWithRenderingMode(.AlwaysTemplate))
        batteryImageView.contentMode = .ScaleAspectFit
        batteryImageView.tintColor = .greenColor()
        view.addSubview(batteryImageView)
        batteryImageView.snp_makeConstraints() {make in
            make.center.equalTo(view)
            make.width.height.equalTo(300)
        }
        self.batteryImageView = batteryImageView
        
        let chargingView = UIView()
        chargingView.backgroundColor = .greenColor()
        view.addSubview(chargingView)
        chargingView.snp_makeConstraints() {make in
            make.left.equalTo(batteryImageView).offset(25)
            make.width.equalTo(233)
            make.centerY.equalTo(batteryImageView)
            make.height.equalTo(120)
        }
        self.chargingView = chargingView
        
        let fullLabel = UILabel()
        fullLabel.font = UIFont.boldSystemFontOfSize(25)
        fullLabel.text = "Charging finished!"
        view.addSubview(fullLabel)
        fullLabel.snp_makeConstraints() {make in
            make.centerY.equalTo(0)
            make.centerX.equalTo(-7)
        }
        self.fullLabel = fullLabel
        fullLabel.hidden = true
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        self.state = Int((UIDevice.currentDevice().batteryLevel < 0 ? 0 : UIDevice.currentDevice().batteryLevel)*100)
        updateState()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        
        if motion == .MotionShake {
            guard shakeTimer == nil else { return }
            shakeTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateState), userInfo: nil, repeats: true)
        }
    }
    
    override func motionCancelled(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            cancelStateupdate()
        }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            cancelStateupdate()
        }
    }
    
    func cancelStateupdate() {
        updateState()
        shakeTimer?.invalidate()
    }
    
    func updateState() {
        let delta = 1
        state += delta
        setBatteryState(state)
        vibrationCountDown -= delta
        if vibrationCountDown <= 0 {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            vibrationCountDown = 10
        }
        if state >= 100 {
            batteryIsFull()
        }
    }

    func setBatteryState(percent: Int) {
        var w: CGFloat = maxChargingWidth/100 * CGFloat(percent)
        w = w < 1 ? 1 : w
        w = w > maxChargingWidth ? maxChargingWidth : w
        chargingView.snp_remakeConstraints() {make in
            make.left.equalTo(batteryImageView).offset(25)
            make.width.equalTo(w)
            make.centerY.equalTo(batteryImageView)
            make.height.equalTo(120)
        }
        
        view.backgroundColor = UIColor(white: CGFloat(percent)/100, alpha: 1)
        setColorForPercent(percent)
    }

    func setColorForPercent(percent: Int) {
        batteryImageView.tintColor = getColorForPercent(percent)
        chargingView.backgroundColor = getColorForPercent(percent)
    }
    
    func getColorForPercent(percent: Int) -> UIColor {
        
        if percent <= 20 {
            return .redColor()
        }
        else if percent <= 50 {
            return .yellowColor()
        }
        else {
            return .greenColor()
        }
    }
    
    func batteryIsFull() {
        fullLabel.hidden = false
        AudioServicesPlaySystemSound (1031)
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
}

