//
//  SubmitForm.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/10/31.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import UIKit

class SubmitFormViewController: UIViewController {
    enum SaveResult {
        case success
        case failure(String)
    }

    var formViewEndPoint: CGFloat?
    var moveUpward: CGFloat = 0

    @IBOutlet var backgroundView: UIView!
    @IBOutlet var formView: UIView!
    @IBOutlet var submitFieldGuideView: UIView!

    private var submitField: SubmitFieldProtocol?

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, submitField: SubmitFieldProtocol) {
        self.submitField = submitField
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubmitField()
        subscribeNotifications()
        configureTapGesture()
    }

    private func configureSubmitField() {
        guard let submitField = submitField else { return }
        submitFieldGuideView.addSubview(submitField.contentView)
        NSLayoutConstraint.activate([
            submitField.contentView.topAnchor.constraint(equalTo: submitFieldGuideView.topAnchor),
            submitField.contentView.bottomAnchor.constraint(equalTo: submitFieldGuideView.bottomAnchor),
            submitField.contentView.leadingAnchor.constraint(equalTo: submitFieldGuideView.leadingAnchor),
            submitField.contentView.trailingAnchor.constraint(equalTo: submitFieldGuideView.trailingAnchor),
        ])
    }
}

// MARK: - Action

extension SubmitFormViewController {
    @IBAction func closeButtonTapped(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func resetButtonTapped(_: Any) {
        submitField?.resetButtonTapped()
    }

    @IBAction func saveButtonTapped(_: Any) {
        guard let submitField = self.submitField else {
            dismiss(animated: true, completion: nil)
            return
        }

        switch submitField.saveButtonTapped() {
        case .success:
            dismiss(animated: true, completion: nil)
        case let .failure(message):
            showAlert(at: self, title: message, prepare: moveFormViewDownward, completion: moveFormViewUpward)
        }
    }

    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        if
            let userInfo = notification.userInfo,
            let keyboardValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        {
            guard formViewEndPoint == nil else { return }

            let newEndPoint = formView.frame.origin.y + formView.frame.height
            formViewEndPoint = newEndPoint

            moveUpward = newEndPoint - keyboardValue.origin.y
            if newEndPoint > keyboardValue.origin.y {
                formView.frame.origin.y -= moveUpward
            }
        }
    }

    @objc func formViewTapped() {
        view.endEditing(true)
        formViewEndPoint = nil
        let finalPos = formView.frame.origin.y + moveUpward

        UIView.animate(withDuration: 0.3, animations: {
            self.formView.frame.origin.y = finalPos
        }, completion: { _ in
            self.formView.frame.origin.y = finalPos
        })

        moveUpward = 0
    }

    @objc func backgroundTapped() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Private Function

extension SubmitFormViewController {
    private func configureTapGesture() {
        formView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(formViewTapped)))
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))
    }

    private func subscribeNotifications() {
        subscribe(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
        subscribe(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
    }

    private func subscribe(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }

    private func moveFormViewUpward() {
        formView.frame.origin.y -= moveUpward
    }

    private func moveFormViewDownward() {
        formView.frame.origin.y += moveUpward
    }
}

extension SubmitFormViewController {
    static let nibName = "SubmitFormViewController"

    static func createViewController(with submitField: SubmitFieldProtocol) -> SubmitFormViewController? {
        let vc = SubmitFormViewController(nibName: nibName, bundle: Bundle.main, submitField: submitField)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        return vc
    }
}
