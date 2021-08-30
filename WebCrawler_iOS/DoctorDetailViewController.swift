//
//  DoctorDetailViewController.swift
//  WebCrawler_iOS
//
//  Created by Peter on 2021/8/29.
//

import UIKit
import AlamofireImage

class DoctorDetailViewController: UIViewController {

    @IBOutlet weak var docAvatorImgView: UIImageView!
    
    @IBOutlet weak var docNameLabel: UILabel!
    
    @IBOutlet weak var docDetailTableView: UITableView!
    
    var docName = ""
    
    var type: Network.Demo = .demo1
    
    let network = Network()
    
    var docDescript: DocDescript? = nil
    
    var docDetail: [DocDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        docDetailTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {

        network.getDoctorDetail(type: type, selectDocName: docName) { [self] isSuccess in
            if isSuccess {
                docDescript = network.docDetail
                var docExp = ""
                if docDescript!.docExps.count != 0 {
                    for i in 0..<docDescript!.docExps.count {
                        docExp.append("\(String(docDescript!.docExps[i]))")
                        if i != docDescript!.docExps.count - 1 {
                            docExp.append("\n")
                        }
                    }
                } else {
                    docExp = docDescript!.docExps2
                }
                
                docDetail.append(DocDetail(title: "經歷", content: docExp))
                docDetail.append(DocDetail(title: "專長", content: docDescript!.docSkills))
                if type == .demo1 {
                    docDetail.append(DocDetail(title: "證照", content: docDescript!.docCerts.trimmingCharacters(in: .whitespacesAndNewlines)))
                }
                if type == .demo3, docDescript!.docCerts != "" {
                    docDetail.append(DocDetail(title: "特殊治療項目", content: docDescript!.docCerts))
                }
                
                DispatchQueue.main.async { [self] in
                    guard let url = URL(string: docDescript!.docImgUrl) else {
                        return
                    }
                    docAvatorImgView.af.setImage(withURL: url)
                    docNameLabel.text = docDescript!.docName
                }
                docDetailTableView.reloadData()
            }
        }
    }

}

extension DoctorDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return docDetail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorDetailCell") as! DoctorDetailCell
        cell.setUp(title: docDetail[indexPath.row].title, content: docDetail[indexPath.row].content)
        return cell
    }
    
    
}
