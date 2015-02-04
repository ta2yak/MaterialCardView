//
//  MaterialCardView.swift
//  MaterialCardView
//
//  Created by Cem Olcay on 22/01/15.
//  Copyright (c) 2015 Cem Olcay. All rights reserved.
//

import UIKit

extension UIView {
    
    enum MaterialCardRippleLocation {
        case Center
        case TouchLocation
    }
    
    func addRipple (
        color: UIColor,
        duration: NSTimeInterval,
        location: MaterialCardRippleLocation,
        action: (()->Void)?) {
            
        let size = min(w, h) / 2
        let rippleLayer = CALayer ()
        rippleLayer.frame = CGRect (x: 0, y: 0, width: size, height: size)
        rippleLayer.backgroundColor = color.CGColor
        rippleLayer.opacity = 0
        rippleLayer.cornerRadius = size/2
        rippleLayer.name = "ripple"
            
        layer.masksToBounds = true
        layer.addSublayer(rippleLayer)
        
        addTapGesture(1, action: { [unowned self] (tap) -> () in
            var loc = tap.locationInView(self)
            if location == .Center {
                loc = self.center
            }
            
            rippleLayer.position = loc
            self.animateRipple(rippleLayer, duration: duration)
            action? ()
        })
    }
    
    private func animateRipple (ripple: CALayer, duration: NSTimeInterval) {
        let scale = CABasicAnimation (keyPath: "transform.scale")
        scale.fromValue = 1
        scale.toValue = 10
        
        let opacity = CABasicAnimation (keyPath: "opacity")
        opacity.fromValue = 0
        opacity.toValue = 1
        opacity.autoreverses = true
        opacity.duration = duration/2
        
        let anim = CAAnimationGroup ()
        anim.animations = [scale, opacity]
        anim.duration = duration
        anim.timingFunction = CAMediaTimingFunction (name: kCAMediaTimingFunctionEaseIn)
        
        ripple.addAnimation(anim, forKey: "rippleAnimation")
    }
}

extension UIColor {
    
    class func CardHeaderColor () -> UIColor {
        return UIColor.RGBColor(242, g: 242, b: 242)
    }
    
    class func CardCellColor () -> UIColor {
        return UIColor.RGBColor(249, g: 249, b: 249)
    }
    
    class func CardBorderColor () -> UIColor {
        return UIColor.RGBColor(200, g: 199, b: 204)
    }
    
    
    class func TitleColor () -> UIColor {
        return UIColor.RGBColor(51, g: 51, b: 51)
    }
    
    class func TextColor () -> UIColor {
        return RGBColor(144, g: 144, b: 144)
    }
}

extension UIFont {
    
    class func AvenirNext (type: FontType, size: CGFloat) -> UIFont {
        return UIFont.Font(UIFont.FontName.AvenirNext, type: type, size: size)
    }
    
    class func AvenirNextDemiBold (size: CGFloat) -> UIFont {
        return AvenirNext(UIFont.FontType.DemiBold, size: size)
    }
    
    class func AvenirNextRegular (size: CGFloat) -> UIFont {
        return AvenirNext(UIFont.FontType.Regular, size: size)
    }
}


struct MaterialCardAppeareance {
    
    var headerBackgroundColor: UIColor
    var cellBackgroundColor: UIColor
    var borderColor: UIColor
    
    var titleFont: UIFont
    var titleColor: UIColor
    
    var textFont: UIFont
    var textColor: UIColor
    
    var rippleColor: UIColor
    var rippleDuration: NSTimeInterval
    
    init (
        headerBackgroundColor: UIColor,
        cellBackgroundColor: UIColor,
        borderColor: UIColor,
        titleFont: UIFont,
        titleColor: UIColor,
        textFont: UIFont,
        textColor: UIColor,
        rippleColor: UIColor,
        rippleDuration: NSTimeInterval) {
        self.headerBackgroundColor = headerBackgroundColor
        self.cellBackgroundColor = cellBackgroundColor
        self.borderColor = borderColor
        
        self.titleFont = titleFont
        self.titleColor = titleColor
        
        self.textFont = textFont
        self.textColor = textColor
            
        self.rippleColor = rippleColor
        self.rippleDuration = rippleDuration
    }
}

class MaterialCardCell: UIView {
    
    
    // MARK: Constants
    
    let itemPadding: CGFloat = 16
    
    
    
    // MARK: Properties
    
    private var parentCard: MaterialCardView!
    
    var bottomLine: UIView?
    
    
    
    // MARK: Lifecyle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init (card: MaterialCardView) {
        super.init(frame: CGRect(x: 0, y: 0, width: card.w, height: 0))
        parentCard = card
    }
    
    
    
    // MARK: Create
    
    func addTitle (title: String) {
        let title = UILabel (
            x: itemPadding,
            y: h,
            width: parentCard.w - itemPadding*2,
            padding: itemPadding,
            text: title,
            textColor: parentCard.appeareance.titleColor,
            textAlignment: .Left,
            font: parentCard.appeareance.titleFont)
        addView(title)
    }
    
    func addText (text: String) {
        let text = UILabel (
            x: itemPadding,
            y: h,
            width: parentCard.w - itemPadding*2,
            padding: itemPadding,
            text: text,
            textColor: parentCard.appeareance.textColor,
            textAlignment: .Left,
            font: parentCard.appeareance.textFont)
        addView(text)
    }

    func addView (view: UIView) {
        addSubview(view)
        h += view.h
    }

    
    func drawBottomLine () {
        if let line = bottomLine {
            return
        }
        
        bottomLine = UIView (x: 0, y: h - 1, w: w, h: 1)
        bottomLine!.backgroundColor = parentCard.appeareance.borderColor
        addSubview(bottomLine!)
    }
    
    func removeBottomLine () {
        if let l = bottomLine {
            l.removeFromSuperview()
            bottomLine = nil
        }
    }
}

