//
//  GetHtmlSource.swift
//  WebCrawler_iOS
//
//  Created by PeterLin on 2021/8/26.
//

import UIKit
import Alamofire
import Kanna

class Network: NSObject {
    
    //https://zh-tw.sltung.com.tw/tung/Salu/department.php?d_id=1
    //http://www.ktgh.com.tw/HRE_VSDPT_Look.asp?CatID=120&ModuleType=Y&NewsID=15
    //http://www.ktgh.com.tw/web/Neurology/

    override init() {
        print("init")
    }
    
    deinit {
        print("deinit")
    }
    
    func getHtmlSource() {
        AF.request("https://zh-tw.sltung.com.tw/tung/Salu/department.php?d_id=1", method: .get).responseString() { [self] response in
            guard let result = try? response.result.get() else {
                return
            }
//            print("\(result)")
            parserDocInfo(html: result)
            
        }
    }
    
    func parserDocInfo(html: String) {
        //
        
        if let doc = try? Kanna.HTML(html: html, encoding: .utf8) {
            let rates = doc.xpath("//div[@class='doctor_descript group']")
            print("rates count : \(rates.count)")
            for rate in rates {
                guard let docPicUrl = rate.at_xpath("//div[@class='doc_pic']")?.at_xpath("//input[@type='image']")?["src"] else { return }
                print("docPicUrl : \(docPicUrl)")
                guard let docName = rate.at_xpath("//div[@class='doc_detail']")?.at_xpath("//table")?.at_xpath("//thead")?.at_xpath("//tr")?.at_xpath("//td[@colspan='2']")?.text else { return }
                print("docName : \(docName)")
                guard let docExperience = rate.at_xpath("//div[@class='doc_detail']")?.at_xpath("//table")?.at_xpath("//tbody")?.at_xpath("//tr")?.css("td")[1].text else { return }
                let docExpArray = docExperience.split(separator: "\r\n")
                print("docExperience : \(docExpArray)")
                guard let docSkills = rate.at_xpath("//div[@class='doc_detail']")?.at_xpath("//table")?.at_xpath("//tbody")?.css("tr")[1].css("td")[1].text else { return }
                print("docSkills : \(docSkills)")
                guard let docCerts =  rate.at_xpath("//div[@class='doc_detail']")?.at_xpath("//table")?.at_xpath("//tbody")?.css("tr")[2].css("td")[1].text else { return }
                print("docCerts : \(docCerts.trimmingCharacters(in: .whitespacesAndNewlines))")
            }
        }
    }
}
