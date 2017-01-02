
import UIKit

@IBDesignable class UIMongolTableView: UIView {
    
    // MARK:- Unique to TableView
    
    // ********* Unique to TableView *********
    fileprivate var view = UITableView()
    fileprivate let rotationView = UIView()
    fileprivate var userInteractionEnabledForSubviews = true
    
    // read only refernce to the underlying tableview
    var tableView: UITableView {
        get {
            return view
        }
    }
    
    var tableFooterView: UIView? {
        
        get {
            return view.tableFooterView
        }
        set {
            view.tableFooterView = newValue
        }
        
    }
    
    func setup() {
        // do any setup necessary
        
        self.addSubview(rotationView)
        rotationView.addSubview(view)
        
        view.backgroundColor = self.backgroundColor
        view.layoutMargins = UIEdgeInsets.zero
        view.separatorInset = UIEdgeInsets.zero
    }
    
    // FIXME: @IBOutlet still can't be set in IB
    @IBOutlet weak var delegate: UITableViewDelegate? {
        get {
            return view.delegate
        }
        set {
            view.delegate = newValue
        }
    }
    
    // FIXME: @IBOutlet still can't be set in IB
    @IBOutlet weak var dataSource: UITableViewDataSource? {
        get {
            return view.dataSource
        }
        set {
            view.dataSource = newValue
        }
    }
    
    @IBInspectable var scrollEnabled: Bool {
        get {
            return view.isScrollEnabled
        }
        set {
            view.isScrollEnabled = newValue
        }
    }
    
    
    func scrollToRowAtIndexPath(_ indexPath: IndexPath, atScrollPosition: UITableViewScrollPosition, animated: Bool) {
        view.scrollToRow(at: indexPath, at: atScrollPosition, animated: animated)
    }
    
    func registerClass(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        view.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func dequeueReusableCellWithIdentifier(_ identifier: String) -> UITableViewCell? {
        return view.dequeueReusableCell(withIdentifier: identifier)
    }
    
    func reloadData() {
        view.reloadData()
    }
    
    func insertRowsAtIndexPaths(_ indexPaths: [IndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        
        view.insertRows(at: indexPaths, with: animation)
        
        
    }
    
    func deleteRowsAtIndexPaths(_ indexPaths: [IndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        
        view.deleteRows(at: indexPaths, with: animation)
    }
    
    
    
    
    // MARK:- General code for Mongol views
    
    // *******************************************
    // ****** General code for Mongol views ******
    // *******************************************
    
    // This method gets called if you create the view in the Interface Builder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // This method gets called if you create the view in code
    override init(frame: CGRect){
        super.init(frame: frame)
        self.setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rotationView.transform = CGAffineTransform.identity
        rotationView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: self.bounds.height, height: self.bounds.width))
        rotationView.transform = translateRotateFlip()
        
        view.frame = rotationView.bounds
        
    }
    
    func translateRotateFlip() -> CGAffineTransform {
        
        var transform = CGAffineTransform.identity
        
        // translate to new center
        transform = transform.translatedBy(x: (self.bounds.width / 2)-(self.bounds.height / 2), y: (self.bounds.height / 2)-(self.bounds.width / 2))
        // rotate counterclockwise around center
        transform = transform.rotated(by: CGFloat(-M_PI_2))
        // flip vertically
        transform = transform.scaledBy(x: -1, y: 1)
        
        return transform
    }
}
