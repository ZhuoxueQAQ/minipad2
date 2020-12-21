//
//  NewNoteViewController.swift
//  minipad2
//
//  Created by 灼雪 on 2020/12/9.
//

import UIKit
import os.log

class NewNoteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextViewDelegate{

    // MARK: - Proporties
    @IBOutlet weak var addSomethingButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var titleView: UITextView!
    @IBOutlet weak var detailView: UITextView!
    
    var newNoteItem: NoteItem?
    var itemViewTitle: String?
    var itemViewCreatedTime: String?
    var itemViewDetail: NSAttributedString?
    var nowMode: String?
    var imagePickerController: UIImagePickerController!
    let recordManager = RecordManager()
    var noteID: Int?
    var recordNameList = [String]()
    
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if self.recordNameList.count != 0 {
            print(self.recordNameList)
            print("Note \(self.noteID!) with \(self.recordNameList.count) records")
        }else {
            print("there is no record list")
        }
        // 编辑模式
        if nowMode == "Edit"{
            titleView.text = itemViewTitle
            detailView.attributedText = itemViewDetail
        }
        // 设置textView属性
        setAttritubesOfTextView()
        
        // 观测键盘弹出事件
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillAppear(notification:)), name: UITextView.keyboardWillShowNotification, object: nil)
        // 观测键盘消失事件
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillDisappear(notification:_:)), name: UITextView.keyboardWillHideNotification, object: nil)
        
    }
    // MARK: - 键盘出现
    @objc func keyboardWillAppear(notification: NSNotification){
        // 键盘大小信息
        let keyboardInfo = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        // 键盘高度
        let keyboardHeight = keyboardInfo.height
        print("keyboard: \(keyboardInfo.height)")
        if detailView.contentInset.bottom < keyboardHeight * 0.8{
            detailView.contentInset.bottom = keyboardHeight * 1.5
        }
    }
    // MARK: - 键盘消失
    @objc func keyboardWillDisappear(notification: NSNotification, _ sender: UITextView){
        // let keyboardInfo = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        detailView.contentInset.bottom = 0
    }
    // MARK: - AddSomething to the detail view
    @IBAction func addSomething(_ sender: UIButton) {
        // 可选项列表，底部向上弹出
        // 每按一次，都重新初始化一个UIAlertController
        let alertController = UIAlertController(title: "添加图片或超链接", message: "qaq", preferredStyle: .actionSheet)
        // 设置alertController
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "编辑笔记", style: .default){ action in
            // 默认为不可编辑，开启编辑后设置为true
            self.detailView.isEditable = true
        })
        alertController.addAction(UIAlertAction(title: "选择图片", style: .default) { action in
            self.pickImage()
        })
        alertController.addAction(UIAlertAction(title: "添加超链接", style: .default){ action in
            self.addHyperLinkToTextView()
        })
        alertController.addAction(UIAlertAction(title: "添加音频", style: .default){ action in
            self.addRecordToTextView()
        })
        // 播放当前noteID的音频
        alertController.addAction(UIAlertAction(title: "播放音频", style: .default){ action in
            // 当前note添加过录音
            if self.recordNameList.count != 0 {
                let recordListAlertController = UIAlertController(title: "选择录音", message: "", preferredStyle: .actionSheet)
                for i in 0 ..< self.recordNameList.count {
                    let nowRecordName = self.recordNameList[i]
                    recordListAlertController.addAction(UIAlertAction(title: "\(nowRecordName)", style: .default){ action in
                        // 播放当前录音
                        self.recordManager.play(nowRecordDiscription: nowRecordName, nowNoteItem: self.noteID!)
                    })
                }
                self.present(recordListAlertController, animated: true, completion: nil)
            }else {
                let recordListAlertController = UIAlertController(title: "该笔记未添加录音", message: "", preferredStyle: .alert)
                recordListAlertController.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
                self.present(recordListAlertController, animated: true, completion: nil)
            }
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        // configure the destination view controller only when the save button is pressed
        guard let button = sender as? UIBarButtonItem, button === saveButton else{
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        // set the newNoteItem that will be unwind to the tableview
        let newNoteTitle = titleView.text!
        let newNoteDetail = detailView.attributedText!
        // 如果是新建noteItem，此时createdTime为空，则创建一个时间，编辑的话则无需改变时间
        itemViewCreatedTime = (nowMode == "Add" ? getSystemTime() : itemViewCreatedTime)
        // 返回修改过的数据，这里把修改过的录音list也传回去保存
        newNoteItem = NoteItem(crDate: getSystemTime(), nTitle: newNoteTitle, nDetail: newNoteDetail, rNameList: self.recordNameList)
        
        // 变为只读模式
        self.detailView.isEditable = false
        self.detailView.dataDetectorTypes = UIDataDetectorTypes.link
    }
    
    // MARK: - Set the attributes of the textView
    func setAttritubesOfTextView(){
        titleView.layer.borderWidth = 1
        titleView.layer.borderColor = UIColor.black.cgColor
        
        detailView.layer.borderWidth = 1
        detailView.layer.borderColor = UIColor.black.cgColor
        
        // 通过富文本来设置行距
        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = 10
        // 添加样式属性
        let mutableStr = NSMutableAttributedString(attributedString: detailView.attributedText)
        mutableStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paraph, range: NSMakeRange(0, mutableStr.length))
        detailView.attributedText = mutableStr
    }
    
    // MARK: - select a image from the user's photo album and add it to the TextView
    func pickImage() {
        self.imagePickerController = UIImagePickerController()
        // 代理
        self.imagePickerController.delegate = self
        // 允许编辑
        self.imagePickerController.allowsEditing = true
        // 用户界面
        self.imagePickerController.sourceType = .photoLibrary
        // 显示imagepickController
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - Your delegate object’s implementation of this method should pass the specified media on to any custom code that needs it, and should then dismiss the picker view.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("media type: \(String(describing: info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerMediaType")]))")
        print("crop type: \(String(describing: info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerCropRect")]))")
        print("reference url: \(String(describing: info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerReferenceURL")]))")
        // get the image
        let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as! UIImage
        // add it to textView
        self.detailView.addImageToTextView(image: image)
        // dismiss the imagePickerController
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARk: -取消选择图片
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK: -Add Hyperlink
    func addHyperLinkToTextView(){
        // 弹窗提示添加超链接
        let addLinkAlertController = UIAlertController(title: "添加超链接", message: "请输入链接描述和链接url", preferredStyle: .alert)
        // 配置弹窗文本框收集描述文本和url
        // 闭包简写 只有一个参数将闭包写外面
        addLinkAlertController.addTextField(){ textField in
            textField.placeholder = "链接描述"
        }
        addLinkAlertController.addTextField(){ textField in
            textField.placeholder = "🔗"
        }
        // 添加action
        addLinkAlertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        addLinkAlertController.addAction(UIAlertAction(title: "创建", style: .default){ action in
            // 从textField数组中获取信息
            let discribe = addLinkAlertController.textFields![0].text
            let link = addLinkAlertController.textFields![1].text
            // 插入超链接
            self.detailView.appendLinkString(discribeString: discribe!, linkURL: link!)
        })
        // 记得显示提示框
        self.present(addLinkAlertController, animated: true, completion: nil)
    }
    
    // MARK: - 添加录音
    func addRecordToTextView(){
        let addRecordViewController = UIAlertController(title: "准备录音", message: "请添加录音描述", preferredStyle: .alert)
        addRecordViewController.addTextField(){ textfield in
            textfield.placeholder = "录音描述"
        }
        addRecordViewController.addAction(UIAlertAction(title: "开始录音", style: .default){ action in
            let record_Discription = addRecordViewController.textFields![0].text!
            // 开始录音
            self.recordManager.beginRecord(recordDiscription: record_Discription, nowNoteItem: self.noteID!)
            // 结束录音的alertController
            let stopRecordViewController = UIAlertController(title: "正在录音中", message: "点击按钮结束录音", preferredStyle: .alert)
            stopRecordViewController.addAction(UIAlertAction(title: "结束录音", style: .destructive){ action in
                // 结束录音
                self.recordManager.stopRecord()
                // 这里将录音名字-文件路径以超链接的形式添加到textView。
                self.detailView.appendLinkString(discribeString: record_Discription, linkURL: "file://\(self.recordManager.firstCreatedRecordPath)")
                // 将该录音的名字记录下来，
                self.recordNameList.append(record_Discription)
                print("Now noteID is: \(String(describing: self.noteID)), number of the records is \(self.recordNameList.count)")
                // 若有录音输出已有录音
                if self.recordNameList.count != 0 {
                    print(self.recordNameList)
                }
            })
            // 显示结束录音的弹窗
            self.present(stopRecordViewController, animated: true, completion: nil)
        })
        // 显示开始录音之前的弹窗
        self.present(addRecordViewController, animated: true, completion: nil)
    }
    
    // Asks the delegate whether the specified text view allows the specified type of user interaction with the specified URL in the specified range of text.
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch URL.scheme {
        case "file":
            self.recordManager.play(nowRecordDiscription: URL.absoluteString,nowNoteItem: self.noteID!)
            print(URL.absoluteString)
        default:
            print(URL.absoluteString)
        }
        return true
    }
    // MARK: - get system time
    func getSystemTime() -> String {
        let timeNow = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strNowTime = timeFormatter.string(from: timeNow) as String
        return strNowTime
    }

}
