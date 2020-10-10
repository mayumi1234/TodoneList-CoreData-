//
//  ViewController.swift
//  ToDoneList
//
//  Created by m.yamanishi on 2020/09/06.
//  Copyright © 2020 Mayumi Yamanishi. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIStackView!
    @IBOutlet weak var graphButton: UIButton!
    
    typealias MySectionRow = (mySection: String, date: Date, myRow: Array<TodoneTask>)
    var mySectionRows = [MySectionRow]()
    var tasks = [TodoneTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableviewSetup()
        
        bottomView.isHidden = true
        graphButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData()
        mainTableView.reloadData()
    }
    
    // get data
    func getData(){
        if tasks.count != 0 {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            do {
                tasks = try context.fetch(TodoneTask.fetchRequest())
                
                mySectionRows.removeAll()
                
                // sectionに日付を追加
                for i in 0..<tasks.count {
    //                すでに日付が入っているときは、該当のセクションにタスクを追加する
                    if let index = self.mySectionRows.firstIndex(where: { $0.mySection == tasks[i].dateString }) {
                        self.mySectionRows[index].myRow.append(tasks[i])
                    } else {
    //                    新しい日付が入ってきたときに、新しいセクションを作成
                        self.mySectionRows.insert((tasks[i].dateString!, tasks[i].date!, [tasks[i]]), at: 0)
                    }
                    sortArray()
                }
            }
            catch{
                print("読み込み失敗！")
            }
        }
    }
    
    // delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath:IndexPath){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete{
            
            let task = mySectionRows[indexPath.section].myRow[indexPath.row]
            context.delete(task)
            
            if let mySectionRowIndex = self.mySectionRows.firstIndex(where: { $0.myRow.contains(where: { $0.documentId == task.documentId }) }) {
                self.mySectionRows[mySectionRowIndex].myRow.removeAll(where: { $0.documentId == task.documentId })
                if self.mySectionRows[mySectionRowIndex].myRow.count == 0 {
                    self.mySectionRows.remove(at: mySectionRowIndex)
                }
            }
            
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                tasks = try context.fetch(TodoneTask.fetchRequest())
            }
            catch{
                print("読み込み失敗！")
            }
        }
        tableView.reloadData()
        
    }
    
    private func tableviewSetup() {
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        //UILongPressGestureRecognizer（長押しイベント）宣言
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))
        longPressGestureRecognizer.delegate = self

        //tableviewにrecognizerを設定
        mainTableView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        AdsSetup()
    }
    
    private func sortArray() {
        self.mySectionRows.sort { (m1, m2) -> Bool in
            let m1Date = m1.date
            let m2Date = m2.date
            return m1.mySection > m2.mySection
        }
    }
    
    @IBAction func addToDoneButton(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "AddToDone", bundle: nil)//遷移先のStoryboardを設定
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddToDoneViewController") as! AddToDoneViewController//遷移先のViewControllerを設定
        self.navigationController?.pushViewController(nextView, animated: true)//遷移する
    }
    
    private func AdsSetup() {
        // 広告ユニットID
        let AdMobID = "ca-app-pub-6973369736628977/7781631026"
        // テスト用広告ユニットID
        let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
        // true:テスト
        let AdMobTest:Bool = true
        
        var admobView = GADBannerView()
        admobView = GADBannerView(adSize:kGADAdSizeBanner)
        
        if #available(iOS 11.0, *) {
//            admobView.frame.origin = CGPoint(x:0, y: self.view.frame.size.height - admobView.frame.height - self.bottomBarHeight.constant - self.view.safeAreaInsets.bottom)
            admobView.frame.origin = CGPoint(x:0, y: self.view.frame.size.height - admobView.frame.height - self.view.safeAreaInsets.bottom)
        } else {
//            admobView.frame.origin = CGPoint(x:0, y: self.view.frame.size.height - admobView.frame.height - self.bottomBarHeight.constant)
            admobView.frame.origin = CGPoint(x:0, y: self.view.frame.size.height - admobView.frame.height)
        }
        admobView.frame.size = CGSize(width: self.view.frame.width, height:admobView.frame.height)
        bottomTableViewConstraint.constant = admobView.frame.size.height
        
        if AdMobTest {
            admobView.adUnitID = TEST_ID
        }
        else{
            admobView.adUnitID = AdMobID
        }
        
        admobView.rootViewController = self
        admobView.load(GADRequest())
        
        self.view.addSubview(admobView)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    //セル長押し時
    @objc func cellLongPressed(sender : UILongPressGestureRecognizer){
        //押された位置でcellのpathを取得
        let point = sender.location(in: mainTableView)
        let indexPath = mainTableView.indexPathForRow(at: point)

        //アラート生成
        let actionSheet = UIAlertController(title: "メニュー", message: "", preferredStyle: UIAlertController.Style.actionSheet)

        let action1 = UIAlertAction(title: "編集", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            let storyboard: UIStoryboard = UIStoryboard(name: "ModifyToDone", bundle: nil)//遷移先のStoryboardを設定
            let nextView = storyboard.instantiateViewController(withIdentifier: "ModifyAddToDoneViewController") as! ModifyAddToDoneViewController//遷移先のViewControllerを設定
            nextView.task = self.mySectionRows[indexPath!.section].myRow[indexPath!.row]
            self.navigationController?.pushViewController(nextView, animated: true)//遷移する
        })

        let action2 = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in

//            選択されたセルを削除する
            let docId = self.mySectionRows[indexPath!.section].myRow[indexPath!.row].documentId
            let task = self.mySectionRows[indexPath!.section].myRow[indexPath!.row]
            
            if let mySectionRowIndex = self.mySectionRows.firstIndex(where: { $0.myRow.contains(where: { $0.documentId == task.documentId }) }) {
                self.mySectionRows[mySectionRowIndex].myRow.removeAll(where: { $0.documentId == task.documentId })
                if self.mySectionRows[mySectionRowIndex].myRow.count == 0 {
                    self.mySectionRows.remove(at: mySectionRowIndex)
                }
            }
            self.mainTableView.reloadData()
            
        })
        let close = UIAlertAction(title: "閉じる", style: UIAlertAction.Style.destructive, handler: {
            (action: UIAlertAction!) in
            print("閉じる")
        })

        //UIAlertControllerにタイトル1ボタンとタイトル2ボタンと閉じるボタンをActionを追加
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(close)

        if sender.state == UIGestureRecognizer.State.began{
            self.present(actionSheet, animated: true, completion: nil)
        }
        else {
            return
        }
    }

    // セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return mySectionRows.count
    }

    // セクションの中の数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mySectionRows[section].myRow.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mySectionRows[section].mySection
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MainTableViewCell
        cell.task = mySectionRows[indexPath.section].myRow[indexPath.row]
        return cell
    }

}

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var task: TodoneTask? {
        didSet {
            if let task = task {
                titleLable.text = task.name
                detailLabel.text = task.detail
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
