//
//  MainViewController.swift
//  MessageBoard
//
//  Created by imac-3700 on 2025/7/7.
//

import UIKit
import Foundation
import RealmSwift


class MessageBoardData: Object {
    /// 使用 ObjectId 作為唯一識別碼
    @Persisted(primaryKey: true) var _id : ObjectId
    /// 使用者名稱
    @Persisted var name: String = ""
    /// 留言內容
    @Persisted var content: String = ""
    /// 留言日期時間
    @Persisted var date: String = ""
    
    convenience init(name: String, content: String, date: String ) {
        self.init()
        self.name = name
        self.content = content
        self.date = date
    }
}


class MainViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var lbUser: UILabel!
    @IBOutlet weak var txfUser: UITextField!
    @IBOutlet weak var lbComments: UILabel!
    @IBOutlet weak var txvContent: UITextView!
    @IBOutlet weak var btnSort: UIButton!
    @IBOutlet weak var btnSent: UIButton!
    @IBOutlet weak var tbvTest: UITableView!
    
    // MARK: - Property
    /// 用來儲存資料庫的陣列
    var messageArray: [MessageBoardData] = []
    
    /// 排序功能，利用true和false控制，預設降序false
    /// true: 升序（舊到新）, false: 降序（新到舊）
    var isAscending = false
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()      // 設定使用者介面
        dataBase()   // 載入資料庫資料
    }
    
    // MARK: - UI Setting
    
    // MARK: - IBAcion
    
    /// 送出按鈕點擊事件
    @IBAction func btnSentAction(_ sender: Any) {
        let realm = try! Realm()
        
        // 檢查按鈕標題是否為「送出」
        if btnSent.currentTitle == "送出" {
            // 取得使用者輸入的文字
            if let user = txfUser.text, let message = txvContent.text {
                // 檢查輸入是否為空
                if !user.isEmpty && !message.isEmpty {
                    let date = getSystemTime()  // 取得當前時間
                    let newMessage = MessageBoardData(name: user, content: message, date: date)
                    
                    // 寫入資料庫
                    try! realm.write {
                        realm.add(newMessage)
                        
                        // 根據排序方式添加到陣列
                        if isAscending {
                            messageArray.append(newMessage)      // 升序：加到最後
                        } else {
                            messageArray.insert(newMessage, at: 0) // 降序：加到最前
                        }
                        tbvTest.reloadData()  // 重新載入表格視圖
                        
                        // 清空輸入框
                        txfUser.text = ""
                        txvContent.text = ""
                    }
                    print("新增新留言時間: \(date)")
                } else {
                    // 顯示錯誤提示
                    showAlert(message: "請輸入使用者名稱和內容")
                }
            }
        }
    }
    
    /// 排序按鈕點擊事件
    @IBAction func btnSortSection(_ sender: Any) {
        showSortOptions()  // 顯示排序選項
    }
    
    // MARK: - Function
    
    /// 設定表格視圖
    func tableSet() {
        // 註冊自定義的表格視圖 Cell
        tbvTest?.register(UINib(nibName : "MainTableViewCell", bundle: nil), forCellReuseIdentifier: MainTableViewCell.identified())
        
        // 設定資料源和代理
        tbvTest?.dataSource = self
        tbvTest?.delegate = self
    }
    
    /// 設定使用者介面
    func setUI() {
        tableSet()  // 設定表格視圖
        btnSent.setTitle("送出", for: .normal)  // 設定按鈕標題
    }
    
    /// 取得系統當前時間
    func getSystemTime() -> String {
        let currentDateTime = Date()
        let dataFormatter: DateFormatter = DateFormatter()
        
        dataFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dataFormatter.locale = Locale.ReferenceType.system
        dataFormatter.timeZone = TimeZone.ReferenceType.system
        return dataFormatter.string(from: currentDateTime)
    }
    
    /// 顯示排序選項的動作表單
    func showSortOptions() {
        //使用 UIAlertController 的 actionSheet 樣式。會從螢幕底部滑出一個選項列表
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 升序選項
        let ascendingAction = UIAlertAction(title: "按時間由舊到新排序", style: .default) { [weak self] _ in
            self?.isAscending = true
            self?.sortMessages()
            self?.tbvTest?.reloadData()
        }
        
        // 降序選項
        let descendingAction = UIAlertAction(title: "按時間由新到舊排序", style: .default) { [weak self] _ in
            self?.isAscending = false
            self?.sortMessages()
            self?.tbvTest?.reloadData()
        }
        
        // 取消選項
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        // 添加所有選項
        alertController.addAction(ascendingAction)
        alertController.addAction(descendingAction)
        alertController.addAction(cancelAction)
        
        // 為 iPad 設定 popover
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = btnSort
            popoverController.sourceRect = btnSort.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// 排序留言陣列
    func sortMessages() {
        messageArray.sort{ (messages1, message2) -> Bool in
            if isAscending {
                return messages1.date < message2.date  // 升序排序
            } else {
                return messages1.date > message2.date  // 降序排序
            }
        }
    }
    
    /// 從資料庫載入資料
    func dataBase() {
        let realm = try! Realm()
        let messageBoardData = realm.objects(MessageBoardData.self)  // 取得所有留言資料
        messageArray = Array(messageBoardData)  // 轉換為陣列
        sortMessages()  // 排序
        tbvTest?.reloadData()  // 重新載入表格視圖
        print("file :a \(realm.configuration.fileURL!)")  // 印出資料庫檔案位置
    }
    
    /// 顯示提示訊息
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /// 編輯留言
    func editMessage(_ message: MessageBoardData, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "編輯留言", message: nil, preferredStyle: .alert)
        
        // 添加文字輸入框，預設顯示原本的內容
        alertController.addTextField { (textField) in
            textField.text = message.content
        }
        
        // 儲存按鈕
        let saveAction = UIAlertAction(title: "儲存", style: .default) { [weak self] (_) in
            guard let newContent = alertController.textFields?.first?.text, !newContent.isEmpty else { return }
            let realm = try! Realm()
            
            // 更新資料庫中的留言內容和時間
            try! realm.write {
                message.content = newContent
                message.date = self?.getSystemTime() ?? ""
            }
            
            // 重新載入表格視圖
            self?.tbvTest.reloadRows(at: [indexPath], with: .automatic)
            self?.sortMessages()
            self?.tbvTest.reloadData()
        }
        
        // 取消按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /// 刪除留言
    func deleteMessage(_ message: MessageBoardData, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "刪除", message: "確定刪除嗎？", preferredStyle: .alert)
        
        // 確定刪除按鈕
        let deleteAction = UIAlertAction(title: "確定", style: .default) { [weak self] _ in
            let realm = try! Realm()
            
            // 從資料庫刪除
            try! realm.write {
                realm.delete(message)
            }
            
            // 從陣列移除並更新表格視圖
            self?.messageArray.remove(at: indexPath.row)
            self?.tbvTest.deleteRows(at: [indexPath], with: .fade)
        }
        
        // 取消按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Extensions
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// 返回表格視圖的行數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    /// 設定表格視圖的每一行
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TableView 並不會為每一筆資料都創建一個新的 Cell，而是會重用滑出螢幕的 Cell。
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identified(), for: indexPath) as? MainTableViewCell else {
            return MainTableViewCell()
        }
        
        let message = messageArray[indexPath.row]
        
        // 建立帶有樣式的文字
        let fullText = "\(message.name): \(message.content)"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // 設定使用者名稱的範圍
        let nameRange = NSRange(location: 0, length: message.name.count)
        
        // 設定使用者名稱的顏色為系統藍色
        let userColor = UIColor.systemBlue
        attributedString.addAttribute(.foregroundColor, value: userColor, range: nameRange)
        
        // 設定使用者名稱為粗體
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: nameRange)
        
        // 設定 Cell 的內容
        cell.lbContent.attributedText = attributedString
        cell.lbDate.text = "時間： \(message.date)"
        
        return cell
    }
    
    /// 設定右滑動作（刪除）
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 刪除動作
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let message = self.messageArray[indexPath.row]
            self.deleteMessage(message, at: indexPath)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .red  // 設定背景色為紅色
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true  // 允許完整滑動執行動作
        return configuration
    }
    
    /// 設定左滑動作（編輯）
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 編輯動作
        let editAction = UIContextualAction(style: .normal, title: "編輯") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let message = self.messageArray[indexPath.row]
            self.editMessage(message, at: indexPath)
            completionHandler(true)
        }
        
        editAction.backgroundColor = .blue  // 設定背景色為藍色
        
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        configuration.performsFirstActionWithFullSwipe = true  // 允許完整滑動執行動作
        return configuration
    }
}
