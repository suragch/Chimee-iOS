// This keyboard key has six text string locations for vertical Mongolian script. These are for glyph variations that can be selected with the three FVS (Free Variation Selector) Unicode character. The top three positions are for initial/medial variations and the bottom three are for isolate/final variations.


// This keyboard key has two text string locations for vertical Mongolian script, one centered and one in the bottom right.


import UIKit

@IBDesignable
class KeyboardFvsKey: KeyboardKey {
    
    private let fvs1TopLayer = KeyboardKeyTextLayer()
    private let fvs2TopLayer = KeyboardKeyTextLayer()
    private let fvs3TopLayer = KeyboardKeyTextLayer()
    private let horizonalDividerLayer = CALayer()
    private let fvs1BottomLayer = KeyboardKeyTextLayer()
    private let fvs2BottomLayer = KeyboardKeyTextLayer()
    private let fvs3BottomLayer = KeyboardKeyTextLayer()
    private let popupLayerBackground = CAShapeLayer()
    private let highlightLayer = CALayer()
    private var oldFrame = CGRectZero
    
    
    let mongolFontName = "ChimeeWhiteMirrored"
    var useMirroredFont = true
    let popupFontSize: CGFloat = 24
    let popupHeight: CGFloat = 100
    var popupWidth: CGFloat = 0 // to be updated later
    private var touchDownPoint = CGPointZero
    private var currentSelection = CurrentSelection.FVS1
    let fvs1 = "\u{180b}"
    let fvs2 = "\u{180c}"
    let fvs3 = "\u{180d}"
    private var numberOfFvsChoices = 0
    
    private enum CurrentSelection {
        case OutOfBoundsLeft
        case FVS1
        case FVS2
        case FVS3
        case OutOfBoundsRight
    }
    
    // MARK: Primary input value
    
    var primaryString: String = "A"
    
    private var fvs1TopString = ""
    private var fvs2TopString = ""
    private var fvs3TopString = ""
    private var fvs1BottomString = ""
    private var fvs2BottomString = ""
    private var fvs3BottomString = ""
    
    var fontSize: CGFloat = 12 {
        didSet {
            updateTextFrames()
        }
    }
    //var dividerColor: UIColor = UIColor.blackColor() // TODO: update text
    
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override var frame: CGRect {
        didSet {
            // only update frames if non-zero and changed
            if frame != CGRectZero && frame != oldFrame {
                updateTextFrames()
                oldFrame = frame
            }
        }
    }
    
    func setup() {
        
        // Popup layer
        popupLayerBackground.contentsScale = UIScreen.mainScreen().scale
        //popupLayerBackground.path = popupMenuPath(3).CGPath
        popupLayerBackground.strokeColor = self.borderColor.CGColor
        popupLayerBackground.fillColor = self.fillColor.CGColor
        popupLayerBackground.lineWidth = 0.5
        popupLayerBackground.hidden = true
        layer.addSublayer(popupLayerBackground)
        
        //
        // highlight layer
        highlightLayer.contentsScale = UIScreen.mainScreen().scale
        highlightLayer.backgroundColor = UIColor.grayColor().CGColor
        highlightLayer.cornerRadius = 4
        layer.addSublayer(highlightLayer)
        
        // FVS1 Top Layer
        fvs1TopLayer.useMirroredFont = useMirroredFont
        fvs1TopLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(fvs1TopLayer)
        
        // FVS2 Top Layer
        fvs2TopLayer.useMirroredFont = useMirroredFont
        fvs2TopLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(fvs2TopLayer)
        
        // FVS3 Top Layer
        fvs3TopLayer.useMirroredFont = useMirroredFont
        fvs3TopLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(fvs3TopLayer)
        
        // Horizonal divider layer
        horizonalDividerLayer.contentsScale = UIScreen.mainScreen().scale
        horizonalDividerLayer.backgroundColor = borderColor.CGColor
        layer.addSublayer(horizonalDividerLayer)
        
        // FVS1 Bottom Layer
        fvs1BottomLayer.useMirroredFont = useMirroredFont
        fvs1BottomLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(fvs1BottomLayer)
        
        // FVS2 Bottom Layer
        fvs2BottomLayer.useMirroredFont = useMirroredFont
        fvs2BottomLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(fvs2BottomLayer)
        
        // FVS3 Bottom Layer
        fvs3BottomLayer.useMirroredFont = useMirroredFont
        fvs3BottomLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(fvs3BottomLayer)
        
        
        
    }
    
