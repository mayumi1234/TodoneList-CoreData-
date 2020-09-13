//
//  ViewController.swift
//  ToDoneList
//
//  Created by m.yamanishi on 2020/09/06.
//  Copyright © 2020 Mayumi Yamanishi. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FirebaseAuth
import FirebaseStorage
import Firebase
import FirebaseFirestore

class ViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var bottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIStackView!
    
    var tasks = [Task]()
    var dates = [DateModel]()
    
    typealias MySectionRow = (mySection: String, myRow: Array<Task>)
    var mySectionRows = [MySectionRow]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLogin()
        fetchForFirestore()
        
        // ボトムは申請審査の時に、いるかいらないか判断
        bottomView.isHidden = true
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        AdsSetup()
    }
    
    private func fetchForFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).collection("date").getDocuments { (snaps, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snaps!.documents {
                    let dic = document.data()
                    let date = DateModel(dic: dic)
                    // セクションのための配列を代入
                    self.dates.insert(date, at: 0)
                    let dateId = document.documentID
                    self.firestoreToTasks(uid: uid, dateId: dateId)
                }
            }
        }
    }
    
    private func firestoreToTasks(uid: String, dateId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("date").document(dateId).collection("tasks")
            .addSnapshotListener { (snapshots, err) in
                if let err = err {
                    print("date情報の取得に失敗しました。\(err)")
                    return
                }
                
                snapshots?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type {
                    case .added:
                        let dic = documentChange.document.data()
                        let task = Task(dic: dic)
                        self.tasks.append(task)
                        
                        self.mySectionRows.insert((dateId, [task]), at: 0)
//                        print("self.mySectionRows: ", self.mySectionRows)
//                        print("self.tasks: ", self.tasks)
//                        print("self.dates: ", self.dates)
                        
                    case .modified, .removed:
                        print("nothing to do")
                    }
                })
        }
        
        
    }
    
    @IBAction func addToDoneButton(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "AddToDone", bundle: nil)//遷移先のStoryboardを設定
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddToDoneViewController") as! AddToDoneViewController//遷移先のViewControllerを設定
        self.navigationController?.pushViewController(nextView, animated: true)//遷移する
    }
    
    @IBAction func graphButton(_ sender: Any) {
    }
    
    private func setupLogin() {
        if Auth.auth().currentUser == nil { // ログインしてない時
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            let nav = UINavigationController(rootViewController: signUpViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
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
            admobView.frame.origin = CGPoint(x:0, y: self.view.frame.size.height - admobView.frame.height - self.bottomBarHeight.constant - self.view.safeAreaInsets.bottom)
        } else {
            admobView.frame.origin = CGPoint(x:0, y: self.view.frame.size.height - admobView.frame.height - self.bottomBarHeight.constant)
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
    
    // セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return dates.count
    }
    
    // セクションの中の数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dates[section].date
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MainTableViewCell
//        cell.task = tasks[indexPath.section][indexPath.row]
        return cell
    }
    
//    選択する時
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedClass = mySections[indexPath.section]
//        selectedPerson = twoDimArray[indexPath.section][indexPath.row]
//    }

//    // sectionの中の数
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
//    }
//
//    // Section数
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return uniqDate.count
//    }
//
//    // Sectioのタイトル
//    func tableView(_ tableView: UITableView,
//                       titleForHeaderInSection section: Int) -> String? {
//        for i in 0..<uniqDate.count {
//            if section == i {
//                titleString = uniqDate[i]
//            }
//        }
//        return titleString
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = mainTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MainTableViewCell
//        cell.task = tasks[indexPath.row]
//        return cell
//    }
}

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var task: Task? {
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
