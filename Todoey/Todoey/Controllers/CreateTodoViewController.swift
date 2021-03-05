//
//  CreateTODOViewController.swift
//  Todoey
//
//  Created by Никита Игумнов on 05.03.2021.
//

import UIKit
import CoreData

class CreateTodoViewController: UIViewController {
    
    public var item: Item?
    public var context: NSManagedObjectContext!
    
    private var willEdit: Bool = false
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var inProgressControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        
        let borderColor: UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = borderColor.cgColor
        textView.layer.cornerRadius = 5.0
        
        if let itemUnwrapped = item { // кейс когда мы открыли по клику на ячейку
            willEdit = true
            self.titleTextField.text = itemUnwrapped.title
            self.datePicker.date = itemUnwrapped.date!
            self.inProgressControl.selectedSegmentIndex = itemUnwrapped.inProgress ? 0 : 1
            self.textView.text = itemUnwrapped.descriptionText
        }
    }
    
    @IBAction func saveBarButtonPressed(_ sender: UIBarButtonItem) {
        
        // заполнили элемент, который нужно сохранить
        let itemToSave = willEdit ? item! : Item(context: context)
        
        itemToSave.title = titleTextField.text
        itemToSave.date = datePicker.date
        itemToSave.inProgress = inProgressControl.selectedSegmentIndex == 0
        itemToSave.descriptionText = textView.text
        
        // сохраняем
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Text field Methods

extension CreateTodoViewController: UITextFieldDelegate {
    
    // чтобы после нажатия на кнопку return закрывалась клавиатура
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
