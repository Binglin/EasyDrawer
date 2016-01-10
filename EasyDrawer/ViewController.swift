//
//  ViewController.swift
//  EasyDrawer
//
//  Created by 郑林琴 on 16/1/9.
//  Copyright © 2016年 Ice Butterfly. All rights reserved.
//

import UIKit

class ViewController: EasyDrawerViewController,DrawerViewLayoutProtocol {

    override func viewDidLoad() {
        print(self.navigationController)
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func action(sender: UIButton) {
        
        if let drawer = self.easyDrawer as? RightDrawer{
            drawer.showRightAnimation()
        }
//        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Main")
//        self.presentViewController(viewController, animated: true, completion: nil)
        

    }
    
    func layoutDrawerView() {
        if let drawer = self.easyDrawer as? DrawerKit{
//            drawer.leftController?.view.frame = CGRectMake(0, 10, 200, kConst_DrawerScreenHeight - 20)
        }
    }
}

