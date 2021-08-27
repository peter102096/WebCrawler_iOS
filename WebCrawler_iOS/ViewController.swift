//
//  ViewController.swift
//  WebCrawler_iOS
//
//  Created by PeterLin on 2021/8/26.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var docTableView: UITableView!
    
    var docDescripts: [DocDescript] = []
    
    let network = Network()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        docTableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        network.getHtmlSource() { isSuccess in
            if isSuccess {
                self.docDescripts = self.network.docDescripts!
                self.docTableView.reloadData()
            }
        }
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return docDescripts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocDescriptCell") as! DocDescriptCell
        cell.setUp(docDes: docDescripts[indexPath.row])
        return cell
    }
    
    
}

