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
        self.mongolLabel.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(mongolLabel)
        
        // Constraints
        let topConstraint = NSLayoutConstraint(item: mongolLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.topMargin, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: mongolLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1.0, constant: 0)
        let horizontalCenterConstraint = NSLayoutConstraint(item: mongolLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        self.contentView.addConstraints([ topConstraint, bottomConstraint, horizontalCenterConstraint ])
    }
    
    override internal class var requiresConstraintBasedLayout : Bool {
        return true
    }
}