class MaterialCardView: UIView {
    
    
    // MARK: Constants
    
    let cardPadding: CGFloat = 10
    let cardRadius: CGFloat = 5
    
    let estimatedRowHeight: CGFloat = 53
    let estimatedHeaderHeight: CGFloat = 40
    
    
    
    // MARK: Properties

    var appeareance: MaterialCardAppeareance!
    var items: [MaterialCardCell] = []
    var contentView: UIView!
    
    
    
    // MARK: Lifecylce
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init () {
        super.init()
        defaultInit()
    }
    
    
    init (x: CGFloat, y: CGFloat, w: CGFloat) {
        super.init(frame: CGRect (x: x, y: y, width: w, height: 0))
        defaultInit()
    }
    
    func defaultInit () {
        h = 0
        appeareance = defaultAppeareance()
        
        contentView = UIView (superView: self)
        addSubview(contentView)
    }
    
    
    
    // MARK: Setup
    
    func defaultAppeareance () -> MaterialCardAppeareance {
        return MaterialCardAppeareance (
            headerBackgroundColor: UIColor.CardHeaderColor(),
            cellBackgroundColor: UIColor.CardCellColor(),
            borderColor: UIColor.CardBorderColor(),
            titleFont: UIFont.AvenirNextDemiBold(18),
            titleColor: UIColor.TitleColor(),
            textFont: UIFont.AvenirNextRegular(15),
            textColor: UIColor.TextColor(),
            rippleColor: UIColor.Gray(51, alpha: 0.1),
            rippleDuration: 0.4)
    }
    
    
    
    // MARK: Card
    
    func updateFrame () {
        var current = 0
        var currentY: CGFloat = 0
        for item in items {
            item.y = currentY
            currentY += item.h
            
            item.removeBottomLine()
            if ++current < items.count {
                item.drawBottomLine()
            }
        }
        
        contentView.size = size
        materialize()
    }

    func materialize () {
        
        addShadow(
            CGSize (width: 0, height: 1),
            radius: 1,
            color: UIColor.TitleColor(),
            opacity: 1,
            cornerRadius: cardRadius)
        
        contentView.setCornerRadius(cardRadius)
    }

    
    
    // MARK: Add Cell
    
    func addHeader (title: String) {
        let cell = MaterialCardCell (card: self)
        cell.backgroundColor = appeareance.headerBackgroundColor
        
        cell.addTitle(title)
        cell.h = max (cell.h, estimatedHeaderHeight)
        
        items.insert(cell, atIndex: 0)
        add(cell)
    }
    
    func addHeader (view: UIView) {
        let cell = MaterialCardCell (card: self)
        cell.backgroundColor = appeareance.headerBackgroundColor

        cell.addView(view)
        cell.h = max (cell.h, estimatedHeaderHeight)
        
        items.insert(cell, atIndex: 0)
        add(cell)
    }
    
    
    func addFooter (title: String) {
        let cell = MaterialCardCell (card: self)
        cell.backgroundColor = appeareance.headerBackgroundColor
        
        cell.addTitle(title)
        cell.h = max (cell.h, estimatedHeaderHeight)
        
        items.insert(cell, atIndex: items.count)
        add(cell)
    }
    
    func addFooter (view: UIView) {
        let cell = MaterialCardCell (card: self)
        cell.backgroundColor = appeareance.headerBackgroundColor
        
        cell.addView(view)
        cell.h = max (cell.h, estimatedHeaderHeight)
        
        items.insert(cell, atIndex: items.count)
        add(cell)
    }
    
    
    func addCell (text: String, action: (()->Void)? = nil) {
        let cell = MaterialCardCell (card: self)
        cell.backgroundColor = appeareance.cellBackgroundColor
        
        cell.addText(text)
        cell.h = max (cell.h, estimatedRowHeight)
        
        if let act = action {
            cell.addRipple(
                appeareance.rippleColor,
                duration: appeareance.rippleDuration,
                location: .TouchLocation,
                action: act)
        }
        
        items.append(cell)
        add(cell)
    }
    
    func addCell (view: UIView, action: (()->Void)? = nil) {
        let cell = MaterialCardCell (card: self)
        cell.backgroundColor = appeareance.cellBackgroundColor
        
        cell.addView(view)
        cell.h = max (cell.h, estimatedRowHeight)
        
        if let act = action {
            cell.addRipple(
                appeareance.rippleColor,
                duration: appeareance.rippleDuration,
                location: .TouchLocation,
                action: act)
        }
        
        items.append(cell)
        add(cell)
    }
    
    func addCell (cell: MaterialCardCell) {
        cell.backgroundColor = appeareance.cellBackgroundColor
        cell.h = max (cell.h, estimatedRowHeight)
        
        items.append(cell)
        add(cell)
    }
    
    
    private func add (cell: MaterialCardCell) {
        contentView.addSubview(cell)
        h += cell.h
        
        updateFrame()
    }
    
    
    
    // MARK: Remove Cell
    
    func removeCell (index: Int) {
        if index < items.count {
            let cell = items[index]
            removeCell(cell)
        }
    }
    
    func removeCell (cell: MaterialCardCell) {
        cell.removeFromSuperview()
        items.removeObject(cell)
        
        h -= cell.h
        updateFrame()
    }
}
