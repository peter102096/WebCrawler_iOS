//
//  ViewController.swift
//  WebCrawler_iOS
//
//  Created by PeterLin on 2021/8/26.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var hospitalPicker: UIPickerView!
    
    @IBOutlet weak var doctorNameTextField: UITextField!
    
    let hospitals = ["童綜合沙鹿胸腔內科", "光田一般內科", "光田神經科"]
    
    var didSelectedHospital = "童綜合沙鹿胸腔內科"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doctorNameTextField.text = "林毓慧"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hospitalPicker.dataSource = self
        hospitalPicker.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    @IBAction func searchBtnAction(_ sender: Any) {
        let vc = DoctorDetailViewController.fromStoryBoard()
        vc.docName = doctorNameTextField.text!
        if didSelectedHospital.contains("童綜合") {
            vc.type = .demo1
        } else {
            if didSelectedHospital.contains("一般內科") {
                vc.type = .demo2
            } else {
                vc.type = .demo3
            }
        }
        self.push(vc: vc)
    }

}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hospitals.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hospitals[row]
    }
    
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelectedHospital = hospitals[row]
    }
}
