//
//  RecordManager.swift
//  minipad2
//
//  Created by 灼雪 on 2020/12/20.
//

import Foundation
import AVFoundation

class RecordManager{
    var recorder:AVAudioRecorder?
    var player : AVAudioPlayer?
    var diskRootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    var firstCreatedRecordPath = ""
    var firstRecordName = ""
    
    // MARK: - 需要注意的是开始录音和结束录音的路径时一样的，而读取录音并播放的路径则不唯一
    
    //开始录音
    func beginRecord(recordDiscription: String, nowNoteItem: Int) {
        // 记录录音第一次创建时的路径，开始录音和结束录音保存数据的时候都要用到
        firstRecordName = recordDiscription
        firstCreatedRecordPath = (diskRootPath.appending("/\(nowNoteItem)-\(recordDiscription).wav"))
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSession.Category.playAndRecord)
        } catch let err{
            print("设置类型失败:\(err.localizedDescription)")
        }
        
        // 设置session动作
        do {
            try session.setActive(true)
        } catch let err {
            print("初始化动作失败:\(err.localizedDescription)")
        }
        
        // 录音设置,注意,后面需要转换成NSNumber,如果不转换,你会发现,无法录制音频文件,
        let recordSetting:[String:Any] = [AVSampleRateKey:NSNumber(value:16000),//采样集
            AVFormatIDKey:NSNumber(value: kAudioFormatLinearPCM),//音频格式
            AVLinearPCMBitDepthKey:NSNumber(value:16),//采样位数
            AVNumberOfChannelsKey:NSNumber(value: 1),//通道数
            AVEncoderAudioQualityKey:NSNumber(value: AVAudioQuality.min.rawValue)//录音质量
        ]
        
        // 开始录音
        do {
            let url = URL(fileURLWithPath: firstCreatedRecordPath)
            recorder = try AVAudioRecorder(url: url, settings: recordSetting)
            recorder!.prepareToRecord()
            recorder!.record()
            print("开始录音")
        } catch let err {
            print("录音失败:\(err.localizedDescription)")
        }
    }
    
    // 结束录音
    func stopRecord() {
        if let recorder = self.recorder{
            if recorder.isRecording {
                print("正在录音,马上结束它,文件保存到了:\(firstCreatedRecordPath)")
            }else{
                print("没有录音,但是依然结束它")
            }
            recorder.stop()
            self.recorder = nil
        }else{
            print("没有初始化")
        }
    }
    
    //播放
    func play(nowRecordDiscription: String, nowNoteItem: Int) {
        do {
            let nowFilePath = diskRootPath.appending("/\(nowNoteItem)-\(nowRecordDiscription).wav")
            print("loading record file: \(String(describing: nowFilePath))")
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: nowFilePath))
            print("歌曲长度:\(player!.duration)")
            player!.play()
            
        } catch let err {
            print("播放失败:\(err.localizedDescription)")
        }
    }
}
