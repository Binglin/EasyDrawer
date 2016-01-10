//
//  RightViewController.swift
//  EasyDrawer
//
//  Created by 郑林琴 on 16/1/9.
//  Copyright © 2016年 Ice Butterfly. All rights reserved.
//

import UIKit

class RightViewController: EasyDrawerViewController, DrawerAnimateViewProtocol {
    
    @IBOutlet weak var viewContainer:UIView?
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.7)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateSubView() -> UIView {
        return self.viewContainer!
    }
    
    func drawerActioned(progress: CGFloat) {
        self.button.alpha = fabs(progress)
    }

}
