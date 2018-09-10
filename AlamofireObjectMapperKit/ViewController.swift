//
//  ViewController.swift
//  AlamofireObjectMapperKit
//
//  Created by David Bala on 09/09/2018.
//  Copyright © 2018 AXNET. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var repos: [GithubRepo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func didPressSearchButton(_ sender: AnyObject) {
        guard let userName = userNameField.text, userName != "" else { return }
        
        GithubService.shared.getRepos(of: userName)
            .then { response -> Void in
                self.repos = response.repos
                self.tableView.reloadData()
            }.catch { error in
                debugPrint("Error while fetching github repos of \(userName)")
                debugPrint(error)
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GithubRepoTableViewCell", for: indexPath) as! GithubRepoTableViewCell
        cell.setData(repos[indexPath.row])
        return cell
    }
}
