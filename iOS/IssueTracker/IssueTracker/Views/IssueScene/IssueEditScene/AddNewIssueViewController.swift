//
//  AddNewIssueViewController.swift
//  IssueTracker
//
//  Created by sihyung you on 2020/11/03.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import MarkdownView
import UIKit

enum AddType: String {
    case newIssue = "새 이슈"
    case editIssue = "#"
    case newComment = "댓글 추가"
}

struct PreviousData {
    let title: String
    let description: String
    let issueNumber: String
}

class AddNewIssueViewController: UIViewController {
    static let identifier = "AddNewIssueViewController"
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var titleLabel: UILabel!
    private var commentTextView = UITextView()
    private var markdownView = MarkdownView()
    private var previousData: PreviousData?
    var addType: AddType = .newIssue

    private let textViewPlaceholder = "코멘트는 여기에 작성하세요"
    var doneButtonTapped: (([String]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        switch addType {
        case .newIssue, .editIssue:
            titleLabel.isHidden = false
            titleTextField.isHidden = false
        case .newComment:
            titleLabel.isHidden = true
            titleTextField.isHidden = true
        }
        configureKeyboardRelated()
        configureNavigationBar()
        configureCommentTextView()
    }

    private func configureKeyboardRelated() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        subscribe(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
        subscribe(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
    }

    private func subscribe(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    private func configureNavigationBar() {
        let commonAppearance = UINavigationBarAppearance()
        commonAppearance.backgroundColor = .white
        commonAppearance.shadowColor = .gray
        navigationController?.navigationBar.scrollEdgeAppearance = commonAppearance
    }

    private func configureCommentTextView() {
        commentTextView.delegate = self
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(commentTextView)
        commentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        commentTextView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10).isActive = true
        commentTextView.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 1).isActive = true
        commentTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true

        switch addType {
        case .newIssue, .newComment:
            initTextViewPlaceholder()
        case .editIssue:
            initTextViewPreviousData()
        }
    }

    private func configureMarkdownView() {
        // 매번 rendering 하는데 더 효율적인 방법?
        markdownView = MarkdownView()

        if commentTextView.text != textViewPlaceholder {
            markdownView.load(markdown: commentTextView.text)
        } else {
            markdownView.load(markdown: "")
        }

        markdownView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(markdownView)

        markdownView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        markdownView.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 1).isActive = true
        markdownView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10).isActive = true
        markdownView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
    }

    @IBAction func cancelButtonTapped(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonTapped(_: Any) {
        var content = [String]()

        switch addType {
        case .newIssue, .editIssue:
            guard let title = titleTextField.text, !title.isEmpty else {
                showAlert(at: self, title: "제목을 입력해주세요!", prepare: nil, completion: nil)
                return
            }
            content.append(title)
        default:
            break
        }

        content.append(commentTextView.text == textViewPlaceholder ? "" : commentTextView.text)

        doneButtonTapped?(content)
        dismiss(animated: true, completion: nil)
    }

    private func initTextViewPreviousData() {
        titleTextField.text = previousData?.title
        commentTextView.text = previousData?.description
    }

    private func initTextViewPlaceholder() {
        if commentTextView.text.isEmpty {
            commentTextView.text = textViewPlaceholder
            commentTextView.textColor = .lightGray
        }
    }

    private func setTextViewPlaceholder() {
        if commentTextView.text == textViewPlaceholder {
            commentTextView.text = ""
            commentTextView.textColor = .black
        } else if commentTextView.text.isEmpty, addType != .editIssue {
            commentTextView.text = textViewPlaceholder
            commentTextView.textColor = .lightGray
        }
    }

    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        if
            let userInfo = notification.userInfo,
            let keyboardValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        {
            if notification.name == UIResponder.keyboardWillHideNotification {
                commentTextView.contentInset = UIEdgeInsets.zero
            } else {
                commentTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardValue.height, right: 0)
                commentTextView.scrollIndicatorInsets = commentTextView.contentInset
            }

            commentTextView.scrollRangeToVisible(commentTextView.selectedRange)
        }
    }

    @IBAction func segmentDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // 마크다운 작성
            markdownView.removeFromSuperview()
            configureCommentTextView()
        case 1:
            // 미리보기
            commentTextView.removeFromSuperview()
            configureMarkdownView()
        default:
            return
        }
    }
}

extension AddNewIssueViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_: UITextView) {
        setTextViewPlaceholder()
    }

    func textViewDidEndEditing(_: UITextView) {
        if commentTextView.text.isEmpty {
            setTextViewPlaceholder()
        }
    }
}

extension AddNewIssueViewController {
    static let storyboardName = "EditIssue"

    static func present(
        at viewController: UIViewController,
        addType: AddType,
        previousData: PreviousData?,
        onDismiss: (([String]) -> Void)?
    ) {
        let storyBoard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        guard let container = storyBoard.instantiateInitialViewController() as? UINavigationController,
              let vc = container.topViewController as? AddNewIssueViewController
        else { return }

        switch addType {
        case .newIssue, .newComment:
            vc.title = addType.rawValue
        case .editIssue:
            if let previousData = previousData {
                vc.previousData = previousData
                vc.title = addType.rawValue + previousData.issueNumber
            }
        }

        vc.addType = addType
        vc.doneButtonTapped = onDismiss

        viewController.present(container, animated: true, completion: nil)
    }
}
