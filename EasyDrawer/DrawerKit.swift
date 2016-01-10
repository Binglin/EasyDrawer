//
//  DrawerKit.swift
//  EasyDrawer
//
//  Created by 郑林琴 on 16/1/9.
//  Copyright © 2016年 Ice Butterfly. All rights reserved.
//

import UIKit
import pop

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
    
    var panGesture: UIPanGestureRecognizer!
    var dismissGesture: UITapGestureRecognizer!
    
    // MARK: gesture
    public override func initialController() {
        super.initialController()
        self.panGesture = UIPanGestureRecognizer(target: self, action: "pannedAction:")
        self.centerController.view.addGestureRecognizer(self.panGesture)
        
        self.dismissGesture = UITapGestureRecognizer(target: self, action: "tappedAction:")
        self.centerController.view.addGestureRecognizer(self.dismissGesture)
        
    }
    
    func tappedAction(sender: UITapGestureRecognizer){
        
        print("tapped")
        self.rightDismissAnimation()
    }
    
    func pannedAction(sender: UIPanGestureRecognizer){
        
        print("panned")
        switch sender.state{
        case .Began:
            self.showRightAnimation()
//            self.showAnimation.pa
        case .Changed:
            let moveX = sender.translationInView(self.centerController.view).x
            self.rightPercentDriven(moveX/kConst_DrawerScreenWidth)
        case .Ended:
            let moveX = sender.translationInView(self.centerController.view).x
            if moveX >= kConst_DrawerScreenWidth/2.0{
                //

            }else{
                self.rightDismissAnimation()
            }
        default: break

        }
    }
    

    // MARK: animation
    public func showRightAnimation() {
        
        self.rightController?.view.frame = CGRectMake(0, 0, kConst_DrawerScreenWidth, kConst_DrawerScreenHeight)
        
        if let rightVC = self.rightController as? DrawerAnimateViewProtocol{
            
            let rightAnimateView = rightVC.animateSubView()
            
            let animateTime = 0.1

            let anim = POPBasicAnimation(propertyNamed: kPOPLayerTranslationX)
            anim.fromValue = kConst_DrawerScreenWidth
            anim.toValue = kConst_DrawerScreenWidth - rightAnimateView.frame.width/2 * 3
            anim.duration = animateTime
            rightAnimateView.layer.pop_addAnimation(anim, forKey: "translateX")

            let alphaAni = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            alphaAni.fromValue = 0
            alphaAni.toValue   = 1
            alphaAni.duration  = animateTime
            
            self.rightController?.view.pop_addAnimation(alphaAni, forKey: "showAlpha")
        }
    }
    
    public func rightDismissAnimation() {
        
        if let rightVC = self.rightController as? DrawerAnimateViewProtocol{
            
            let rightAnimateView = rightVC.animateSubView()
            
            let animateTime = 0.1
            
            let anim = POPBasicAnimation(propertyNamed: kPOPLayerTranslationX)
            anim.fromValue = kConst_DrawerScreenWidth - rightAnimateView.frame.width/2 * 3
            anim.toValue =  kConst_DrawerScreenWidth
            anim.duration = animateTime
            anim.completionBlock = { complete in
                
                var frame = self.centerController!.view.frame
                frame.origin.x = kConst_DrawerScreenWidth
                self.rightController?.view.frame = frame
            }
            
            let alphaAni = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            alphaAni.fromValue = 1
            alphaAni.toValue   = 0
            anim.duration  = animateTime

            self.rightController?.view.pop_addAnimation(alphaAni, forKey: "fade")
            
            rightAnimateView.layer.pop_addAnimation(anim, forKey: "translateX.dismiss")
            
        }
    }
    
    public func rightPercentDriven(percent: CGFloat) {
        

    }
}
