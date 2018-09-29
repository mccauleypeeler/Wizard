//
//  SignInViewController.swift
//  WizardUser
//
//  Created by McCauley Peeler on 9/12/18.
//  Copyright © 2018 McCauley Peeler. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseUI

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    var numberToSend: String = ""
    var firestoreUserID: String = ""
    var currentUser: User? = nil
    var collection = Firestore.firestore().collection("Users")
    
    
    
    @IBOutlet weak var numberInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.currentUser = Auth.auth().currentUser!
//        loadData(currentUserObject: currentUser!)
        numberInput.delegate = self
        
    }
    
    private func loadData(currentUserObject: User) {

            self.collection.whereField("email", isEqualTo: currentUser?.email).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.firestoreUserID = document.documentID
                    self.numberToSend = document.data()["number"] as! String
                    
                    self.numberInput.text = self.numberToSend
                }
            }   
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "proceed" {
            let viewController = segue.destination as? ViewController
            viewController?.userID = firestoreUserID
        }
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
        
    @IBAction func enterNumber(_ sender: Any) {
        numberToSend = numberInput.text!
        
        PhoneAuthProvider.provider().verifyPhoneNumber(numberToSend, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print(error)
                return
            }
            // Sign in using the verificationID and the code sent to the user
            // ...
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        }
        
//        self.collection.document(self.firestoreUserID).updateData([
//            "number": self.numberToSend
//            ])
    }
    
    @IBAction func signOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        numberInput.resignFirstResponder()
    }
}
