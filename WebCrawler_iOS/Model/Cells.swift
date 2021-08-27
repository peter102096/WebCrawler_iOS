//
//  Cells.swift
//  WebCrawler_iOS
//
//  Created by PeterLin on 2021/8/27.
//

import UIKit
import AlamofireImage

class DocDescriptCell: UITableViewCell {
    @IBOutlet weak var docAvatarImgView: UIImageView!
    @IBOutlet weak var docNameLabel: UILabel!
    @IBOutlet weak var docExpLabel: UILabel!
    @IBOutlet weak var docSkillsLabel: UILabel!
    @IBOutlet weak var docCertsLabel: UILabel!
    
    func setUp(docDes: DocDescript) {
        guard let imgUrl = URL(string: docDes.docImgUrl) else { return }
        docAvatarImgView.af.setImage(withURL: imgUrl)
        docNameLabel.text = docDes.docName
        var docExp = ""
        for i in 0..<docDes.docExps.count {
            docExp.append("\(i+1) : \(String(docDes.docExps[i]))")
            if i != docDes.docExps.count - 1 {
                docExp.append("\n")
            }
        }
        docExpLabel.text = docExp
        docSkillsLabel.text = docDes.docSkills
        docCertsLabel.text = docDes.docCerts.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
