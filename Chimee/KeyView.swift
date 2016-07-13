import UIKit

@IBDesignable
class KeyView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    @IBInspectable var primaryLetter = ""
    
    @IBInspectable var secondaryLetter = ""
    
    

}
