//
//  TSActionSheet.swift
//  ThreeStone
//
//  Created by 王磊 on 17/2/10.
//  Copyright © 2017年 ThreeStone. All rights reserved.
//

import UIKit
enum TSActionSheetDismissType: Int {
    case TapDarkShadow
    case Item
}
/*
 if dismissType ==  .TapDarkShadow buttonIndex = nil
 if dismissType ==  .Button buttonIndex = button.tag
 */
typealias TSActionSheetBlock = (dismissType: TSActionSheetDismissType,buttonIndex: Int?) -> ()

private let Screen_Width: CGFloat = CGRectGetWidth(UIScreen.mainScreen().bounds)

private let Screen_Height: CGFloat = CGRectGetHeight(UIScreen.mainScreen().bounds)

private let ActionSheet_Title_Height: CGFloat = 60

private let ActionSheet_Button_Height: CGFloat = 60

private let ActionSheet_Show_Animated_Duration: NSTimeInterval = 0.3

private let ActionSheet_Dismiss_Animated_Duration: NSTimeInterval = 0.2

private func RGBColor(r: CGFloat,g: CGFloat ,b: CGFloat) -> UIColor {
    return UIColor(red: r / 255.0,green: g / 255.0,blue: b / 255.0,alpha: 1)
}

private var Clear_Color: UIColor = UIColor.clearColor()

private var White_Color: UIColor = UIColor.whiteColor()

private extension String {
    
    var lengths: Int {
        return lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    }
    
}

private extension UIImage {
    
    class func imageWithColor(color: UIColor) -> UIImage {
        
        let rect = CGRectMake(0, 0, 1.0, 1.0)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}


class TSActionSheet: UIView {
    /*
     * actionSheetBlock 点击的哪里 如果点击的是按钮 回调按钮下标
     */
    private var actionSheetBlock: TSActionSheetBlock?
    
    /*
     * 透明背景 view
     */
    private lazy var darkShadowView: UIView = UIView()
    /*
     * 透明背景的透明度
     */
    internal var darkShadowAlpha: CGFloat = 0.3
    /*
     * 按钮背景 view
     */
    private lazy var buttonBackgroundView: UIView = UIView()
    
    /*
     * 标题
     */
    private var title: String = ""
    /*
     * 取消按钮标题
     */
    private var cancleButtonTitle: String = ""
    /*
     *
     */
    private var destructiveButtonTitle: String = ""
    
    private var otherButtonTitles: NSMutableArray = NSMutableArray()
    
    internal var titleLabelFont: UIFont = UIFont.systemFontOfSize(15)
    
    internal var titleLabelTextColor: UIColor = UIColor.darkGrayColor()
    
    internal var destructiveTextColor: UIColor = UIColor.redColor()
    
    internal var otherBtnFont: UIFont = UIFont.systemFontOfSize(13)
    
    internal var otherBtnTextColor: UIColor = UIColor.blackColor()
    
    static func actionSheet(title: String = "",cancleButtonTitle: String = "",destructiveButtonTitle: String,otherButtonTitles: NSArray? ,actionSheetBlock: TSActionSheetBlock) -> TSActionSheet {
        return TSActionSheet(title: title, cancleButtonTitle: cancleButtonTitle, destructiveButtonTitle: destructiveButtonTitle, otherButtonTitles: otherButtonTitles, actionSheetBlock: actionSheetBlock)
    }
    