    func updateTextFrames() {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let myAttribute = [ NSFontAttributeName: UIFont(name: mongolFontName, size: fontSize )! ]
        
        // highlight layer
        highlightLayer.frame = CGRectZero
        
        // FVS1 top
        var attrString = NSMutableAttributedString(string: fvs1TopString, attributes: myAttribute )
        var size = dimensionsForAttributedString(attrString)
        var x = (layer.bounds.width - 3*size.height) / 6 + padding
        var y = (layer.bounds.height - 2*size.width) / 4 + padding
        fvs1TopLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        fvs1TopLayer.string = attrString
        
        // FVS 2 top
        attrString = NSMutableAttributedString(string: fvs2TopString, attributes: myAttribute )
        size = dimensionsForAttributedString(attrString)
        x = (layer.bounds.width - size.height) / 2
        y = (layer.bounds.height - 2*size.width) / 4 + padding
        fvs2TopLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        fvs2TopLayer.string = attrString
        
        // FVS 3 top
        attrString = NSMutableAttributedString(string: fvs3TopString, attributes: myAttribute )
        size = dimensionsForAttributedString(attrString)
        x = (5*layer.bounds.width - 3*size.height) / 6 - padding
        y = (layer.bounds.height - 2*size.width) / 4 + padding
        fvs3TopLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        fvs3TopLayer.string = attrString
        
        // Horizontal divider 
        x = padding
        y = layer.bounds.height / 2
        horizonalDividerLayer.frame = CGRect(x: x, y: y, width: layer.bounds.width - 2*padding, height: 0.5)
        
        
        // FVS 1 bottom
        attrString = NSMutableAttributedString(string: fvs1BottomString, attributes: myAttribute )
        size = dimensionsForAttributedString(attrString)
        x = (layer.bounds.width - 3*size.height) / 6 + padding
        y = (3*layer.bounds.height - 2*size.width) / 4 - padding
        fvs1BottomLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        fvs1BottomLayer.string = attrString
        
        // FVS 2 bottom
        attrString = NSMutableAttributedString(string: fvs2BottomString, attributes: myAttribute )
        size = dimensionsForAttributedString(attrString)
        x = (layer.bounds.width - size.height) / 2
        y = (3*layer.bounds.height - 2*size.width) / 4 - padding
        fvs2BottomLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        fvs2BottomLayer.string = attrString
        
        // FVS 3 bottom
        attrString = NSMutableAttributedString(string: fvs3BottomString, attributes: myAttribute )
        size = dimensionsForAttributedString(attrString)
        x = (5*layer.bounds.width - 3*size.height) / 6 - padding
        y = (3*layer.bounds.height - 2*size.width) / 4 - padding
        fvs3BottomLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        fvs3BottomLayer.string = attrString
        
        CATransaction.commit()
    }
    
    func updateTextFramesForPopup() {
        
        let myAttribute = [ NSFontAttributeName: UIFont(name: mongolFontName, size: popupFontSize )! ]
        
        // hightlight layer
        highlightLayer.frame = CGRect(x: 2*padding, y: -popupHeight + self.cornerRadius, width: (popupWidth - 2*padding)/3, height: popupHeight - 2*self.cornerRadius)
        currentSelection = CurrentSelection.FVS1
        
        // FVS1 top
        var attrString = NSMutableAttributedString(string: fvs1TopString, attributes: myAttribute )
        var size = dimensionsForAttributedString(attrString)
        var x = popupWidth/6 - size.height/2 + padding
        var y = -3/4*popupHeight - size.width/2 + padding
        fvs1TopLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        fvs1TopLayer.string = attrString
        
        // FVS 2 top
        attrString = NSMutableAttributedString(string: fvs2TopString, attributes: myAttribute )
        size = dimensionsForAttributedString(attrString)
        x = popupWidth/2 - size.height/2 + padding
        y = -3/4*popupHeight - size.width/2 + padding
        fvs2TopLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        fvs2TopLayer.string = attrString
        
        // FVS 3 top
        attrString = NSMutableAttributedString(string: fvs3TopString, attributes: myAttribute )
        size = dimensionsForAttributedString(attrString)
        x = 5/6*popupWidth - size.height/2 + padding
        y = -3/4*popupHeight - size.width/2 + padding
        fvs3TopLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        fvs3TopLayer.string = attrString
        
        // Horizontal divider
        x = 2*padding
        y = -popupHeight / 2
        horizonalDividerLayer.frame = CGRect(x: x, y: y, width: popupWidth - 2*padding, height: 0.5)
        
        
        // FVS 1 bottom
        attrString = NSMutableAttributedString(string: fvs1BottomString, attributes: myAttribute )
        size = dimensionsForAttributedString(attrString)
        x = popupWidth/6 - size.height/2 + padding
        y = -1/4*popupHeight - size.width/2 + padding
        fvs1BottomLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        fvs1BottomLayer.string = attrString
        
        // FVS 2 bottom
        attrString = NSMutableAttributedString(string: fvs2BottomString, attributes: myAttribute )
        size = dimensionsForAttributedString(attrString)
        x = popupWidth/2 - size.height/2 + padding
        y = -1/4*popupHeight - size.width/2 + padding
        fvs2BottomLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        fvs2BottomLayer.string = attrString
        
        // FVS 3 bottom
        attrString = NSMutableAttributedString(string: fvs3BottomString, attributes: myAttribute )
        size = dimensionsForAttributedString(attrString)
        x = 5/6*popupWidth - size.height/2 + padding
        y = -1/4*popupHeight - size.width/2 + padding
        fvs3BottomLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        fvs3BottomLayer.string = attrString
    }
    
