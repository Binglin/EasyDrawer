//
//  ViewController.swift
//  EasyDrawer
//
//  Created by 郑林琴 on 16/1/9.
//  Copyright © 2016年 Ice Butterfly. All rights reserved.
//

import UIKit

class ViewController: EasyDrawerViewController,DrawerViewLayoutProtocol, DrawerAnimateViewProtocol {

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
    }
    
    func layoutDrawerView() {
        if let drawer = self.easyDrawer as? DrawerKit{
            drawer.leftController?.view.frame = CGRectMake(-200, 10, 200, kConst_DrawerScreenHeight - 20)
        }
    }
    
    func animateSubView() -> UIView {
        return self.view
    }

    func drawerActioned(progress: CGFloat) {
        if progress > 0 {
            if let drawer = self.easyDrawer as? DrawerKit{
                drawer.leftController?.view.frame = CGRectMake(-200 + 200 * progress * 2, 10, 200, kConst_DrawerScreenHeight - 20)
            }
        }
    }
}

