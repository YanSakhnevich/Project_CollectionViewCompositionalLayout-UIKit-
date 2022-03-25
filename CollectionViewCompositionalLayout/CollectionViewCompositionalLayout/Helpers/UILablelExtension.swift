import UIKit

class UILabelPadding: UILabel {

    let padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let oroginContentSize = super.intrinsicContentSize
        return CGSize(width: oroginContentSize.width, height: oroginContentSize.height+20)
    }
}