    func setStrings(fvs1Top: String, fvs2Top: String, fvs3Top: String, fvs1Bottom: String, fvs2Bottom: String, fvs3Bottom: String) {
        
        // set the number of fvs choices available 
        // (assume that blank lower fvs means blank upper fvs)
        if fvs1Top == "" && fvs1Bottom == "" {
            numberOfFvsChoices = 0
        } else if fvs2Top == "" && fvs2Bottom == "" {
            numberOfFvsChoices = 1
        } else if fvs3Top == "" && fvs3Bottom == "" {
            numberOfFvsChoices = 2
        } else {
            numberOfFvsChoices = 3
        }
        
        fvs1TopString = fvs1Top
        fvs2TopString = fvs2Top
        fvs3TopString = fvs3Top
        fvs1BottomString = fvs1Bottom
        fvs2BottomString = fvs2Bottom
        fvs3BottomString = fvs3Bottom
        
        updateTextFrames()
    }
    
    // MARK: - touch events
    
    override func addLongPressGestureRecognizer() {
        
        // don't let super class add long press gesture recognizer
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        
        // disable key if no fvs choices available
        if numberOfFvsChoices == 0 {
            return false
        }
        super.beginTrackingWithTouch(touch, withEvent: event)
        
        // don's show popup menu if only fvs1 available
        if numberOfFvsChoices == 1 {
            return true
        }
        
        touchDownPoint = touch.locationInView(self)
        
        // popup menu
        popupLayerBackground.path = popupMenuPath().CGPath
        updateTextFramesForPopup()
        popupLayerBackground.hidden = false
        
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        
        // don's update popup menu if only fvs1 available
        if numberOfFvsChoices == 1 {
            return true
        }

        let touchPoint = touch.locationInView(self)
        let x = touchPoint.x
        let unit = (popupWidth - 2*padding)/3
        
        // set highlight background frame
        if x < 0 {
            if currentSelection != CurrentSelection.OutOfBoundsLeft {
                highlightLayer.frame = CGRect(x: 2*padding, y: -popupHeight + self.cornerRadius, width: 0, height: popupHeight - 2*self.cornerRadius)
                currentSelection = CurrentSelection.OutOfBoundsLeft
            }
        } else if x > 0 && x <= unit {
            if currentSelection != CurrentSelection.FVS1 {
                highlightLayer.frame = CGRect(x: 2*padding, y: -popupHeight + self.cornerRadius, width: (popupWidth - 2*padding)/3, height: popupHeight - 2*self.cornerRadius)
                currentSelection = CurrentSelection.FVS1
            }
        } else if x > unit && x <= 2*unit {
            if currentSelection != CurrentSelection.FVS2 {
                highlightLayer.frame = CGRect(x: 2*padding + (popupWidth - 2*padding)/3, y: -popupHeight + self.cornerRadius, width: (popupWidth - 2*padding)/3, height: popupHeight - 2*self.cornerRadius)
                currentSelection = CurrentSelection.FVS2
            }
        } else if x > 2*unit && x <= 3*unit && numberOfFvsChoices != 2 {
            if currentSelection != CurrentSelection.FVS3 {
                highlightLayer.frame = CGRect(x: 2*padding + 2*(popupWidth - 2*padding)/3, y: -popupHeight + self.cornerRadius, width: (popupWidth - 2*padding)/3, height: popupHeight - 2*self.cornerRadius)
                currentSelection = CurrentSelection.FVS3
            }
        } else if x > 3*unit {
            if currentSelection != CurrentSelection.OutOfBoundsRight {
                highlightLayer.frame = CGRect(x: 2*padding + 3*(popupWidth - 2*padding)/3, y: -popupHeight + self.cornerRadius, width: 0, height: popupHeight - 2*self.cornerRadius)
                currentSelection = CurrentSelection.OutOfBoundsRight
            }
        }
        
        return true
        
    }
    
