import UIKit

class DotView: UIControl {
    let mainColor: UIColor

    init(
        frame: CGRect,
        mainColor: UIColor = .black
    ) {
        self.mainColor = mainColor
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let dotPath = UIBezierPath(ovalIn: rect)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = dotPath.cgPath
        shapeLayer.fillColor = mainColor.cgColor
        layer.addSublayer(shapeLayer)
    }
}

public class PageDotsView: UIView {
    private var dots: [DotView] = []
    private var dotCount: Int
    private let currentDot: Int
    private let dotSize: CGFloat
    private let dotColor: UIColor
    private let currentDotColor: UIColor

    public init(
        count: Int,
        dotColor: UIColor = .gray,
        currentDotColor: UIColor = .red,
        dotSize: CGFloat = 7,
        currentDot: Int = 0,
        frame: CGRect
    ) {
        self.dotCount = count
        self.dotSize = dotSize
        self.currentDot = currentDot
        self.dotColor = dotColor
        self.currentDotColor = currentDotColor

        super.init(frame: frame)

        self.dots = setupViews(
            count: count,
            dotColor: dotColor,
            currentDotColor: currentDotColor,
            dotSize: dotSize
        )
        setupConstraints(dotSize: dotSize)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func shiftRight() throws -> PageDotsView {
        guard currentDot < dots.count - 1 else { throw DotsError.outOfBounds }
        return PageDotsView(
            count: self.dotCount,
            dotColor: self.dotColor,
            currentDotColor: self.currentDotColor,
            dotSize: self.dotSize,
            currentDot: self.currentDot + 1,
            frame: self.frame
        )
    }

    public func shiftLeft() throws -> PageDotsView {
        guard currentDot > 0 else { throw DotsError.outOfBounds }
        return PageDotsView(
            count: self.dotCount,
            dotColor: self.dotColor,
            currentDotColor: self.currentDotColor,
            dotSize: self.dotSize,
            currentDot: self.currentDot - 1,
            frame: self.frame
        )
    }

    public func moveTo(index: Int) throws -> PageDotsView {
        guard index < self.dotCount, index >= 0 else { throw DotsError.outOfBounds }
        return PageDotsView(
            count: self.dotCount,
            dotColor: self.dotColor,
            currentDotColor: self.currentDotColor,
            dotSize: self.dotSize,
            currentDot: index,
            frame: self.frame
        )
    }

    override public var intrinsicContentSize: CGSize {
        let width = Double(dots.count * (Int(dotSize) * 2) - Int(dotSize)) + 4
        let height = Double(dotSize) * 1.50
        return CGSize(width: width, height: height)
    }
}

private extension PageDotsView {
    func setupViews(
        count: Int,
        dotColor: UIColor,
        currentDotColor: UIColor,
        dotSize: CGFloat
    ) -> [DotView] {
        return (0..<count).map { index in
            let dot = generateDot(
                index: index,
                dotColor: dotColor,
                currentDotColor: currentDotColor,
                dotSize: dotSize
            )
            self.addSubview(dot)
            return dot
        }
    }

    func setupConstraints(dotSize: CGFloat) {
        var previousDot: DotView?

        let dotConstraints = dots.flatMap { (dot) -> [NSLayoutConstraint] in
            let constraints = [
                dot.heightAnchor.constraint(equalToConstant: dotSize),
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.leadingAnchor.constraint(equalTo: previousDot?.trailingAnchor ?? self.leadingAnchor, constant: previousDot==nil ? 2 : dotSize),
                dot.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ]

            previousDot = dot

            return constraints
        }

        NSLayoutConstraint.activate(dotConstraints)
    }

    func generateDot(
        index: Int,
        dotColor: UIColor,
        currentDotColor: UIColor,
        dotSize: CGFloat
    ) -> DotView {
        let frame = CGRect(x: 0, y: 0, width: dotSize, height: dotSize)
        let color = index == self.currentDot ? currentDotColor : dotColor
        let dot: DotView = DotView(frame: frame, mainColor: color)

        dot.accessibilityIdentifier = "DotAt\(index)"

        return dot
    }
}