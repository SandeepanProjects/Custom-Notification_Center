//
//  ViewController.swift
//  Custom-Notification_Center
//
//  Created by Apple on 26/12/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        CustomNotificationCenter.shared.post(name: "FetchCompleted", object: nil, userInfo: ["id": 10, "name": "Tom"])
        checkObserver()
    }


    func checkObserver() {
        // Observe a notification
        CustomNotificationCenter.shared.addObserver(forName: "FetchCompleted", object: nil, queue: OperationQueue.current) { (notification) in
            print(notification.userInfo?["id"]!) // Prints 10
            print(notification.userInfo?["name"]!) // Prints Tom
        }
        
        // Remove all observers for a notification
        CustomNotificationCenter.shared.removeObservers(name: "FetchCompleted")
        
    }
    
}

