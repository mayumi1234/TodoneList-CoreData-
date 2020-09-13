//
//  SignUpViewController.swift
//  InstagramCloneApp
//
//  Created by m.yamanishi on 2020/08/08.
//  Copyright © 2020 Mayumi Yamanishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PKHUD

class SignUpViewController: UIViewController, UITextFieldDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyMemberButton: UIButton!
    @IBOutlet weak var usernameStackView: UIStackView!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setUpViews() {
        usernameStackView.isHidden = true
        
        emailTextField.delegate = self
        passwdTextField.delegate = self
        userNameTextField.delegate = self
        
        passwdTextField.isSecureTextEntry = true
        registerButton.isEnabled = false
        registerButton.backgroundColor = UIColor.lightGray
    }
    
    private func checkRegisterButton() {
        if emailTextField.text != "" && passwdTextField.text != "" {
            registerButton.isEnabled = true
            registerButton.backgroundColor = blueColor
        } else {
            registerButton.isEnabled = false
            registerButton.backgroundColor = UIColor.lightGray
        }
    }
    
    //    キーボード以外をタップしてキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        checkRegisterButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkRegisterButton()
        return true
    }
    
    @IBAction func pushOnRegisterButton(_ sender: Any) {
        HUD.show(.progress)
        createUserToFirestore()
    }
    
    private func createUserToFirestore() {
        guard let email = emailTextField.text else { return }
        guard let passwd = passwdTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: passwd) { (res, err) in
            if let err = err {
                print("認証情報の取得に失敗しました。\(err)")
                HUD.hide()
                HUD.flash(.labeledError(title: "会員登録に失敗しました。", subtitle: "\(err)"), delay: HUDTime)
                return
            }
            print("認証情報の保存に成功しました。")
                
                self.dismiss(animated: true, completion: nil)
                
                HUD.hide()
        }
    }
    
    @IBAction func pushOnAlreadyButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
        let signinViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.navigationController?.pushViewController(signinViewController, animated: true)
    }
    
}
