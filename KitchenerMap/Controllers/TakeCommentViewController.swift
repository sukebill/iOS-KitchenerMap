//
//  TakeCommentViewController.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 25/05/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import UIKit
import CoreLocation
import SwifterSwift
import MessageUI

class TakeCommentViewController: UIViewController {
    
    @IBOutlet weak var commentTitle: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    
    var location: CLLocationCoordinate2D!
    private var imagePicker: UIImagePickerController?
    private let isGreek: Bool = LocaleHelper.shared.language == .greek

    override func viewDidLoad() {
        super.viewDidLoad()
        let ui = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(ui)
        commentTitle.text = isGreek ? "Γράψτε το σχόλιο σας" : "Type your feedback"
        button.setTitleForAllStates(isGreek ? "Προσθήκη Φωτογραφίας" : "Add Photo")
        sendButton.setTitleForAllStates(isGreek ? "Αποστολή" : "Send")
    }
    
    @objc private func closeKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func onPhotoAdditionTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: isGreek ? "Κάμερα" : "Camera", style: .default, handler: { (_) in
            self.openCameraPicker()
        }))
        alert.addAction(UIAlertAction(title: isGreek ? "Φωτογραφίες" : "Library", style: .default, handler: { (_) in
            self.openLibraryPicker()
        }))
        if imageView.image != nil {
            alert.addAction(UIAlertAction(title: isGreek ? "Διαγραφή" : "Delete", style: .destructive, handler: { (_) in
                self.imageView.image = nil
                self.button.setTitleForAllStates(self.isGreek ? "Προσθήκη Φωτογραφίας" : "Add Photo")
            }))
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.sourceView = imageView
            alert.popoverPresentationController?.sourceRect = imageView.bounds
            alert.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        present(alert, animated: true)
    }
    
    private func openCameraPicker() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraCaptureMode = .photo
        imagePicker?.cameraDevice = .rear
        imagePicker?.mediaTypes = ["public.image"]
        imagePicker?.delegate = self
        present(imagePicker!, animated: true)
    }
    
    private func openLibraryPicker() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .photoLibrary
        imagePicker?.mediaTypes = ["public.image"]
        imagePicker?.delegate = self
        present(imagePicker!, animated: true)
    }
    
    @IBAction func onSendTapped(_ sender: Any) {
        guard textView.text.count > 0 else { return }
        openMailApp()
    }
    
    private func openMailApp() {
        guard MFMailComposeViewController.canSendMail() else {
            sendButton.setTitleForAllStates(isGreek ? "Δεν υπάρχει συνδεδεμένος λογαριασμός" :"No Account in Mail")
            return
        }
        let emailTitle = isGreek ? "Ανατροφοδότηση" : "Feedback"
        let messageBody = "Coordinates \(location.latitude), \(location.longitude)\n\n\(textView.text ?? "")"
        let toRecipents = ["gaia_webmaster@hua.gr"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        if let image = imageView.image?.compressedData() {
            mc.addAttachmentData(image, mimeType: "image/jpeg", fileName: "feedback_\(location.latitude)_\(location.longitude)_\(Date().string()).jpg")
        }
        present(mc, animated: true)
    }
}

extension TakeCommentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return picker.dismiss(animated: true)
        }
        imageView.image = image
        button.setTitleForAllStates(isGreek ? "Αλλαγή Φωτογραφίας" : "Change Photo")
        picker.dismiss(animated: true)
    }
}

extension TakeCommentViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

