//
//  NSMutableAttributedString.swift
//  minipad2
//
//  Created by 灼雪 on 2020/12/17.
//

import Foundation
import UIKit

extension UITextView {
    public func appendLinkString(discribeString: String = "", linkURL: String){
        print("appending link \(linkURL) to str \(discribeString)")
        let orignalTypingAttritube = self.typingAttributes
        // 如果没有描述文本，则默认描述文本为超链接字符串
        let discribeString = (discribeString == "" ? linkURL: discribeString)
        // 原始文本
        let mutableStr = NSMutableAttributedString(attributedString: self.attributedText)
        // 新增超链接文本, 字体和原始textview保持一致
        // let newAttr = [NSAttributedString.Key.font: self.font]
        let newAppendString = NSMutableAttributedString(string: discribeString)
        let url = NSURL(string: linkURL)
        let range = NSMakeRange(0, newAppendString.length)
        // 添加url属性
        newAppendString.addAttribute(NSAttributedString.Key.link, value: url, range: range)
        // newAppendString.setAttributes([.link: url], range: range)
        // 在当前光标处插入超链接文本
        mutableStr.insert(newAppendString, at: self.selectedRange.location)
        mutableStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15.0), range: NSMakeRange(0, mutableStr.length))
        // 更新富文本和光标位置
        let newSelectedRange = NSMakeRange(selectedRange.location + newAppendString.length, 0)
        self.attributedText = mutableStr
        self.selectedRange = newSelectedRange
        self.typingAttributes = orignalTypingAttritube
    }
    
    public func addImageToTextView(image: UIImage) {
        // 创建附件
        let attachment = NSTextAttachment()
        // 设置附件的图片
        attachment.image = image
        let scale = (self.frame.width - 2*5) / image.size.width
        // 图片尺寸
        attachment.bounds = CGRect(x: 0, y: 0, width: scale * image.size.width, height: scale * image.size.height)
        // 将附件转换为属性化文本
        let attStr = NSAttributedString(attachment: attachment)
        // 获取textview的文本并转换为可变文本，记录光标位置，插入上一步的属性化文本
        let mutableStr = NSMutableAttributedString(attributedString: self.attributedText)
        // 获取目前光标位置
        let selectedRange = self.selectedRange
        // 在指定位置插入图片，可以用append直接插到末尾
        mutableStr.insert(attStr, at: selectedRange.location)
        // 设置新的可变文本的属性，计算插入后的光标位置
        mutableStr.addAttribute(NSAttributedString.Key.font, value: self.font, range: NSMakeRange(0, mutableStr.length))
        let newSelectedRange = NSMakeRange(selectedRange.location + attStr.length, 0)
        
        self.attributedText = mutableStr
        self.selectedRange = newSelectedRange
        self.attributedText = mutableStr
    }

}
