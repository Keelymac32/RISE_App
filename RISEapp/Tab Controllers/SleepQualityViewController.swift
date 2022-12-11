//
//  SleepQualityViewController.swift
//  RISEapp
//
//  Created by Keelyn McNamara on 12/8/22.
//

import UIKit

class SleepQualityViewController: UIViewController {

    @IBOutlet var sleepPicker: UIPickerView!
    
    let data = ["1","2","3","4","5","6","7","8","9","10"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sleepPicker.dataSource = self
        sleepPicker.delegate = self

        // Do any additional setup after loading the view.
    }
    
}

extension SleepQualityViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    
}
extension SleepQualityViewController: UIPickerViewDelegate{
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) ->
    String? {
        return data[row]
    }
}
