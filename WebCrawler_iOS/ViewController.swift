//
//  ViewController.swift
//  WebCrawler_iOS
//
//  Created by PeterLin on 2021/8/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        Network().getHtmlSource()
    }

}

