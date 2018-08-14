//
//  ViewController.swift
//  TouchIdDemoApp
//
//  Created by Sumit Ghosh on 13/08/18.
//  Copyright © 2018 Sumit Ghosh. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var notesTableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var dataArray:NSMutableArray!
    var noteIndexToEdit:Int? = nil
    
    
    struct StoryboardID {
        static let EDIT_SCREEN = "EditScreen"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set delegate
        self.notesTableView.delegate = self
        self.notesTableView.dataSource = self
        
        //authenticate user using TouchID
        self.authenticateUser()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == StoryboardID.EDIT_SCREEN {
            let editScreen:EditViewController = segue.destination as! EditViewController
            editScreen.delegate = self
            
            if noteIndexToEdit != nil {
                editScreen.indexOfEditedNote = noteIndexToEdit
                noteIndexToEdit = nil
            }
        }
    }
    
    func showPasswordAlert() -> Void {
        let passwordAlert: UIAlertView = UIAlertView.init(title: "TouchID", message: "Please enter your Password", delegate: self, cancelButtonTitle:"Cancel", otherButtonTitles:"Okay")
        passwordAlert.alertViewStyle = UIAlertViewStyle.secureTextInput
        passwordAlert.show()
    }
    
    
    func authenticateUser() -> Void {
        // Get the Local Authentication Context
        let context: LAContext = LAContext()
        
        //Declare a NSError variable
        var error: NSError?
        
        //Set the reason String that will appear on the authentication alert
        var reasonString = "Authentication is needed to access your notes"
        
        //Check if the device can evaluate the policy
        //The DeviceOwnerAuthenticationWithBiometrics is a property of the LAPolicy class.
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            [context .evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                
                if success {
                    OperationQueue.main.addOperation {
                        self.loadData()
                    }
                }else{
                    print(evalPolicyError?.localizedDescription)
                    
                    switch evalPolicyError?.code {
                    case LAError.SystemCancel.rawValue:
                        print("Authentication was canceled by the System")
                        
                    case LAError.UserCancel.rawValue:
                        print("Authentication was canceled by the user")
                        
                    case LAError.UserFallback.rawValue:
                        print("User selected to enter custom password")
                        OperationQueue.main.addOperation({ () -> Void in
                            self.showPasswordAlert()
                        })
                        
                    default:
                        print("Authentication failed")
                        OperationQueue.main.addOperation({ () -> Void in
                            self.showPasswordAlert()
                        })
                    }
                }
                } as! (Bool, Error?) -> Void)]
        } else {
            //If the security policy cannot be evaluated then show a short alert
            switch error?.code {
            case LAError.TouchIDNotAvailable.rawValue:
                print("TouchID in not enrolled")
            case LAError.PasscodeNotSet.rawValue:
                print("A passcode has not been set")
            default:
                //The LAError.TouchIDNotAvailable case
                print("Touch ID not available")
            }
            
            //Optionally the error description can be displayed on the console
            print(error?.localizedDescription as Any)
            //Show the custom alert view to allow users to enter the password
            self.showPasswordAlert()
        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            if alertView.textField(at: 0)?.text?.isEmpty == false {
                if alertView.textField(at: 0)?.text == "Apple" {
                    self.loadData()
                }else{
                    self.showPasswordAlert()
                }
            }else{
                self.showPasswordAlert()
            }
        }
    }
    
    
    func loadData() -> Void {
        if appDelegate.checkIfDataFileExists() {
            self.dataArray = NSMutableArray(contentsOfFile: appDelegate.getPathOfDataFiles())
            self.notesTableView.reloadData()
        }else{
            print("File does not exist")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = self.dataArray {
            return array.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! NotesTableViewCell
        let currentNote = self.dataArray.object(at: indexPath.row) as! Dictionary<String,String>
        cell.textLabel?.text = currentNote["title"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // Delete the respective object from the dataArray array.
            dataArray.remove(indexPath.row)
            
            // Save the array to disk.
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            dataArray.write(toFile: appDelegate.getPathOfDataFiles(), atomically: true)
            
            // Reload the tableview.
            self.notesTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: UITableViewRowAnimation.automatic)
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Selected index
        self.noteIndexToEdit = indexPath.row
        performSegue(withIdentifier: StoryboardID.EDIT_SCREEN, sender: Int?.self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController:EditNoteViewControllerDelegate {
    func noteWasSaved() {
    // Load the data and reload the table view.
     self.loadData()
    }
}

