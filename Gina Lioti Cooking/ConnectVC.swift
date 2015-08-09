//
//  ConnectVC.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 09/08/2015.
//  Copyright © 2015 gl. All rights reserved.
//

import UIKit
import SafariServices

class ConnectVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://ginalioti.com/connect")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
