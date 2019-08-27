//
//  CaptchaAlertView.swift
//  UNCmorfi
//
//  Created by Joaquin Barcena on 8/23/19.
//  Copyright © 2019 George Alegre. All rights reserved.
//

import Foundation
import UIKit

//MARK: View class
class CaptchaAlertView : UIView {
    
    let title:UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "balance.reservation.title".localized()
        return titleLabel
    }()
    
    let message:UILabel = {
        let messageLabel = UILabel()
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = "balance.reservation.description".localized()
        return messageLabel
    }()
    
    let captchaImage:UIImageView = {
        let captchaImage = UIImageView()
        captchaImage.clipsToBounds = true
        captchaImage.layer.cornerRadius = 5
        captchaImage.translatesAutoresizingMaskIntoConstraints = false
        return captchaImage
    }()
    
    let captchaTextField:UITextField = {
        let captchaFieldText = UITextField()
        captchaFieldText.enablesReturnKeyAutomatically = true
        captchaFieldText.placeholder = "Captcha ..."
        captchaFieldText.clearButtonMode = .whileEditing
        captchaFieldText.autocorrectionType = .no
        captchaFieldText.translatesAutoresizingMaskIntoConstraints = false
        captchaFieldText.layer.borderColor = UIColor.lightGray.cgColor
        captchaFieldText.layer.borderWidth = 0.7
        return captchaFieldText
    }()
    
    let okButton:UIButton = {
        let okButton = UIButton(type: UIButtonType.system)
        //okButton.titleLabel?.font = UIFont.buttonFontSize
        okButton.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        okButton.titleLabel?.textAlignment = .center
        okButton.setTitle("balance.add.user.text.confirm".localized(), for: .normal)
        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return okButton
    }()
    
    let cancelButton:UIButton = {
        let okButton = UIButton(type: UIButtonType.system)
        okButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
        okButton.titleLabel?.textAlignment = .center
        okButton.setTitle("cancel".localized(), for: .normal)
        okButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        okButton.translatesAutoresizingMaskIntoConstraints = false
        return okButton
    }()
    
    let verticalSeparator:UIView = {
        let buttonSeparator = UIView()
        buttonSeparator.backgroundColor = .lightGray
        buttonSeparator.alpha = 0.5
        buttonSeparator.translatesAutoresizingMaskIntoConstraints = false
        return buttonSeparator
    }()
    
    let horizontalSeparator:UIView = {
        let buttonSeparator = UIView()
        buttonSeparator.backgroundColor = .lightGray
        buttonSeparator.alpha = 0.5
        buttonSeparator.translatesAutoresizingMaskIntoConstraints = false
        return buttonSeparator
    }()
    
    let loadingIndicator:UIActivityIndicatorView = {
        let loading = UIActivityIndicatorView()
        loading.hidesWhenStopped = true
        loading.layer.cornerRadius = 5
        loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        loading.color = .white
        return loading
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(){
        super.init(frame:.zero)
        backgroundColor = .white
        alpha = 0.99
//        let blurEffect = UIBlurEffect(style: .light)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = self.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
//        loadingIndicator.startAnimating();
//        addSubview(blurEffectView)
        addSubview(title)
        addSubview(message)
        addSubview(captchaImage)
        addSubview(loadingIndicator)
        addSubview(captchaTextField)
        addSubview(okButton)
        addSubview(cancelButton)
        addSubview(verticalSeparator)
        addSubview(horizontalSeparator)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            title.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            
            message.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5),
            message.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            message.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -20),
            
            loadingIndicator.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 10),
            loadingIndicator.leadingAnchor.constraint(equalTo: message.leadingAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: message.trailingAnchor),
            //Hacky
            loadingIndicator.heightAnchor.constraint(equalToConstant: 90),//UIScreen.main.scale),
            
            captchaImage.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 10),
            captchaImage.leadingAnchor.constraint(equalTo: message.leadingAnchor),
            captchaImage.trailingAnchor.constraint(equalTo: message.trailingAnchor),
            
            
            captchaTextField.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 10),
            captchaTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            captchaTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -20),
            
            horizontalSeparator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            horizontalSeparator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            horizontalSeparator.topAnchor.constraint(equalTo: captchaTextField.bottomAnchor, constant: 10),
            horizontalSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            
            okButton.topAnchor.constraint(equalTo: horizontalSeparator.bottomAnchor),
            okButton.leadingAnchor.constraint(equalTo: self.centerXAnchor),
            okButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            okButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: okButton.topAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: self.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            verticalSeparator.topAnchor.constraint(equalTo: okButton.topAnchor),
            verticalSeparator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            verticalSeparator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            verticalSeparator.widthAnchor.constraint(equalToConstant: 0.5)
            
            
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented")
    }
    
    
}

