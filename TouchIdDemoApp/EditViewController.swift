//
//  EditViewController.swift
//  TouchIdDemoApp
//
//  Created by Sumit Ghosh on 13/08/18.
//  Copyright © 2018 Sumit Ghosh. All rights reserved.
//

import UIKit
import LocalAuthentication

protocol EditNoteViewControllerDelegate{
    func noteWasSaved()
}

class EditViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var NoteTextField: UITextField!
    @IBOutlet weak var bodtTextView: UITextView!
    var delegate:EditNoteViewControllerDelegate?
    var indexOfEditedNote:Int?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.NoteTextField.becomeFirstResponder()
        NoteTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if indexOfEditedNote != nil {
            self.editNote()
        }
    }

    @IBAction func SaveButtonAction(_ sender: Any) {
        if (self.NoteTextField.text?.isEmpty)! {
            print("No title for the notes was typed")
            return
        }
        //Create a dictionary with the note data.
        var noteDict = ["title":self.NoteTextField.text, "body": self.bodtTextView.text]
        
        //Declare a NSMutableArray object
        var dataArray: NSMutableArray
        
        if appDelegate.checkIfDataFileExists() {
            //Load any existing notes
            dataArray = NSMutableArray(contentsOfFile: appDelegate.getPathOfDataFiles())!
            
            // Check if is editing a note or not.
            if indexOfEditedNote == nil {
                //Add the dictionary to the array
                dataArray.add(noteDict)
            } else {
                // Replace the existing dictionary to the array.
                dataArray.replaceObject(at: indexOfEditedNote!, with: noteDict)
            }
        }else{
            //Create a new muttable array and add the note dict object to it
            dataArray = NSMutableArray(object: noteDict)
        }
        
        //Save the array contents to file
        dataArray.write(toFile: appDelegate.getPathOfDataFiles(), atomically:true)
        
        //Notify the delegate class that the note has been saved
        self.delegate?.noteWasSaved()
        
        //pop the view controller
        self.navigationController?.popViewController(animated: true)
    }
    
    func editNote() -> Void {
        //Load all notes
        var notesArray: NSArray = NSArray(contentsOfFile: appDelegate.getPathOfDataFiles())!
        
        //Get the dictionary at the specified index
        let noteDict: Dictionary = notesArray.object(at: indexOfEditedNote!) as! Dictionary<String, String>
        
        //Set the textfield text
        self.NoteTextField.text = noteDict["title"]
        
        //Set the textview text
        self.bodtTextView.text = noteDict["body"]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        bodtTextView.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
