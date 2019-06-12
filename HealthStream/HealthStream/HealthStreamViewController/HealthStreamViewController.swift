//
//  HealthStreamViewController.swift
//  HealthStream
//
//  Created by Jan Rombout on 12/06/2019.
//  Copyright © 2019 Rommed BV. All rights reserved.
//

import UIKit
import Parse
import Bolts

class HealthStreamViewController: PFQueryTableViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate
{
    var user:PFUser?

    override init(style: UITableView.Style, className: String!)
    {
        super.init(style: style, className: className)
        
        _commonInit()
    }
    
    init(style: UITableView.Style, className: String!, user: PFUser)
    {
        super.init(style: style, className: className)
        
        self.user = user
        
        _commonInit()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func _commonInit()
    {
        print(#function)
        
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 25
        
        self.parseClassName = "Post"
        self.tableView.allowsSelection = false
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 400.0
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()


    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if PFUser.current() == nil
        {
            let loginVC:PFLogInViewController = PFLogInViewController()
            loginVC.fields = [PFLogInFields.usernameAndPassword, PFLogInFields.logInButton, PFLogInFields.signUpButton]
            loginVC.view.backgroundColor = UIColor.white
            
            loginVC.delegate = self
            
            let signupVC:PFSignUpViewController = PFSignUpViewController()
            signupVC.view.backgroundColor = UIColor.white
            
            signupVC.delegate = self
            
            loginVC.signUpController = signupVC
            
            self.present(loginVC, animated: true, completion: nil)
        }
        
        self.loadObjects()
    }
    
    // mark: - Log in with Parse
    
    func log(_ logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool
    {
        if username.count > 0 && password.count > 0
        {
        return true
        }
        
        let alert:UIAlertController = UIAlertController(title: "Mislukt", message: "Vul alle velden in", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Voltooid", style: UIAlertAction.Style.default, handler: nil))
        
        logInController.present(alert, animated: true, completion: nil)
        
        return false
    }
    
    func log(_ logInController: PFLogInViewController, didFailToLogInWithError error: Error?)
    {
        let alert:UIAlertController = UIAlertController(title: "Mislukt", message: "Niet herkend, probeer het opnieuw", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Gelukt", style: UIAlertAction.Style.default, handler: nil))
        
        logInController.present(alert, animated: true, completion: nil)
    }
    
    func log(_ logInController: PFLogInViewController, didLogIn user: PFUser)
    {
        self.loadObjects()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // mark: - Sign up with Parse
    
    func  signUpViewController(_ signUpController: PFSignUpViewController, shouldBeginSignUp info: [String : String]) -> Bool
    {
        var success = false
        
        for (_, value) in info
        {
            if !value.isEmpty
            {
                success = true
                continue
            }
            
            success = false
            break
        }
        
        if success == false
        {
            let alert:UIAlertController = UIAlertController(title: "Foutmelding", message: "Vul alle velden in", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Gelukt    ", style: UIAlertAction.Style.default, handler: nil))
            
            signUpController.present(alert, animated: true, completion: nil)
        }
        
        return success
    }
    
    func signUpViewController(_ signUpController: PFSignUpViewController, didFailToSignUpWithError error: Error?) {
        let alert:UIAlertController = UIAlertController(title: "Foutmelding", message: "Er ging iets mis, probeer het opnieuw", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Gelukt", style: UIAlertAction.Style.default, handler: nil))
    }
    
    func signUpViewController(_ signUpController: PFSignUpViewController, didSignUp user: PFUser)
    {
        let user_follow:PFObject = PFObject(className: "User_Follow")
        user_follow["user"] = user
        user_follow["follower"] = user
        
        user_follow.saveInBackground()
            {
                (success, error) in
                
                self.dismiss(animated: true, completion: nil)
        }
        
        self.loadObjects()
    }
    
    // MARK: - Parse quere
    
    override func queryForTable() -> PFQuery<PFObject>
    {
        let query:PFQuery = PFQuery(className: "Post")
        query.includeKey("user")
        query.order(byDescending: "createdAt")
        
        if objects != nil && objects!.count == 0
        {
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
        }
        
        return query
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
}
