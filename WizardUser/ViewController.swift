//
//  ViewController.swift
//  WizardUser
//
//  Created by McCauley Peeler on 9/5/18.
//  Copyright © 2018 McCauley Peeler. All rights reserved.
//

import UIKit
import Firebase


class ViewController: UIViewController {
    
    @IBOutlet weak var bigButton: UIImageView!
    
    var docRef: DocumentReference!
    var userID: String = ""
    var firestoreUserID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        checkIfUserLoggedIn()
    }

    private func checkIfUserLoggedIn() {
        if Auth.auth().currentUser == nil {
            return
        } else {
            retrieveCurrentUserDocumentID(currentUserObject: Auth.auth().currentUser!)
        }
    }
    
    private func retrieveCurrentUserDocumentID(currentUserObject: User) {
        let collection = Firestore.firestore().collection("Users")

        collection.whereField("email", isEqualTo: Auth.auth().currentUser?.email).addSnapshotListener { querySnapshot, err in
            guard let documents = querySnapshot?.documents else {
                print("Error getting documents: \(err)")
                return
            }
            for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.firestoreUserID = document.documentID
                    self.docRef = Firestore.firestore().collection("Users").document(self.firestoreUserID)
                    self.checkEvent(ref: self.docRef)
            }
        }
    }
    func buttonColor(color: String) {
            if color == "green" {
                bigButton.image = UIImage(named: "greenButton")
            } else {
                bigButton.image = UIImage(named: "redButton")
            }
    }
    private func checkEvent(ref: DocumentReference) {
        ref.getDocument { (docSnapshot, error) in
            var eventData = docSnapshot?.data()
            let eventStatus = eventData!["event"] as? Bool
            if eventStatus == false {
                self.bigButton.image = UIImage(named: "greenButton")
            } else if eventStatus == true {
                self.bigButton.image = UIImage(named: "redButton")
            }
        }
    }
    
    private func toggleEvent(ref: DocumentReference) {
        
        ref.getDocument { (docSnapshot, error) in
            var eventData = docSnapshot?.data()
            let eventStatus = eventData!["event"] as? Bool
            if eventStatus == false {
                ref.updateData([
                    "event": true,
                    "eventTime": FieldValue.serverTimestamp()
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        self.buttonColor(color: "red")
                    }
                }
            } else if eventStatus == true {
                ref.updateData([
                    "event": false
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        self.buttonColor(color: "green")
                    }
                }
            }
        }
    }
    
    @IBAction func test(_ sender: Any) {
        if self.bigButton.image == UIImage(named: "redButton") {
            self.displayAreYouSureAlert()
        } else {
            toggleEvent(ref: docRef)
        }
    }
    
    func displayAreYouSureAlert() {
        let alert = UIAlertController(title: "Hey!", message: "Are you sure you want to cancel?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "End Request", style: .cancel, handler: { action in self.toggleEvent(ref: self.docRef) } ))
        alert.addAction(UIAlertAction(title: "Continue waiting", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
            if self.bigButton.image == UIImage(named: "redButton") {
                return false
            } else {
                return true
            }
    }
}