    required init(title: String = "",cancleButtonTitle: String = "",destructiveButtonTitle: String,otherButtonTitles: NSArray?,actionSheetBlock: TSActionSheetBlock) {
        super.init(frame: CGRectMake(0, 0, Screen_Width, Screen_Height))
        
        self.title = title
        
        self.cancleButtonTitle = cancleButtonTitle.length > 0 ? cancleButtonTitle : "取消"
        
        if destructiveButtonTitle.length > 0 {
            
            self.otherButtonTitles.addObject(destructiveButtonTitle)
        }
        
        self.destructiveButtonTitle = destructiveButtonTitle
        
        if let _ = otherButtonTitles where otherButtonTitles!.count > 0 {
            self.otherButtonTitles.addObjectsFromArray(otherButtonTitles! as [AnyObject])
        }
        
        self.actionSheetBlock = actionSheetBlock
        
        commitInitSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension TSActionSheet {
    
    private func commitInitSubviews() {
        
        frame = CGRectMake(0, 0, Screen_Width, Screen_Height)
        
        backgroundColor = Clear_Color
        
        hidden = true
        
        darkShadowView.frame = bounds
        
        darkShadowView.backgroundColor = RGBColor(30, g: 30, b: 30)
        
        addSubview(darkShadowView)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewDismiss))
        
        darkShadowView.addGestureRecognizer(tap)
        
        buttonBackgroundView.backgroundColor = RGBColor(220, g: 220, b: 220)
        
        addSubview(buttonBackgroundView)
        
        if title.length > 0 {
            
            let titleLabel: UILabel = UILabel(frame: CGRectMake(0, ActionSheet_Button_Height - ActionSheet_Title_Height, Screen_Width, ActionSheet_Title_Height))
            
            titleLabel.font = titleLabelFont
            
            titleLabel.text = title
            
            titleLabel.textAlignment = .Center
            
            titleLabel.textColor = titleLabelTextColor
            
            titleLabel.backgroundColor = White_Color
            
            titleLabel.numberOfLines = 0
            
            buttonBackgroundView.addSubview(titleLabel)
        }
        var i: Int = 0
        
        print(otherButtonTitles)
        
        for item in otherButtonTitles {
            
            let btn: UIButton = UIButton(type: .Custom)
            
            btn.tag = i
            
            buttonBackgroundView.addSubview(btn)
            
            btn.backgroundColor = White_Color
            
            btn.titleLabel?.font = titleLabelFont
            
            btn.setTitleColor(otherBtnTextColor, forState: .Normal)
            
            if i == 0 && destructiveButtonTitle.length > 0 {
                
                btn.setTitleColor(destructiveTextColor, forState: .Normal)
            }
            
            let btnY = ActionSheet_Button_Height * CGFloat(i + (title.length > 0 ? 1 : 0 ))
            
            btn.frame = CGRectMake(0, btnY, Screen_Width, ActionSheet_Button_Height)
            
            btn.addTarget(self, action: #selector(buttonClick), forControlEvents: .TouchUpInside)
            
            btn.setTitle(item as? String, forState: .Normal)
            
            btn.setBackgroundImage(UIImage.imageWithColor(RGBColor(245, g: 245, b: 245)), forState: .Highlighted)
            
            buttonBackgroundView.addSubview(btn)
            
            let line = UIView()
            
            line.backgroundColor = RGBColor(200, g: 200, b: 200)
            
            line.frame = CGRectMake(0, btnY, Screen_Width, 0.5)
            
            buttonBackgroundView.addSubview(line)
            
            i += 1
        }
        
        let cancelBtn: UIButton = UIButton(type: .Custom)
        
        cancelBtn.tag = otherButtonTitles.count
        
        cancelBtn.backgroundColor = White_Color
        
        cancelBtn.titleLabel?.font = otherBtnFont
        
        cancelBtn.setTitle(cancleButtonTitle, forState: .Normal)
        
        cancelBtn.setTitleColor(otherBtnTextColor, forState: .Normal)
        
        cancelBtn.setBackgroundImage(UIImage.imageWithColor(RGBColor(245, g: 245, b: 245)), forState: .Highlighted)
        
        let btnY: CGFloat = ActionSheet_Button_Height * CGFloat(otherButtonTitles.count + (title.length > 0 ? 1 : 0)) + 3
        
        cancelBtn.frame = CGRectMake(0, btnY, Screen_Width, ActionSheet_Button_Height)
        
        cancelBtn.addTarget(self, action: #selector(buttonClick), forControlEvents: .TouchUpInside)
        
        buttonBackgroundView.addSubview(cancelBtn)
        
        let bg_height: CGFloat = ActionSheet_Button_Height * CGFloat(otherButtonTitles.count + 1 + (title.length > 0 ? 1 : 0)) + 3
        
        buttonBackgroundView.frame = CGRectMake(0, Screen_Height, Screen_Width, bg_height)
        
    }
    
}
extension TSActionSheet {
    
    @objc private func buttonClick(button: UIButton) {
        
        if let _ = actionSheetBlock {
            
            actionSheetBlock!(dismissType: .Item,buttonIndex: button.tag)
        }
        
        dismiss()
        
    }
}

extension TSActionSheet {
    
    @objc private func viewDismiss() {
        
        if let _ = actionSheetBlock {
            
            actionSheetBlock!(dismissType: .TapDarkShadow,buttonIndex: nil)
        }
        
        dismiss()
    }
    
}
extension TSActionSheet {
    
    internal func show() {
        let window = UIApplication.sharedApplication().keyWindow
        
        window?.addSubview(self)
        
        hidden = false
        
        UIView.animateWithDuration(ActionSheet_Show_Animated_Duration, animations: { [weak self] in
            
            self!.darkShadowView.alpha = self!.darkShadowAlpha
            
            self!.buttonBackgroundView.transform = CGAffineTransformMakeTranslation(0, -self!.buttonBackgroundView.height)
            
            //            print(self!.buttonBackgroundView.height)
        }) { (isFinished) in
            
            
        }
    }
    private func dismiss() {
        
        UIView.animateWithDuration(ActionSheet_Dismiss_Animated_Duration, animations: {[weak self] in
            
            self!.darkShadowView.alpha = 0
            
            self!.buttonBackgroundView.transform = CGAffineTransformIdentity
            
        }) { [weak self](isFinished) in
            
            self!.hidden = true
            
            self!.removeFromSuperview()
        }
        
    }
}