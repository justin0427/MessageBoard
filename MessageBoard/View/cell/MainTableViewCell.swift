//
//  MainTableViewCell.swift
//  MessageBoard
//
//  Created by imac-3700 on 2025/7/7.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    // MARK: - IBOutlet 介面元件連接
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    
    // MARK: - Static Properties
    static let identifier = "MainTableViewCell"
    
    // MARK: - Static Methods
    static func identified() -> String {
        return identifier
    }
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()  // 設定使用者介面
    }

    /// 當 Cell 被選取或取消選取時執行
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 設定內容標籤可以顯示多行文字
        lbContent.numberOfLines = 0
        // 設定日期標籤可以顯示多行文字
        lbDate.numberOfLines = 0
        // 設定內容標籤的換行模式為按單字換行
        lbContent.lineBreakMode = .byWordWrapping
        // 設定日期標籤的換行模式為按單字換行
        lbDate.lineBreakMode = .byWordWrapping
    }
}
