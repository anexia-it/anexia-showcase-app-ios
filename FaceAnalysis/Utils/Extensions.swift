//
//  Extensions.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 07.11.18.
//  Copyright © 2019 Anexia. All rights reserved.
//

import UIKit

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}
extension UIImage.Orientation {
    init(_ cgOrientation: CGImagePropertyOrientation) {
        switch cgOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}

extension UIViewController {
    func showToast(message : String) {
        DispatchQueue.main.async {
            let font = UIFont.systemFont(ofSize: 12.0)
            let width = message.width(withConstrainedHeight: 45, font: font)+20
            let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - width/2, y: self.view.safeAreaInsets.top+16, width: width, height: 38))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center;
            toastLabel.font = font
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
    }
}


extension UIView {
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }

    func asImage() -> UIImage? {
        UIGraphicsBeginImageContext(self.frame.size)
        self.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = image, let cgImage = image.cgImage {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

extension UIView {
    func flipAnimation() {
        UIView.transition(with: self, duration: 0.5,
                          options: [.transitionFlipFromRight,
                                    .showHideTransitionViews],
                          animations: {
                            self.alpha = 0
                            self.alpha = 1
        }) { _ in
            self.isHidden = true
            self.isHidden = false
            self.isUserInteractionEnabled = false
            self.isUserInteractionEnabled = true
        }
    }
    
    func flipAnimationCurlUp() {
        UIView.transition(with: self, duration: 0.5,
                          options: [.transitionCurlUp,
                                    .showHideTransitionViews],
                          animations: {
                            self.alpha = 0
                            self.alpha = 1
        }) { _ in
            self.isHidden = true
            self.isHidden = false
            self.isUserInteractionEnabled = false
            self.isUserInteractionEnabled = true
        }
    }
    
    func stopRotateView() {
        self.layer.removeAllAnimations()
        UIView.animate(
            withDuration: 1.0,
            delay: 0.5,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 10,
            options: .curveLinear,
            animations: {
                self.transform = CGAffineTransform.identity
        },
            completion: nil
        )
    }
    
    func rotateView() {
        let fullRotation = CABasicAnimation(keyPath: "transform.rotation")
        fullRotation.fromValue = NSNumber(floatLiteral: 0)
        fullRotation.toValue = NSNumber(floatLiteral: Double(CGFloat.pi * 2))
        fullRotation.duration = 1
        fullRotation.repeatCount = Float.infinity
        self.layer.add(fullRotation, forKey: "360")
    }
}


extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
