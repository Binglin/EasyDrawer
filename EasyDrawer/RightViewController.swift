//
//  RightViewController.swift
//  EasyDrawer
//
//  Created by 郑林琴 on 16/1/9.
//  Copyright © 2016年 Ice Butterfly. All rights reserved.
//

import UIKit

class RightViewController: EasyDrawerViewController, DrawerAnimateViewProtocol {
    
    var viewContainer:UIView?
    
//    var drawer : DrawerKit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.7)
        
        let containerWidth = kConst_DrawerScreenWidth / 3.0 * 2
        
        self.viewContainer = UIView(frame: CGRectMake(kConst_DrawerScreenWidth - containerWidth , 0, containerWidth , kConst_DrawerScreenHeight - 0))
        self.view.addSubview(self.viewContainer!)
        self.viewContainer?.backgroundColor = UIColor.yellowColor()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateSubView() -> UIView {
        return self.viewContainer!
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let drawer = self.easyDrawer as? RightDrawer{
             drawer.showRightAnimation()
        }
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
