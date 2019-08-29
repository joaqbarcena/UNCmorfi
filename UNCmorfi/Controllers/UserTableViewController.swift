//
//  UserTableViewController.swift
//  UNCmorfi
//
//  Created by George Alegre on 4/25/17.
//
//  LICENSE is at the root of this project's repository.
//

import UIKit
import os.log

class UserTableViewController: UITableViewController {
    // MARK: Properties
    private var users: [User] = []
    private var timer:Timer?

    // MARK: Setup.
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "balance.nav.label".localized()
        if #available(iOS 11.0, *) {
            navigationController!.navigationBar.prefersLargeTitles = true
        }
        
        setupNavigationBarButtons()
    
        // Load saved users.
        if let savedUsers = savedUsers() {
            users = savedUsers
        }
        
        // Update all data.
        refreshData()
        
        // Allow updating data.
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        // Cell setup.
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
    }
    
    private func setupNavigationBarButtons() {
        self.navigationItem.leftBarButtonItem = editButtonItem
        
        let addViaCameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addViaCameraButtonTapped(_:)))
        let addViaTextButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addViaTextButtonTapped(_:)))
        let devOptions = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(openOptions(_:)))
        self.navigationItem.rightBarButtonItems = [addViaTextButton, addViaCameraButton, devOptions]
    }

    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.5 // 8 for margin, 50 for image, 8 for margin and 0.5 for table separator
    }

    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier, for: indexPath) as? UserCell else {
            fatalError("The dequeued cell is not an instance of UserCell.")
        }

        let user = users[indexPath.row]
        
        cell.configureFor(user: user)
        
        return cell
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let beastMode = UIContextualAction(style: .normal, title: "Beast Mode") { (action, view, completion) in
            let user = self.users[indexPath.row]
//
//            if self.timer != nil {
//                self.timer?.invalidate()
//                self.timer = nil
//            } else {
                let alert = UIAlertController(title: "balance.reservation.resession".localized(),
                                              message: "loading".localized(), preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel){
                    action in
                    if self.timer != nil {
                        self.timer?.invalidate()
                        self.timer = nil
                    }
                })
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
                self.timer = Timer.scheduledTimer(withTimeInterval: UNCComedor.remote ? 2 : 0.7 , repeats: true, block: { timer in
                    if let reservationLogin = ReservationLogin.load(code: user.code) {
                        UNCComedor.api.getReservation(with: reservationLogin){
                            result in
                            let (resultText, redoLogin) = UNCComedor.reservationResult(result)
                            if resultText == "balance.reservation.reserved.label".localized() ||
                               resultText == "balance.reservation.soldout.label".localized() || redoLogin {
                                timer.invalidate()
                                self.timer = nil
                                if redoLogin {
                                    reservationLogin.deleteFromStorage()
                                    self.showReservationLogin(to: user)
                                }
                            }
                            if !redoLogin, case let .success(status) = result,
                                let path = status.path {
                                reservationLogin.copy(withPath: path, withCaptchaImage: nil)
                                    .save()
                            }
                            NSLog(resultText)
                            DispatchQueue.main.async {
                                alert.message = resultText
                            }
                        }
                    } else {
                        timer.invalidate()
                        self.timer = nil
                        DispatchQueue.main.async {
                            alert.dismiss(animated: false, completion: nil)
                        }
                        self.showReservationLogin(to: user)
                    }
                })
            //}
            completion(true)
        }
        beastMode.backgroundColor = UIColor.lightGray
        return UISwipeActionsConfiguration(actions:[beastMode])
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //Reservation swipe action
        let reservationAction = UITableViewRowAction(style: .normal, title: "balance.reservation.title".localized()){
            [unowned self] action, indexPath in
            //Check for valid session stored
            //i.e. it exist and < 1 hour
            let user = self.users[indexPath.row]
            if let reservationLogin = ReservationLogin.load(code: user.code) {
                UNCComedor.api.getReservation(with: reservationLogin){
                    result in
                    let (resultText, redoLogin) = UNCComedor.reservationResult(result)
                    if redoLogin {
                        reservationLogin.deleteFromStorage()
                    } else {
                        if case let .success(status) = result,
                            let path = status.path {
                         reservationLogin.copy(withPath: path, withCaptchaImage: nil).save()
                        }
                    }
                    let alert = UIAlertController(title: "balance.reservation.resession".localized(), message: resultText, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                }
            } else { //if isn't valid
                self.showReservationLogin(to: user)
            }
            
        }
        
        //Delete swipe action
        let deleteAction = UITableViewRowAction(style: .destructive, title: "delete".localized()){
            [unowned self] action, indexPath in
            self.users.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.saveUsers()
        }
        reservationAction.backgroundColor = UIColor.orange
        
        return [deleteAction, reservationAction]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let user = users[fromIndexPath.row]
        users.remove(at: fromIndexPath.row)
        users.insert(user, at: to.row)
    }
    
    // MARK: Actions
    @objc private func openOptions(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "options".localized(),
                                   message: nil,
                                   preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel))
        ac.addAction(UIAlertAction(title: "Clean reservation sessions", style: .default){
            action in
            self.users.forEach({ ReservationLogin.load(code: $0.code)?.deleteFromStorage() })
        })
        ac.addAction(UIAlertAction(title: "\(UNCComedor.remote ? "Local" : "Remote") reservations mode", style: .default){
            action in
            UNCComedor.remote = !UNCComedor.remote
        })
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func addViaTextButtonTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "balance.add.user.text.title".localized(),
                                   message: "balance.add.user.text.description".localized(),
                                   preferredStyle: .alert)

        ac.addTextField { textField in
            textField.enablesReturnKeyAutomatically = true
            textField.autocapitalizationType = .allCharacters
            textField.clearButtonMode = .whileEditing
        }
        ac.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel))
        ac.addAction(UIAlertAction(title: "balance.add.user.text.confirm".localized(), style: .default) { [unowned self, ac] _ in
            guard let text = ac.textFields!.first!.text?.uppercased() else { return }
            
            let user = User(fromCode: text)
            self.add(user: user)
        })
        present(ac, animated: true)
    }
    
    @objc private func addViaCameraButtonTapped(_ sender: UIBarButtonItem) {
        let bsvc = BarcodeScannerViewController()
        bsvc.delegate = self
        navigationController?.pushViewController(bsvc, animated: true)
    }
    
    // MARK: Methods
    func add(user: User) {
        // Make sure it doesn't already exist.
        guard !users.contains(user) else {
            os_log("User already exists.", log: .default, type: .debug)
            // TODO: Maybe alert the user?
            return
        }
        users.append(user)
        os_log("User added successfully.", log: .default, type: .debug)
        
        // Add a new user.
        users.update { users in
            DispatchQueue.main.async { [unowned self] in
                self.users = users
                self.tableView.reloadData()
                self.saveUsers()
            }
        }
    }
    
    func showReservationLogin(to user:User){
        DispatchQueue.main.async {
            let alertvc = CaptchaViewController().thenPresent(over: self)
            UNCComedor.api.getReservationLogin(to: user.code){
                result in
                switch result {
                case let .success(reservationLogin):
                    guard let captchaData = reservationLogin.captchaImage,
                        let captchaImage = UIImage(data: captchaData) else {
                            print("Cant decode captcha image")
                            alertvc.setResultMessage("balance.reservation.captcha.error.label".localized())
                            return
                    }
                    
                    alertvc.setCaptchaImage(captchaImage)
                    alertvc.onConfirmAlert {
                        text in
                        let cleanReservationLogin = reservationLogin.copy(withCaptchaText: text, withCaptchaImage: nil)
                        UNCComedor.api.getReservation(with: cleanReservationLogin){
                            result in
                            //If itsn't redoLogin save cleanReservation
                            let (resultText, redoLogin) = UNCComedor.reservationResult(result)
                            alertvc.setResultMessage(resultText)
                            if !redoLogin {
                                guard case let .success(status) = result,
                                    let path = status.path, let token = status.token else {
                                    return
                                }
                                cleanReservationLogin.copy(withPath: path, withToken:token, withCaptchaImage: nil)
                                    .save()
                            }
                        }
                    }
                case .failure(_):
                    alertvc.setResultMessage("balance.reservation.error.label".localized())
                    //print(err)
                }
            }
        }
    }
    
    private func saveUsers() {
        let jsonEncoder = JSONEncoder()
        do {
            let data = try jsonEncoder.encode(users)
            try data.write(to: User.ArchiveURL)
            os_log("Users successfully saved.", log: .default, type: .debug)
        } catch {
            os_log("Failed to save users...", log: .default, type: .error)
            print("Error: \(error).")
        }
    }
    
    private func savedUsers() -> [User]? {
        let jsonDecoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: User.ArchiveURL)
            let users = try jsonDecoder.decode([User].self, from: data)
            return users
        } catch {
            os_log("Failed to load users...", log: .default, type: .error)
            print("Error: \(error).")
            return nil
        }
    }
    
    @objc private func refreshData(_ refreshControl: UIRefreshControl? = nil) {
        users.update { (users) in
            DispatchQueue.main.async {
                self.users = users
                self.saveUsers()
                self.tableView.reloadData()
                refreshControl?.endRefreshing()
            }
        }
    }
}
