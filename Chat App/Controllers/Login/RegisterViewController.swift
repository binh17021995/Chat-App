//
//  RegisterViewController.swift
//  Chat App
//
//  Created by Duy Bình on 12/05/2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)

    private let scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let firstNameField :UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let lastNameField :UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let emailField :UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let passWordField :UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true

        
        return field
    }()
    
    private let imageView : UIImageView={
        let  imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor

        return imageView
        
    }()
    
    private let registerButton : UIButton = {
        let button = UIButton()
        button.setTitle("Register", for:.normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = .white
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passWordField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passWordField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didChangeProfilePic))
        
        imageView.addGestureRecognizer(gesture)
        
    }
    @objc private func didChangeProfilePic(){
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width - size)/2,
                                 y: 20,
                                 width: size,
                                 height:size)
        imageView.layer.cornerRadius = imageView.width/2
        
        firstNameField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width:scrollView.width - 60,
                                  height:52)
        lastNameField.frame = CGRect(x: 30,
                                  y: firstNameField.bottom + 10,
                                  width:scrollView.width - 60,
                                  height:52)
        
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom + 10,
                                  width:scrollView.width - 60,
                                  height:52)
        passWordField.frame = CGRect(x: 30,
                                  y: emailField.bottom + 10,
                                  width:scrollView.width - 60,
                                  height:52)
        registerButton.frame = CGRect(x: 30,
                                  y: passWordField.bottom + 10,
                                  width:scrollView.width - 60,
                                  height:52)
        
        
    }
    
     @objc private func registerButtonTapped(){
         emailField.resignFirstResponder()
         passWordField.resignFirstResponder()
         firstNameField.resignFirstResponder()
         lastNameField.resignFirstResponder()
         
         guard let firstName = firstNameField.text,
               let lastName = lastNameField.text,
               let email = emailField.text,
               let password = passWordField.text,
               !email.isEmpty,
               !password.isEmpty,
               password.count>=6,
               !firstName.isEmpty,
               !lastName.isEmpty else {
             alertUserRegisterError()
             return
         }
         spinner.show(in: view)
         
         DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
             guard let strongSelf = self else {
                 return
             }

             DispatchQueue.main.async {
                 strongSelf.spinner.dismiss()
             }

             guard !exists else {
                 // user already exists
                 strongSelf.alertUserRegisterError(message: "Looks like a user account for that email address already exists.")
                 return
             }

             FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                 guard authResult != nil, error == nil else {
                     print("Error cureating user")
                     return
                 }

                 UserDefaults.standard.setValue(email, forKey: "email")
                 UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")


                 let chatUser = ChatAppUser(firstName: firstName,
                                           lastName: lastName,
                                           emailAddress: email)
                 
            
                 DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                     if success {
                         // upload image
                         guard let image = strongSelf.imageView.image,
                             let data = image.pngData() else {
                                 return
                         }
                         
                         let filename = chatUser.profilePictureFileName
                         StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                             switch result {
                             case .success(let downloadUrl):
                                 UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                 print(downloadUrl)
                             case .failure(let error):
                                 print("Storage maanger error: \(error)")
                             }
                         })
                     }
                 })

                 strongSelf.navigationController?.dismiss(animated: true, completion: nil)
             })
         })
     }

    func alertUserRegisterError(message : String = "Please enter all information to new account"){
        let alert = UIAlertController(title: "Woops", message: message , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dissmis", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension RegisterViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField : UITextField) -> Bool {
        
        if textField == emailField {
            passWordField.becomeFirstResponder()
        }
        else if textField == passWordField {
            registerButtonTapped()
        }
        
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in

                                                self?.presentCamera()

        }))
        actionSheet.addAction(UIAlertAction(title: "Chose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in

                                                self?.presentPhotoPicker()

        }))

        present(actionSheet, animated: true)
    }

    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }

        self.imageView.image = selectedImage
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
