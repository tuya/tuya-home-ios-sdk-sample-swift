//
//  UIView+Extension.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

extension UIView {
    var height: CGFloat {
        frame.size.height
    }

    var width: CGFloat {
        frame.size.width
    }

    var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    var borderWidth: CGFloat {
        get {
            layer.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }

    var borderColor: UIColor? {
        get {
            guard let borderColor = layer.borderColor else { return nil }
            return UIColor(cgColor: borderColor)
        } set {
            layer.borderColor = newValue?.cgColor
        }
    }

    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }

    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }
}

extension UIView {
    convenience init(backgroundColor: UIColor) {
        self.init()
        self.backgroundColor = backgroundColor
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        setBackgroundImage(.init(demo_withColor: color), for: state)
    }
}

extension UIImage {
    fileprivate convenience init?(demo_withColor color: UIColor) {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        color.setFill()
        UIRectFill(.init(origin: .zero, size: size))
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}

extension UIColor {
    convenience init(demo_withHex hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let b = CGFloat((hex & 0x0000FF) >> 0) / 255.0
        self.init(displayP3Red: r, green: g, blue: b, alpha: alpha)
    }
}