//MARK: Controller class
class CaptchaViewController: UIViewController {
    
    private let alertView: CaptchaAlertView = {
        let captchaAlertView = CaptchaAlertView()
        captchaAlertView.layer.cornerRadius = 12
        captchaAlertView.layer.masksToBounds = true
        captchaAlertView.translatesAutoresizingMaskIntoConstraints = false
        
        return captchaAlertView
    }()
    
    private var confirmAlertHandler:((String)->Void)?
    
    init(){
        super.init(nibName: nil, bundle: nil)
        alertView.captchaImage.isHidden = true
        alertView.loadingIndicator.isHidden = false
        setupButtons(doneButtonEnabled: false)
    }
    
    init(withCaptcha:UIImage){
        super.init(nibName: nil, bundle: nil)
        alertView.loadingIndicator.isHidden = true
        alertView.captchaImage.image = withCaptcha
        setupButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButtons(doneButtonEnabled:Bool = true){
        alertView.okButton.isEnabled = doneButtonEnabled
        //Cancel button
        alertView.cancelButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        //Done button
        alertView.okButton.addTarget(self, action: #selector(confirmAlert), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        alertView.captchaTextField.becomeFirstResponder()
        if !alertView.loadingIndicator.isHidden {
            alertView.loadingIndicator.startAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        view.addSubview(alertView)
        alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        alertView.widthAnchor.constraint(equalToConstant: view.bounds.width*0.8).isActive = true
        
    }
    
    // MARK: Animations
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.view.alpha = 0;
        self.view.isHidden = false;
        self.view.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        UIView.animate(withDuration: 0.1, delay:0, options: .curveEaseIn, animations:{ [unowned self] in
            self.view.transform = CGAffineTransform.identity
        }, completion:nil)
        UIView.animate(withDuration: 0.4){ [unowned self] in
            self.view.alpha = 1.0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(white: 0, alpha: 0)
    }
    
    // MARK: Keyboard calculation
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                //Antes era un offset arriba del teclado cuando se pasaba
                //Ahora es centrado al espacio remanente
                let viewHeight = self.alertView.frame.size.height
                let remainingView = (UIScreen.main.bounds.height - keyboardSize.height)/2 - (viewHeight/2)
                self.view.frame.origin.y -= alertView.frame.origin.y - remainingView
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    //MARK: Controller methods
    func onConfirmAlert(handler: @escaping (String)->Void){
        DispatchQueue.main.async {
            self.alertView.okButton.isEnabled = true
        }
        confirmAlertHandler = handler
    }
    
    @objc func close() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func confirmAlert() {
        guard let confirmAlertHandler = confirmAlertHandler else {
            return
        }
        //Check for emptyness maybe
        self.alertView.loadingIndicator.isHidden = false
        self.alertView.loadingIndicator.startAnimating()
        confirmAlertHandler(alertView.captchaTextField.text ?? "")
    }
    
    func thenPresent(over controller:UIViewController) -> CaptchaViewController {
        present(over: controller)
        return self
    }
    
    func present(over controller:UIViewController){
        self.modalPresentationStyle = .overFullScreen
        controller.present(self, animated: false, completion: nil)
    }
    
    func setCaptchaImage(_ captchaImage:UIImage){
        DispatchQueue.main.async {
            if self.alertView.loadingIndicator.isAnimating {
                self.alertView.loadingIndicator.stopAnimating()
            }
            self.alertView.captchaImage.isHidden = false
            self.alertView.captchaImage.image = captchaImage
        }
    }
    
    func setResultMessage(_ result:String){
        DispatchQueue.main.async {
            self.alertView.message.text = result
            self.alertView.captchaTextField.isHidden = true
            self.alertView.captchaImage.isHidden = true
            if self.alertView.loadingIndicator.isAnimating {
                self.alertView.loadingIndicator.stopAnimating()
            }
            self.alertView.loadingIndicator.isHidden = true
            self.alertView.okButton.isEnabled = false
            UIView.animate(withDuration: 0.3, animations: {
                NSLayoutConstraint.deactivate(self.alertView.captchaImage.constraints)
                NSLayoutConstraint.deactivate(self.alertView.captchaTextField.constraints)
                NSLayoutConstraint.deactivate(self.alertView.loadingIndicator.constraints)
                self.alertView.layoutIfNeeded()
            })
        }
    }
    
}
