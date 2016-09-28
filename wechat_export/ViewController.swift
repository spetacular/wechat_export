//
//  ViewController.swift
//  wechat_export
//
//  Created by yanxiaokun on 16/9/18.
//  Copyright © 2016年 yanxiaokun. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var srcPath = ""
    var dstPath = ""
    var videoTotalNum = 0
    var videoCurNum = 0
    var imageTotalNum = 0
    var imageCurNum = 0
    var exportTypes = [String]()
    @IBOutlet weak var srcFolder: NSTextField!
    
    @IBOutlet weak var dstFolder: NSTextField!
    
    @IBOutlet weak var videoBtn: NSButton!
    
    @IBOutlet weak var imageBtn: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let username = NSUserName()
        srcPath = "/Users/\(username)/Library/Containers/com.tencent.xinWeChat/Data/Library/Application Support/com.tencent.xinWeChat/"
        dstPath = "/Users/\(username)/Documents/wechat/"
        srcFolder.stringValue = srcPath
        dstFolder.stringValue = dstPath
    }
    

    @IBOutlet weak var exportBtn: NSButton!
    @IBAction func export(sender: NSButton) {
        if videoBtn.state == NSOnState{
            exportTypes.append("mp4")
        }
        if imageBtn.state == NSOnState{
            exportTypes.append("jpg")
            exportTypes.append("jpeg")
            exportTypes.append("png")
            exportTypes.append("gif")
            exportTypes.append("bmp")
        }
        if exportTypes.isEmpty{
            dialogOKCancel("错误提示",text: "请选择导出内容的类型")
            return
        }
        
        sender.enabled = false
        sender.stringValue = "开始导出……"
        
        exportAction()
        
        let resultTitle = "成功导出"
        let resultText = "共\(videoTotalNum)个视频，本次新增\(videoCurNum)个视频\n共\(imageTotalNum)个图片，本次新增\(imageCurNum)个图片"
        dialogOKCancel(resultTitle,text: resultText)
        
        sender.enabled = true
        sender.stringValue = "开始导出"
        videoTotalNum = 0
        videoCurNum = 0
        imageTotalNum = 0
        imageCurNum = 0
    }

    @IBAction func openSrcFolder(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        
        openPanel.beginWithCompletionHandler{(result)-> Void in
            if result == NSFileHandlingPanelOKButton{
                self.srcPath = openPanel.URL!.path!
                self.srcFolder.stringValue = self.srcPath
               
            }
        }
    }
    
    
    @IBAction func openDstFolder(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        
        openPanel.beginWithCompletionHandler{(result)-> Void in
            if result == NSFileHandlingPanelOKButton{
                self.dstPath = openPanel.URL!.path!
                self.dstFolder.stringValue = self.dstPath
            }
        }
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    private func findFiles(path: String, filterTypes: [String]) -> [String] {
        let enumerator:NSDirectoryEnumerator! = NSFileManager.defaultManager().enumeratorAtPath(path)
        var files = [String]()
        while let element = enumerator?.nextObject() as? String {
            let absPath = path+element
            files.append(absPath)
        }
        
        if filterTypes.count == 0 {
            return files
        }
        else {
            let filteredfiles = NSArray(array: files).pathsMatchingExtensions(filterTypes)
            return filteredfiles
        }
        
    }

    private func exportAction(){
        let fileManager = NSFileManager.defaultManager()
        
        if !fileManager.fileExistsAtPath(dstPath){
            try! fileManager.createDirectoryAtPath(dstPath,
                withIntermediateDirectories: true, attributes: nil)
        }
        
        let files = findFiles(srcPath, filterTypes: exportTypes)
        files.forEach { (file) -> () in
            let fileArr = file.componentsSeparatedByString("/")
            let fileName = fileArr.last!
            let isVideoFile = isVideo(fileName)
            let dstFile = dstPath + fileName
            
            if fileManager.fileExistsAtPath(dstFile) {
                print("Video already Saved: \(dstFile)")
            } else {
                print("Save Video \(fileName) To \(dstFile)")
                try! fileManager.copyItemAtPath(file, toPath: dstFile)
                if isVideoFile{
                    videoCurNum += 1
                }else{
                    imageCurNum += 1
                }
                
            }
            if isVideoFile{
                videoTotalNum += 1
            }else{
                imageTotalNum += 1
            }
            
        }
        print("DONE!")
    }
    
    private func isVideo(fileName: String)->Bool{
        return fileName.containsString("mp4");
    }
    
    
    private func dialogOKCancel(question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.Warning
        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        if res == NSAlertFirstButtonReturn {
            return true
        }
        return false
    }
}