    // tap event (do when finger lifted)
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        super.endTrackingWithTouch(touch, withEvent: event)
        
        // return early if only fvs1 is available
        if numberOfFvsChoices == 1 {
            delegate?.keyTextEntered(fvs1)
            return
        }
        
        popupLayerBackground.hidden = true
        updateTextFrames()
        
        switch currentSelection {
        case CurrentSelection.FVS1:
            delegate?.keyTextEntered(fvs1)
        case CurrentSelection.FVS2:
            delegate?.keyTextEntered(fvs2)
        case CurrentSelection.FVS3:
            delegate?.keyTextEntered(fvs3)
        default:
            break
        }
        
        
    }
    
    func dimensionsForAttributedString(attrString: NSAttributedString) -> CGSize {
        
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var width: CGFloat = 0
        let line: CTLineRef = CTLineCreateWithAttributedString(attrString)
        width = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, nil))
        
        // make width an even integer for better graphics rendering
        width = ceil(width)
        if Int(width)%2 == 1 {
            width += 1.0
        }
        
        return CGSize(width: width, height: ceil(ascent+descent))
    }
    
    // MARK: - Path
    
    func popupMenuPath() -> UIBezierPath {
        
        //  ------------------
        // |                  |
        // |                  |
        // |   popup area     |
        // |                  |
        // |                  |
        // |                  |
        // *      ------------
        // | key |
        // |     |
        //  -----
        //
        // * starting point close to (0,0)
        // working clockwise
        
        //let numberOfItems = CGFloat(numberOfItems)
        popupWidth = 2*self.bounds.width
        //let contentHeight = CGFloat(100)
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        
        // create a new path
        let path = UIBezierPath()
        
        // starting point for the path (on left side)
        x = padding
        path.moveToPoint(CGPoint(x: x, y: y))
        
        // top-left corner
        x = x + self.cornerRadius
        y = -padding - popupHeight + self.cornerRadius
        path.addArcWithCenter(
            CGPoint(x: x, y: y),
            radius: self.cornerRadius,
            startAngle: CGFloat(M_PI), // straight left
            endAngle: CGFloat(3*M_PI_2), // straight up
            clockwise: true)
        
        // top-right corner
        x = x - 2*self.cornerRadius +  popupWidth
        path.addArcWithCenter(
            CGPoint(x: x, y: y),
            radius: self.cornerRadius,
            startAngle: CGFloat(3*M_PI_2), // straight up
            endAngle: CGFloat(0), // straight right
            clockwise: true)
        
        // mid-right corner
        y = -padding - self.cornerRadius
        path.addArcWithCenter(
            CGPoint(x: x, y: y),
            radius: self.cornerRadius,
            startAngle: CGFloat(0), // straight right
            endAngle: CGFloat(M_PI_2), // straight down
            clockwise: true)
        
        // mid-bottom upper corner
        x = bounds.width - padding + self.cornerRadius
        y = -padding + self.cornerRadius
        path.addArcWithCenter(
            CGPoint(x: x, y: y),
            radius: self.cornerRadius,
            startAngle: CGFloat(3*M_PI_2), // straight up
            endAngle: CGFloat(M_PI), // straight left
            clockwise: false)
        
        // mid-bottom lower corner
        x = x - 2*self.cornerRadius
        y = bounds.height - padding - self.cornerRadius
        path.addArcWithCenter(
            CGPoint(x: x, y: y),
            radius: self.cornerRadius,
            startAngle: CGFloat(0), // straight right
            endAngle: CGFloat(M_PI_2), // straight down
            clockwise: true)
        
        // bottom-left corner
        x = padding + self.cornerRadius
        path.addArcWithCenter(
            CGPoint(x: x, y: y),
            radius: self.cornerRadius,
            startAngle: CGFloat(M_PI_2), // straight down
            endAngle: CGFloat(M_PI), // straight left
            clockwise: true)
        
        
        path.closePath() // draws the final line to close the path
        
        return path
    }
}

