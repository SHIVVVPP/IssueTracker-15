//
//  LabelSubmitFormView.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/10/27.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import UIKit

class LabelSubmitFormView: UIView {
    var submitbuttonTapped: ((String, String, String) -> Void)?
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descField: UITextField!
    @IBOutlet weak var hexCodeField: UITextField!
    @IBOutlet weak var colorView: UIView!
    private let defaultColorCode: String = "#000000"
    private var formViewEndPoint: CGFloat?
    
    func configure(labelViewModel: LabelItemViewModel? = nil) {
        configureTapGesture()
        subscribeNotificationForKeyboardBehaviors()
        
        hexCodeField.delegate = self
        
        if let labelViewModel = labelViewModel {
            titleField.text = labelViewModel.title
            descField.text = labelViewModel.description
            hexCodeField.text = labelViewModel.hexColor
        } else {
            hexCodeField.text = defaultColorCode
        }
        
        colorView.layer.backgroundColor = hexCodeField.text?.color
    }
    
    private func subscribeNotificationForKeyboardBehaviors() {
        // subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
        
        // subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
    }
    
    private func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        if let userInfo = notification.userInfo, let keyboardValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            guard formViewEndPoint == nil else { return }
            
            formViewEndPoint = self.formView.frame.origin.y + self.formView.frame.height
            let moveUpward = formViewEndPoint! - keyboardValue.origin.y
            if formViewEndPoint! > keyboardValue.origin.y {
                self.frame.origin.y -= moveUpward
            }
        }
    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        self.endEditing(true)
        self.frame.origin.y = 0
        self.formViewEndPoint = nil
    }
    
    @IBAction func refreshColorTapped(_ sender: UIButton) {
        let newHexColorCode: String = "#" + getRandomGeneratedString()
        hexCodeField.text = newHexColorCode
        colorView.layer.backgroundColor = hexCodeField.text?.color
    }
    
    private func getRandomGeneratedString() -> String {
        let letters = "ABCDEF0123456789"
        return String((1...6).map { _ in letters.randomElement()! })
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if let titleText = titleField.text, !titleText.isEmpty,
            let descText = descField.text, !descText.isEmpty,
            let hexCodeText = hexCodeField.text, !hexCodeText.isEmpty {
            submitbuttonTapped?(titleText, descText, hexCodeText)
            self.removeFromSuperview()
        } else {
            let alert = UIAlertController(title: "제목, 설명, 색상을\n모두 입력해주세요!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func refreshFormButtonTapped(_ sender: UIButton) {
        titleField.text = ""
        descField.text = ""
        hexCodeField.text = defaultColorCode
        colorView.layer.backgroundColor = defaultColorCode.color
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.removeFromSuperview()
    }
}

extension LabelSubmitFormView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        colorView.layer.backgroundColor = hexCodeField.text?.color
    }
}
