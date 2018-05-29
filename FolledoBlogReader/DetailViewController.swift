//
//  DetailViewController.swift
//  FolledoBlogReader
//
//  Created by Samuel Folledo on 5/10/18.
//  Copyright © 2018 Samuel Folledo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController { //1

    //@IBOutlet weak var detailDescriptionLabel: UILabel! //1

    @IBOutlet var webView: UIWebView! //34 mins
    
    func configureView() { //1
        // Update the user interface for the detail item.

        if let detail = detailItem { //1
            
            self.title = detail.value(forKey: "title") as! String //39:20 min to have the title update depending on the selected article's title
            
            if let blogWebView = self.webView { //1
                //label.text = detail.timestamp!.description  //1
            //instead of showing the timestamp
                //label.text = detail.value(forKey: "title") as? String //33 mins.
                blogWebView.loadHTMLString((detail.value(forKey: "content") as? String)!, baseURL: nil) //35:35 min
            }
        }
    }

    override func viewDidLoad() { //1
        super.viewDidLoad() //1
        // Do any additional setup after loading the view, typically from a nib.
        configureView() //1
    }

    override func didReceiveMemoryWarning() { //1
        super.didReceiveMemoryWarning() //1
        // Dispose of any resources that can be recreated.
    } //1

    var detailItem: Event? { //1
        didSet { //1
            // Update the view.
            configureView() //1
        } //1
    } //1


}

