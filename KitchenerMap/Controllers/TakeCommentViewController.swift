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

class TakeCommentViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    var location: CLLocationCoordinate2D!
    private var imagePicker: UIImagePickerController?

    override func viewDidLoad() {
        super.viewDidLoad()
        let ui = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(ui)
    }
    
    @objc private func closeKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func onPhotoAdditionTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
            self.openCameraPicker()
        }))
        alert.addAction(UIAlertAction(title: "Library", style: .default, handler: { (_) in
            self.openLibraryPicker()
        }))
        if imageView.image != nil {
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                self.imageView.image = nil
                self.button.setTitleForAllStates("Προσθήκη Φωτογραφίας")
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
        guard textView.text.count > 0 else {
            return
        }
        //TODO: send comment, image and location
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
        button.setTitleForAllStates("Αλλαγή Φωτογραφίας")
        picker.dismiss(animated: true)
    }
}


