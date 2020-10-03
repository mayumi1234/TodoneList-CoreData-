//
//  AddToDoneViewController.swift
//  ToDoneList
//
//  Created by m.yamanishi on 2020/09/06.
//  Copyright © 2020 Mayumi Yamanishi. All rights reserved.
//

import UIKit
import GoogleMobileAds
import PKHUD
import CoreData

class CoreDataModel {
    
    private static var persistentContainer: NSPersistentCloudKitContainer = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer as! NSPersistentCloudKitContainer
    
    static func newTask() -> TodoneTask {
        let context = persistentContainer.viewContext
        let todoneTask = NSEntityDescription.insertNewObject(forEntityName: "TodoneTask", into: context) as! TodoneTask
        return todoneTask
    }
    
    static func save() {
        persistentContainer.saveContext()
    }
    
    static func delete(person: TodoneTask) {
        let context = persistentContainer.viewContext
        context.delete(person)
    }
    
    static func getTask() -> [TodoneTask] {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoneTask")
        
        do {
            let todoneTask = try context.fetch(request) as! [TodoneTask]
            return todoneTask
        }
        catch {
            fatalError()
        }
    }
    
}

class AddToDoneViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var continuedRecordButton: UIButton!
    
    var datePicker: UIDatePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDatePicker()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        AdsSetup()
        setupLayout()
    }
    
    private func setupDatePicker() {
        // ピッカー設定
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        dateTextField.inputView = datePicker
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // インプットビュー設定
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = toolbar
    }
    
    // 決定ボタン押下
    @objc func done() {
        dateTextField.endEditing(true)
        
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = "\(formatter.string(from: datePicker.date))"
    }
    
    @IBAction func pushOnContinuedRecordButton(_ sender: Any) {
        if nameTextField.text!.isEmpty || detailTextView.text.isEmpty || dateTextField.text!.isEmpty {
            HUD.flash(.labeledError(title: "項目を入力してください。", subtitle: ""), delay: HUDTime)
            return
        } else {
            HUD.show(.progress)
            createToCoreData()
            let test = CoreDataModel.getTask()
            print(test)
        }
    }
    
    @IBAction func pushOnRecordButton(_ sender: Any) {
        if nameTextField.text!.isEmpty || detailTextView.text.isEmpty || dateTextField.text!.isEmpty  {
            HUD.flash(.labeledError(title: "項目を入力してください。", subtitle: ""), delay: HUDTime)
            return
        } else {
            HUD.show(.progress)
            createToCoreData()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func pushOnCanceledButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func createToCoreData() {
        guard let name = nameTextField.text else {
            return
        }
        guard let detail = detailTextView.text else {
            return
        }
        guard let dateString = dateTextField.text else {
            return
        }
        
        let date = datePicker.date
        
        // task作成
        let task = CoreDataModel.newTask()
        task.name = name
        task.date = date
        task.dateString = dateString
        task.detail = detail

        // 保存
        CoreDataModel.save()
        HUD.hide()
        HUD.flash(.labeledSuccess(title: "完了しました。", subtitle: ""), delay: HUDTime)
    }
    
//
//    private func createToFirestore() {
//        guard let name = nameTextField.text else {
//            return
//        }
//        guard let detail = detailTextView.text else {
//            return
//        }
//        guard let dateString = dateTextField.text else {
//            return
//        }
//        guard let uid = Auth.auth().currentUser?.uid else {
//            return
//        }
//
//        let date = datePicker.date
//        let documentID = UIViewController.randomString(length: 20)
//
//        let docData = [
//            "name": name,
//            "detail": detail,
//            "dateString": dateString,
//            "date": date,
//            "documentId": documentID
//            ] as [String : Any]
//
//        // タスクを記録
//        db.collection("users").document(uid).collection("tasks").document(documentID).setData(docData) { (err) in
//            if let err = err {
//                print("Firestoreへの保存に失敗しました。\(err)")
//                HUD.hide()
//                HUD.flash(.labeledError(title: "失敗しました。", subtitle: "\(err)"), delay: HUDTime)
//                return
//            }
//            print("Firestoreへの保存が成功しました。")
//            HUD.hide()
//            HUD.flash(.labeledSuccess(title: "完了しました。", subtitle: ""), delay: HUDTime)
//        }
//    }
    
    private func setupLayout() {
        continuedRecordButton.layer.cornerRadius = 5
        
        detailTextView.layer.borderWidth = 1
        detailTextView.layer.borderColor = borderColor.cgColor
        detailTextView.layer.cornerRadius = 5
        detailTextView.layer.masksToBounds = true
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
            admobView.frame.origin = CGPoint(x:0, y: self.view.frame.size.height - admobView.frame.height - self.view.safeAreaInsets.bottom)
        } else {
            admobView.frame.origin = CGPoint(x:0, y: self.view.frame.size.height - admobView.frame.height)
        }
        admobView.frame.size = CGSize(width: self.view.frame.width, height:admobView.frame.height)
        
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
