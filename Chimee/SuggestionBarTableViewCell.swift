import UIKit
class SuggestionBarTableViewCell: UITableViewCell {
    
    var mongolLabel = UIMongolSingleLineLabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        self.mongolLabel.translatesAutoresizingMaskIntoConstraints = false
        self.mongolLabel.centerText = false
        self.mongolLabel.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(mongolLabel)
        
        // Constraints
        let topConstraint = NSLayoutConstraint(item: mongolLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.TopMargin, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: mongolLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.BottomMargin, multiplier: 1.0, constant: 0)
        let horizontalCenterConstraint = NSLayoutConstraint(item: mongolLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.contentView.addConstraints([ topConstraint, bottomConstraint, horizontalCenterConstraint ])
    }
    
    override internal class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}