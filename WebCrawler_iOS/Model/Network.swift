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
                print(rate.at_xpath("//div[@class='doc_pic']")?.toHTML)
                print(rate.text)
            }
            
//            let rates = doc.xpath("/html/body/div[3]/div/div[1]/div")
//            print("rates count : \(rates.count)")
////            dump(rates)
//            for raaaa in rates {
//                print("dsdsdffs : \(raaaa.toHTML)")
//            }
//            print("------------------------------------")
//            for rate in doc.xpath("/html/body/div[3]/div/div[1]/div/div[2]") {
//                print("rate : \(rate.toHTML)")
//            }
        }
    }
}
