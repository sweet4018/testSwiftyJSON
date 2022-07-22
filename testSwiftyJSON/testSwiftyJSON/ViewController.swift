//
//  ViewController.swift
//  testSwiftyJSON
//
//  Created by Luan on 2019/1/29.
//  Copyright © 2019 Luan. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.test_JSONSerialization()
        DataManager.test_SwiftyJSON()
	DataManager.test_SwiftyJSONWithNSDictionary()
    }


}

