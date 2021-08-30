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
    
    private let sharedSession: Session = {
            let manager = ServerTrustManager(evaluators: ["zh-tw.sltung.com.tw": DisabledTrustEvaluator()])
            let configuration = URLSessionConfiguration.af.default
            configuration.timeoutIntervalForRequest = 30
            return Session(configuration: configuration, serverTrustManager: manager)
        }()
    
    let demoUrl1 = "https://zh-tw.sltung.com.tw/tung/Salu/department.php?d_id=1"
    let demoUrl2 = "http://www.ktgh.com.tw/HRE_VSDPT_Look.asp?CatID=120&ModuleType=Y&NewsID=15"
    let demoUrl3 = "http://www.ktgh.com.tw/web/index.asp?DataID=34&CatID=12"

    private(set) var docDetail: DocDescript? = nil
    
    private let big5encoding: String.Encoding
    
    override init() {
        print("init")
        let value = CFStringEncoding(CFStringEncodings.big5_HKSCS_1999.rawValue)
        let big5 = CFStringConvertEncodingToNSStringEncoding(value)
        big5encoding = String.Encoding(rawValue: big5)
        super.init()
    }
    
    deinit {
        print("deinit")
    }
    
    func getDoctorDetail(type: Demo, selectDocName: String, completion: @escaping (Bool) -> Void) {
        let demoUrl: String
        switch type {
        case .demo1:
            demoUrl = demoUrl1
        case .demo2:
            demoUrl = demoUrl2
        case .demo3:
            demoUrl = demoUrl3
        }

        sharedSession.request(demoUrl, method: .get).response { [self] response in
            guard let result = response.data else {
                completion(false)
                return
            }
            let htmlString: String?
            if type == .demo1 {
                htmlString = String(data: result, encoding: .utf8)
            } else {
                htmlString = String(data: result, encoding: big5encoding)
            }
            guard htmlString != nil else {
                completion(false)
                return
            }
            docDetail = parserDocInfo(type: type, selectDocName: selectDocName, html: htmlString!)
            if docDetail == nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    fileprivate func parserDocInfo(type: Demo, selectDocName: String, html: String) -> DocDescript? {
        switch type {
        case .demo1:
            return parserDemo1(html: html, selectDocName: selectDocName)
        case .demo2:
            return parserDemo2(html: html, selectDocName: selectDocName)
        case .demo3:
            return parserDemo3(html: html, selectDocName: selectDocName)

        }
    }
    
    fileprivate func parserDemo1(html: String, selectDocName: String) -> DocDescript? {
        if let doc = try? Kanna.HTML(html: html, encoding: .utf8) {
            let rates = doc.xpath("//div[@class='doctor_descript group']")
            for rate in rates {
                guard let docName = rate.at_xpath("//div[@class='doc_detail']")?.at_xpath("//table")?.at_xpath("//thead")?.at_xpath("//tr")?.at_xpath("//td[@colspan='2']")?.text else { return nil }
                if docName.contains(selectDocName) {
                    guard let docPicUrl = rate.at_xpath("//div[@class='doc_pic']")?.at_xpath("//input[@type='image']")?["src"] else { return nil }
                    
                    guard let docExperience = rate.at_xpath("//div[@class='doc_detail']")?.at_xpath("//table")?.at_xpath("//tbody")?.at_xpath("//tr")?.css("td")[1].text else { return nil }
                    let docExpArray = docExperience.split(separator: "\r\n")
                    guard let docSkills = rate.at_xpath("//div[@class='doc_detail']")?.at_xpath("//table")?.at_xpath("//tbody")?.css("tr")[1].css("td")[1].text else { return nil }
                    guard let docCerts =  rate.at_xpath("//div[@class='doc_detail']")?.at_xpath("//table")?.at_xpath("//tbody")?.css("tr")[2].css("td")[1].text else { return nil }
                    return DocDescript(docImgUrl: docPicUrl.trimmingCharacters(in: .whitespaces), docName: docName, docExps: docExpArray, docSkills: docSkills, docCerts: docCerts)
                }
            }
        }
        return nil
    }
    
    fileprivate func parserDemo2(html: String, selectDocName: String) -> DocDescript? {
        if let doc = try? Kanna.HTML(html: html, encoding: .utf8) {
            guard let rates =
                    doc.xpath("//div[@id='Sizebox']")[0].at_xpath("//table")?.at_xpath("//table")?.xpath("//tr//td[@valign='top']//table[@border='0']")[2].xpath("//table[@width='100%']") else { return nil }
            for rate in rates {
                guard var docName = rate.at_xpath("//tr//td")?.at_xpath("//font[@color='#330099']")?.text else {
                    return nil
                }
                if docName.contains(selectDocName) {
                    if docName.contains("（") {
                        var endIndex = 0
                        let docNameArray = Array(docName)
                        for i in 0..<docNameArray.count {
                            if docNameArray[i] == "）" {
                                endIndex = i+1
                            }
                        }
                        let range = docName.startIndex..<docName.index(docName.startIndex, offsetBy: endIndex)
                        docName.removeSubrange(range)
                        docName = docName.trimmingCharacters(in: .whitespaces)
                    }
                    guard let docImgUrl = rate.at_xpath("//tr//td[@style='vertical-align:top;padding-top:3em;']")?.at_xpath("//img")?["src"]?.replacingOccurrences(of: "../", with: "http://www.ktgh.com.tw/") else { return nil }
                    guard var docExpsAndSkill = rate.at_xpath("//tr//td")?.at_xpath("//ul")?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
                    //移除學經歷Title
                    let docExpsAndSkillRange = docExpsAndSkill.startIndex..<docExpsAndSkill.index(docExpsAndSkill.startIndex, offsetBy: 4)
                    docExpsAndSkill.removeSubrange(docExpsAndSkillRange)
                    var docExps = ""
                    var docSkills = ""
                    var expsEndIndex = 0
                    let docExpsAndSkillArray = Array(docExpsAndSkill)
                    //判斷主治項目的字串位置，需要移除
                    for i in 0..<docExpsAndSkillArray.count {
                        if docExpsAndSkillArray[i] == "主" {
                            if docExpsAndSkillArray[i+1] == "治", docExpsAndSkillArray[i+2] == "項", docExpsAndSkillArray[i+3] == "目" {
                                expsEndIndex = i
                            }
                        }
                    }
                    //移除主治項目
                    docExps = docExpsAndSkill
                    let expsRange = docExps.index(docExps.startIndex, offsetBy: expsEndIndex)..<docExps.endIndex
                    docExps.removeSubrange(expsRange)
                    docSkills = docExpsAndSkill
                    let skillRange = docSkills.startIndex..<docSkills.index(docSkills.startIndex, offsetBy: expsEndIndex+5)
                    docSkills.removeSubrange(skillRange)
                    return DocDescript(docImgUrl: docImgUrl, docName: String(docName), docExps2: docExps, docSkills: docSkills, docCerts: "")
                }
            }
        }
        return nil
    }
    
    fileprivate func parserDemo3(html: String, selectDocName: String) -> DocDescript? {
            if let doc = try? Kanna.HTML(html: html, encoding: .utf8) {
                let rates = doc.xpath("//td[@class='Article_Context2']")
                
                let docs = rates[0].css("table")
                for doc in docs {
                    guard let docName = doc.at_xpath("//td[@class='text_05']")?.at_xpath("//p")?.text else { return nil }
                    if docName.contains(selectDocName) {
                        guard let docImgUrl = doc.at_xpath("//td[@class='text_05']")?.at_xpath("//img")?["src"]?.replacingOccurrences(of: "./", with: "http://www.ktgh.com.tw/web/") else { return nil }
                        var docExps = ""
                        var docSkills = ""
                        var docSpecSkills = ""
                        if let exps = doc.at_xpath("//td[@class='text_05']")?.xpath("//ol//li"), exps.count > 0 {
                            for exp in exps {
                                guard exp.text != nil else {
                                    return nil
                                }
                                docExps.append(exp.text!)
                            }
                        } else {
                            guard let pCount = doc.at_xpath("//td[@class='text_05']")?.xpath("//p") else { return nil }
                            if pCount.count > 5 {
                                guard let exps2 = doc.at_xpath("//td[@class='text_05']")?.xpath("//p") else { return nil }
                                for exp in exps2 {
                                    if ((exp.text?.rangeOfCharacter(from: .decimalDigits)) != nil) {
                                        docExps.append("\(exp.text!)\n")
                                    }
                                }
                            } else {
                                guard let exps3 = doc.at_xpath("//td[@class='text_05']")?.xpath("//p")[1].text?.replacingOccurrences(of: "學經歷", with: "") else { return nil }

                                let exps3Array = exps3.ranges(of: "\\b[0-9].[\\u4E00-\\u9FA5]*", options: .regularExpression).map { exps3[$0].trimmingCharacters(in: .whitespaces) }
                                for exp in exps3Array {
                                    docExps.append("\(exp)\n")
                                }
                            }
                        }
                        
                        guard var docSkillsAndSpecSkills = doc.at_xpath("//td[@class='text_05']")?.xpath("//p")[2].text else { return nil }
                        if docSkillsAndSpecSkills.contains("主治項目") {
                            docSkillsAndSpecSkills = docSkillsAndSpecSkills.replacingOccurrences(of: "主治項目", with: "")
                            if docSkillsAndSpecSkills.contains("特殊治療項目") {
                                var specEndIndex = 0
                                let docSkillsAndSpecSkillsArray = Array(docSkillsAndSpecSkills)
                                //判斷特殊治療項目的字串位置，後面會用到
                                for i in 0..<docSkillsAndSpecSkillsArray.count {
                                    if docSkillsAndSpecSkillsArray[i] == "特" {
                                        if docSkillsAndSpecSkillsArray[i+1] == "殊", docSkillsAndSpecSkillsArray[i+2] == "治", docSkillsAndSpecSkillsArray[i+3] == "療", docSkillsAndSpecSkillsArray[i+4] == "項", docSkillsAndSpecSkillsArray[i+5] == "目" {
                                            specEndIndex = i
                                        }
                                    }
                                }
                                //移除特殊治療項目的內容，以便取得完整主治項目的內容
                                docSkills = docSkillsAndSpecSkills
                                let skillsRange = docSkills.index(docSkills.startIndex, offsetBy: specEndIndex)..<docSkills.endIndex
                                docSkills.removeSubrange(skillsRange)

                                //移除主治項目的內容，以便取得完整特殊治療項目的內容
                                docSpecSkills = docSkillsAndSpecSkills
                                let specSkillsRange = docSpecSkills.startIndex..<docSpecSkills.index(docSpecSkills.startIndex, offsetBy: specEndIndex+6)
                                docSpecSkills.removeSubrange(specSkillsRange)
                            } else {
                                docSkills = docSkillsAndSpecSkills
                            }
                            return DocDescript(docImgUrl: docImgUrl, docName: docName, docExps2: docExps, docSkills: docSkills, docCerts: docSpecSkills)
                        } else {
                            guard let count = doc.at_xpath("//td[@class='text_05']")?.xpath("//p").count else { return nil }
                            if doc.at_xpath("//td[@class='text_05']")?.xpath("//p")[count-2].text != nil {
                                docSkills = (doc.at_xpath("//td[@class='text_05']")?.xpath("//p")[count-2].text)!
                                return DocDescript(docImgUrl: docImgUrl, docName: docName, docExps2: docExps, docSkills: docSkills, docCerts: "")
                            }
                        }
                       
                        
                        
                    }
                }
            }
            return nil
        }
}

extension Network {
    enum Demo {
        case demo1, demo2, demo3
    }
}

extension Data {
    var big5String: String? {
        let big5 = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.big5.rawValue))
            
            return NSString(data: self, encoding: big5) as? String;
            
        }
}

extension StringProtocol {
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...].range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
