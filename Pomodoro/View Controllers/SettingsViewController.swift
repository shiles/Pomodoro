//
//  SettingsViewController.swift
//  Pomodoro
//
//  Created by Sonnie Hiles on 18/01/2019.
//  Copyright © 2019 Sonnie Hiles. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
   
    let defaults = Defaults()
    
    @IBOutlet weak var workLengthLabel: UILabel!
    @IBOutlet weak var shortLengthLabel: UILabel!
    @IBOutlet weak var longLengthLabel: UILabel!
    @IBOutlet weak var sessionLengthLabel: UILabel!
    @IBOutlet weak var dailyGoalLabel: UILabel!
    @IBOutlet weak var autoLockSwitch: UISwitch!
    @IBOutlet weak var appVersion: UILabel!
    
    override func viewDidLoad() {
        self.navigationItem.title = "Settings"
        
        //Getting up-to-date values to display
        appVersion.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        setLabelsToValues()
        
        //Setting table height to remove defualt warningS
        self.tableView.rowHeight = 44
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            setWorkLength()
        }
        
        guard let splitViewController = splitViewController else { fatalError() }
        splitViewController.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
    }
    
    /**
     Sets the labels to the values so that the table will represent the correct current values
     */
    private func setLabelsToValues() {
        workLengthLabel.text = Format.timeToStringWords(seconds: defaults.getWorkTime())
        shortLengthLabel.text = Format.timeToStringWords(seconds: defaults.getShortTime())
        longLengthLabel.text = Format.timeToStringWords(seconds: defaults.getLongTime())
        sessionLengthLabel.text = String(format: "%d work sessions", defaults.getNumberOfSessions())
        dailyGoalLabel.text = String(format: "%d work sessions", defaults.getDailyGoal())
        autoLockSwitch.isOn = defaults.getAutoLockDisabled()
    }

    /**
     Sets work lenght to the value you select in the table
     */
    private func setWorkLength() {
        let saveFn: (Int) -> Void = defaults.setWorkTime(_:)
        
        let newTable = TimeSelectionTable(min: 1, max: 60, selected: Converter.secondsToMinutes(seconds: defaults.getWorkTime()), saveToDefaults: saveFn)
        newTable.title = "Work Length"
        newTable.delegate = self
        presentDetailView(view: newTable)
    }
    
    /**
     Sets short break lenght to the value you select in the table
     */
    private func setShortLength() {
        let saveFn: (Int) -> Void = defaults.setShortTime(_:)
        
        let newTable = TimeSelectionTable(min: 1, max: 60, selected: Converter.secondsToMinutes(seconds: defaults.getShortTime()), saveToDefaults: saveFn)
        newTable.title = "Short Break Length"
        newTable.delegate = self
        presentDetailView(view: newTable)
    }
    
    /**
     Sets long break lenght to the value you select in the table
     */
    private func setLongLength() {
        let saveFn: (Int) -> Void = defaults.setLongTime(_:)
        
        let newTable = TimeSelectionTable(min: 1, max: 60, selected: Converter.secondsToMinutes(seconds: defaults.getLongTime()), saveToDefaults: saveFn)
        newTable.title = "Long Break Length"
        newTable.delegate = self
        presentDetailView(view: newTable)
    }
    
    /**
     Sets the session length to the value you select in the table
     */
    private func setSessionLength() {
        let saveFn: (Int) -> Void = defaults.setNumberOfSessions(_:)
        
        let newTable = SessionSelectionTable(min: 1, max: 10, selected: defaults.getNumberOfSessions(), calculationType: .session, saveToDefaults: saveFn)
        newTable.title = "Length of Session"
        newTable.delegate = self
        presentDetailView(view: newTable)
    }
    
    /**
     Sets the daily goal to the value you select in the table
     */
    private func setDailyGoals() {
        let saveFn: (Int) -> Void = defaults.setDailyGoal(_:)
        
        let newTable = SessionSelectionTable(min: 1, max: 30, selected: defaults.getDailyGoal(), calculationType: .daily, saveToDefaults: saveFn)
        newTable.title = "Daily Work Sessions Goal"
        newTable.delegate = self
        presentDetailView(view: newTable)
    }
    
    /**
     Disables or enables autolock within the app
     */
    @IBAction func toggleAutoLockSwitch(_ sender: Any) {
        defaults.setAutoLockDisabled(autoLockSwitch.isOn)
        UIApplication.shared.isIdleTimerDisabled = autoLockSwitch.isOn
    }
    
    /**
     Resets the session information back to what I deem are the results
     */
    private func resetSessionsToDefaults() {
         let warning = UIAlertController(title: "Reset Session Settings To Defualts", message: "Are you sure you want to reset the sessions settings back to the defualts?", preferredStyle: .alert)
        
        warning.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in
            self.defaults.resetToDefaults()
            self.setLabelsToValues()
        }))
        warning.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(warning, animated: true, completion: nil)
    }
    
    /**
     Resets the statistics and removes all session data
     */
    private func resetStatistics() {
        let warning = UIAlertController(title: "Reset Statistics", message: "Are you sure you want to delete all of the current statistics?", preferredStyle: .alert)
        
        warning.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in
            PersistanceService().removeAllSessions()
        }))
        warning.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(warning, animated: true, completion: nil)
    }
    
    /**
     Present the view into the detailed view controller
     - Parameters: view: UIViewController that you want to present
     */
    private func presentDetailView(view: UIViewController) {
        let tableNav = UINavigationController(rootViewController: view)
        splitViewController?.showDetailViewController(tableNav, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0) :
            self.setWorkLength()
        case (0, 1):
            self.setShortLength()
        case (0, 2):
            self.setLongLength()
        case (0, 3):
            self.setSessionLength()
        case (1, 0):
            self.setDailyGoals()
        case (2, 0):
            presentDetailView(view: SiriViewController())
        case (2, 1):
            break
        case (3, 0):
            self.resetSessionsToDefaults()
        case (3, 1):
            self.resetStatistics()
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsViewController: UpdateSettingsLabelDelegate {
    
    func updateSettingsLabels() {
        setLabelsToValues()
    }
}

extension SettingsViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
