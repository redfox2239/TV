//
//  InitialViewController.swift
//  TV電話
//
//  Created by HARADA REO on 2015/07/28.
//  Copyright (c) 2015年 reo harada. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var nickName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as? ViewController
        vc!.nickName = self.nickName.text
    }
}
