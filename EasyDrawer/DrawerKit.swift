//
//  DrawerKit.swift
//  EasyDrawer
//
//  Created by 郑林琴 on 16/1/9.
//  Copyright © 2016年 Ice Butterfly. All rights reserved.
//

import UIKit


let kConst_DrawerScreenWidth  = UIScreen.mainScreen().bounds.width
let kConst_DrawerScreenHeight = UIScreen.mainScreen().bounds.height

@objc public protocol DrawerViewLayoutProtocol{
    func layoutDrawerView()
}

@objc public protocol DrawerAnimateViewProtocol{
    func animateSubView() -> UIView
}

@objc public protocol EasyDrawer: NSObjectProtocol{
    
    optional func initialController()
    optional func layoutDrawerView()
    
    func addController()
    
    // MARK: Left Animation
    optional func showLeftAnimation()
    optional func leftDismissAnimation()
    optional func leftPercentDriven(percent:Float)
    
    // MARK: Right Animation
    optional func showRightAnimation()
    optional func rightDismissAnimation()
    optional func rightPercentDriven(percent:Float)
    
}

public class EasyDrawerViewController : UIViewController{
    var easyDrawer: EasyDrawer!
}




public class DrawerKit: NSObject , EasyDrawer{
    
    @IBOutlet weak var centerController: EasyDrawerViewController!
    @IBOutlet weak var rightController: EasyDrawerViewController?
    @IBOutlet weak var leftController: EasyDrawerViewController?
    
    // MARK:
    public final override func awakeFromNib() {
        self.initialController()
        self.addController()
        self.layoutDrawerView()

        if let vc = self.centerController as? DrawerViewLayoutProtocol{
            vc.layoutDrawerView()
        }
    }
    
    public func initialController() {
        
    }
    
    public func layoutDrawerView() {
        
    }
    
    public func addController(){
        
        if let centerVC = self.centerController{
            
            if let leftVC = self.leftController{
                
                centerVC.addChildViewController(leftVC)
                centerVC.view.addSubview(leftVC.view)
            }
            
            if let rightVC = self.rightController{
                
                centerVC.addChildViewController(rightVC)
                centerVC.view.addSubview(rightVC.view)
            }
        }
    }
}

public class DrawerStoryboardKit: DrawerKit{
    
    @IBInspectable var leftIdentifier: String?
    @IBInspectable var rightIdentifier: String?
    
    public override func initialController() {
        
        self.centerController.easyDrawer = self
        
        if let identi = leftIdentifier{
            
            self.leftController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(identi) as? EasyDrawerViewController
            
            if let left = self.leftController{
                
                left.easyDrawer = self
                
            }
        }
        
        if let identi = rightIdentifier{
            
            self.rightController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(identi) as? EasyDrawerViewController
            
            if let right = self.rightController{
                right.easyDrawer = self
            }
        }
    }
    
    public override func layoutDrawerView() {
        
        let screenWidth = UIScreen.mainScreen().bounds.width

        let screenHeigh = UIScreen.mainScreen().bounds.height
        
        if let leftVC = self.leftController{
            leftVC.view.frame = CGRectMake(-screenWidth, 0, screenWidth, screenHeigh)
        }
        
        if let rightVC = self.rightController{
            rightVC.view.frame = CGRectMake(screenWidth, 0, screenWidth, screenHeigh)
        }
    }
}


let animateKeyRightDrawerShow = "drawer.right.show"
let animateKeyRightDrawerDissmiss = "drawer.right.dismiss"


// MARK: Only right needed
public class RightDrawer : DrawerStoryboardKit{
    
    lazy var showAnimation    = CABasicAnimation(keyPath: "transform.translation.x")
    lazy var dismissAnimation = CABasicAnimation(keyPath: "transform.translation.x")
    var panGesture: UIPanGestureRecognizer!
    
    // MARK: gesture
    public override func initialController() {
        super.initialController()
        self.panGesture = UIPanGestureRecognizer(target: self, action: "pannedAction:")
//        self.centerController.view.addGestureRecognizer(self.panGesture)
    }
    
    func pannedAction(sender: UIPanGestureRecognizer){
        
        switch sender.state{
        case .Began:
            self.showRightAnimation()
        case .Changed:
            let moveX = sender.translationInView(self.centerController.view).x
            self.rightPercentDriven(moveX/kConst_DrawerScreenWidth)
        case .Ended:
            let moveX = sender.translationInView(self.centerController.view).x
            if moveX >= kConst_DrawerScreenWidth/2.0{
                //
            }
        default: break

        }
    }
    

    // MARK: animation
    public func showRightAnimation() {
        
        self.rightController?.view.frame = CGRectMake(0, 0, kConst_DrawerScreenWidth, kConst_DrawerScreenHeight)
        
        if let rightVC = self.rightController as? DrawerAnimateViewProtocol{
            
            let rightAnimateView = rightVC.animateSubView()
            
            self.showAnimation.fromValue = rightAnimateView.frame.width
            self.showAnimation.toValue   = 0
            
            rightAnimateView.layer.addAnimation(self.showAnimation, forKey: animateKeyRightDrawerShow)
        }
    }
    
    public func rightDismissAnimation() {
        
        var frame = self.centerController!.view.frame
        frame.origin.x = 0
        self.rightController?.view.frame = frame

        
        if let rightVC = self.rightController as? DrawerAnimateViewProtocol{
            
            let rightAnimateView = rightVC.animateSubView()

            self.dismissAnimation.fromValue = 0
            self.dismissAnimation.toValue   = rightAnimateView.frame.width
            self.dismissAnimation.delegate = self
            
            rightAnimateView.layer.addAnimation(self.dismissAnimation, forKey: animateKeyRightDrawerDissmiss)

        }
    }
    
    public func rightPercentDriven(percent: CGFloat) {
        
        
        if let rightVC = self.rightController as? DrawerAnimateViewProtocol{
            
            let rightAnimateView = rightVC.animateSubView()
            rightAnimateView.layer.speed = 0
            self.showAnimation.beginTime = self.showAnimation.duration * Double(percent)
            
        }

    }
    
    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        if let rightVC = self.rightController as? DrawerAnimateViewProtocol{
    
                var frame = self.rightController!.view.frame
                frame.origin.x = kConst_DrawerScreenWidth
                self.rightController?.view.frame = frame
                rightVC.animateSubView().layer.removeAnimationForKey(animateKeyRightDrawerDissmiss)
        }
    }
}
