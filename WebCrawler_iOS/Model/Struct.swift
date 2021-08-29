//
//  Struct.swift
//  WebCrawler_iOS
//
//  Created by PeterLin on 2021/8/27.
//

import Foundation

struct DocDescript {
    let docImgUrl:String
    let docName: String
    var docExps: [Substring] = []
    var docExps2: String = ""
    let docSkills: String
    let docCerts: String
}

struct DocDetail {
    let title: String
    let content: String
}
