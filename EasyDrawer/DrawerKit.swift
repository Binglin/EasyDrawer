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
    //controller 中view根据progress管理显示进度
    optional func drawerActioned(progress: CGFloat)
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
    
    optional func dismissDrawer()
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
public class RightDrawer : DrawerStoryboardKit, UIGestureRecognizerDelegate{
    
    // MARK: property
    var panGesture: UIPanGestureRecognizer!
    var dismissGesture: UITapGestureRecognizer!
    
    // MARK: gesture
    public override func initialController() {
        super.initialController()
        self.panGesture = UIPanGestureRecognizer(target: self, action: "pannedAction:")
        self.centerController.view.addGestureRecognizer(self.panGesture)
        
        self.dismissGesture = UITapGestureRecognizer(target: self, action: "tappedAction:")
        self.centerController.view.addGestureRecognizer(self.dismissGesture)
        self.dismissGesture.delegate = self
        
    }
    
    func tappedAction(sender: UITapGestureRecognizer){
        
        print("tapped")
        self.rightDismissAnimation()
    }
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool{
        if gestureRecognizer == self.dismissGesture{
            if let rightVC = self.rightController as? DrawerAnimateViewProtocol{
                if CGRectContainsPoint(rightVC.animateSubView().frame, gestureRecognizer.locationInView(self.centerController.view)){
                    return false
                }
            }
        }

        if gestureRecognizer == self.panGesture{
            let locateX = gestureRecognizer.locationInView(self.centerController.view).x
            if  locateX < 60 || locateX > kConst_DrawerScreenWidth / 2.0{
                return true
            }else{
                return false
            }
        }
        
        return true
    }


    
    func pannedAction(sender: UIPanGestureRecognizer){
        
        print("panned")
        switch sender.state{
        case .Began:
            self.panBegin(sender)
        case .Changed:
            self.panMove(sender)
        case .Ended:
            self.panEnd(sender)
        default: break

        }
    }
    

    // MARK: animation
    public func showRightAnimation() {
        
        self.rightController?.view.frame = CGRectMake(0, 0, kConst_DrawerScreenWidth, kConst_DrawerScreenHeight)
        
        if let rightVC = self.rightController as? DrawerAnimateViewProtocol{
            
            let rightAnimateView = rightVC.animateSubView()
            
            let animateTime = 0.1
            
            rightAnimateView.frame = CGRectMake(kConst_DrawerScreenWidth, 0, rightAnimateView.frame.width, kConst_DrawerScreenHeight)
            
            self.rightController?.view.alpha = 0
            
            UIView.animateWithDuration(animateTime, animations: { () -> Void in
                rightAnimateView.frame = CGRectMake(kConst_DrawerScreenWidth - rightAnimateView.frame.width, 0, rightAnimateView.frame.width, kConst_DrawerScreenHeight)
                self.rightController?.view.alpha = 1
            })
         }
    }
    
    public func rightDismissAnimation() {
        
        if let rightVC = self.rightController as? DrawerAnimateViewProtocol{
            
            let rightAnimateView = rightVC.animateSubView()
            
            let animateTime = 0.1
            
            rightAnimateView.frame = CGRectMake(kConst_DrawerScreenWidth  - rightAnimateView.frame.width, 0, rightAnimateView.frame.width, kConst_DrawerScreenHeight)
            
            self.rightController?.view.alpha = 1
            
            UIView.animateWithDuration(animateTime,
                animations: { () -> Void in
                    rightAnimateView.frame = CGRectMake(kConst_DrawerScreenWidth, 0, rightAnimateView.frame.width, kConst_DrawerScreenHeight)
                    self.rightController?.view.alpha = 0
                }, completion: { (complete) -> Void in
                    var frame = self.centerController!.view.frame
                    frame.origin.x = kConst_DrawerScreenWidth
                    self.rightController?.view.frame = frame
            })
        }
    }
    
    
    
    
    // MARK: private
    public func panBegin(sender: UIPanGestureRecognizer){
        self.rightController?.view.frame = CGRectMake(0, 0, kConst_DrawerScreenWidth, kConst_DrawerScreenHeight)
    }
    
    public func panMove(sender: UIPanGestureRecognizer){
        let moveX = sender.translationInView(self.centerController.view).x
        let progress = moveX / kConst_DrawerScreenWidth
        //左划
        if moveX < 0{
            self.rightPercentDriven(progress)
        }else{
            
        }
        if let center = self.centerController as? DrawerAnimateViewProtocol{
            center.drawerActioned?(progress)
        }
    }
    
    public func panEnd(sender: UIPanGestureRecognizer){
        let moveX = sender.translationInView(self.centerController.view).x
        
        
        //左划
        if moveX < 0 {
            self.completePercentDriven(fabs(moveX / kConst_DrawerScreenWidth), cancel: (fabs(moveX) * 2 < kConst_DrawerScreenWidth/2.0))
            
        }
    }
    
    
    public func rightPercentDriven(percent: CGFloat) {
        
        print(percent)
        
        if let rightVC = self.rightController as? DrawerAnimateViewProtocol{
            
            let currentPercent = fabs(percent) * 2
            
            let per = currentPercent > 1.0 ? 1.0 : currentPercent
            
            let rightAnimateView = rightVC.animateSubView()
            
            self.rightController?.view.alpha = per
            
            var frame = rightAnimateView.frame
            frame.origin.x = kConst_DrawerScreenWidth - rightAnimateView.frame.width * per
            rightAnimateView.frame = frame
            
            rightVC.drawerActioned?(percent)
        }
    }
    
    public func completePercentDriven(percent: CGFloat, cancel: Bool){
        
        print("complete percent \(percent)")
        if let rightVC = self.rightController as? DrawerAnimateViewProtocol{
            
            let rightAnimateView = rightVC.animateSubView()

            let animateTime = 0.3 * (1 - percent)
            
            let destinationX = cancel ? kConst_DrawerScreenWidth : kConst_DrawerScreenWidth - rightAnimateView.frame.width
            let destinationAlpha = CGFloat(cancel ? 0.0 : 1.0)
            
            UIView.animateWithDuration(Double(animateTime), animations: { () -> Void in
                rightAnimateView.frame = CGRectMake(destinationX, 0, rightAnimateView.frame.width, kConst_DrawerScreenHeight)
                self.rightController?.view.alpha = destinationAlpha
            })
        }
    }
}
