//
//  NoteItemModel.swift
//  minipad2
//
//  Created by 灼雪 on 2020/12/9.
//

import Foundation
import UIKit

class NoteItem: NSObject, NSCoding, NSSecureCoding{
    // 添加这一行，支持安全编码，遵循NSSecureCOding协议
    static var supportsSecureCoding: Bool = true
    
    // 两个NSCoding的协议化方法
    // 序列化
    func encode(with coder: NSCoder) {
        coder.encode(self.createDate, forKey: "createDate")
        coder.encode(self.noteTitle, forKey: "noteTitle")
        coder.encode(self.noteDetail, forKey: "noteDetail")
        coder.encode(self.recordNameList, forKey: "recordNameList")
    }
    
    // 反序列化
    required init?(coder: NSCoder) {
        self.createDate = coder.decodeObject(forKey: "createDate") as? String
        self.noteTitle = coder.decodeObject(forKey: "noteTitle") as? String
        self.noteDetail = coder.decodeObject(forKey: "noteDetail") as? NSAttributedString
        self.recordNameList = coder.decodeObject(forKey: "recordNameList") as? [String]
    }
    
    // 创建日期
    var createDate:String?
    // note标题
    var noteTitle:String?
    // note内容
    var noteDetail: NSAttributedString?
    // 存储某个note中的录音
    var recordNameList: [String]?
    
    init(crDate:String, nTitle: String, nDetail:NSAttributedString, rNameList: [String] = []) {
        createDate = crDate
        noteTitle = nTitle
        noteDetail = nDetail
        recordNameList = rNameList
    }
    
}

