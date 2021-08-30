//
//  Cells.swift
//  WebCrawler_iOS
//
//  Created by PeterLin on 2021/8/27.
//

import UIKit
import AlamofireImage

class DoctorDetailCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    func setUp(title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
    }
    
}
