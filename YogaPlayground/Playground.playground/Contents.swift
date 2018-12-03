import yoga

let node = YGNodeNew()!

// Function to measure size of node (think: UIView.intrinsicContentSize)
func measureFunction(node: YGNodeRef?, width: Float, widthMode: YGMeasureMode, height: Float, heightMode: YGMeasureMode) -> YGSize {
    return YGSize(width: 200, height: 300)
}

YGNodeSetMeasureFunc(node, measureFunction)

YGNodeCalculateLayout(node, YGUndefined, YGUndefined, .LTR)

YGNodeLayoutGetWidth(node)
YGNodeLayoutGetHeight(node)













//// Utilities to convert between Yoga and CGGeometry types
//
//import UIKit
//
//extension YGSize {
//    init(_ cgSize: CGSize) {
//        self.init(width: Float(cgSize.width), height: Float(cgSize.height))
//    }
//}
//
//extension CGSize {
//    init(width: Float, height: Float) {
//        self.init(width: CGFloat(width), height: CGFloat(height))
//    }
//
//    init(_ ygSize: YGSize) {
//        self.init(width: ygSize.width, height: ygSize.height)
//    }
//}
//
//extension CGRect {
//    init(x: Float, y: Float, width: Float, height: Float) {
//        self.init(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height))
//    }
//}



























//// Attempt: "dynamic" factory function


//
//extension YGNodeRef {
//    static func makeBox(size: YGSize) -> YGNodeRef {
//        func measure(node: YGNodeRef?, width: Float, widthMode: YGMeasureMode,
//                     height: Float, heightMode: YGMeasureMode) -> YGSize {
//            return size
//        }
//
//        let node = YGNodeNew()!
//        YGNodeSetMeasureFunc(node, measure)
//        return node
//    }
//}











//// A working "dynamic" factory function
//
//extension YGNodeRef {
//    typealias MeasureFunction = (Float, YGMeasureMode, Float, YGMeasureMode) -> YGSize
//
//    private final class Box<T> {
//        let value: T
//        init(_ value: T) {
//            self.value = value
//        }
//    }
//
//    static func makeNode(measure: @escaping MeasureFunction) -> YGNodeRef {
//        let node = YGNodeNew()!
//
//        let box = Box<MeasureFunction>(measure)
//        YGNodeSetContext(node, UnsafeMutableRawPointer(Unmanaged.passRetained(box).toOpaque())) // leaks
//
//        func measureNode(_ node: YGNodeRef!, width: Float, widthMode: YGMeasureMode, height: Float, heightMode: YGMeasureMode) -> YGSize {
//            guard let ctxt = YGNodeGetContext(node) else { fatalError() }
//            let box = Unmanaged<Box<MeasureFunction>>.fromOpaque(ctxt).takeUnretainedValue()
//            return box.value(width, widthMode, height, heightMode)
//        }
//        YGNodeSetMeasureFunc(node, measureNode)
//
//        return node
//    }
//}












//// makeSizedBox()
//
//extension YGNodeRef {
//    static func makeSizedBox(size: YGSize) -> YGNodeRef {
//        return makeNode { _, _, _, _ in size }
//    }
//}
//
//let sizedBox = YGNodeRef.makeSizedBox(size: YGSize(width: 30, height: 40))
//
//YGNodeCalculateLayout(sizedBox, YGUndefined, YGUndefined, .LTR)
//
//YGNodeLayoutGetWidth(sizedBox)
//YGNodeLayoutGetHeight(sizedBox)
//











//// makeLabel()
//
//extension YGNodeRef {
//    static func makeLabel(text: String) -> YGNodeRef {
//        let node = makeNode { width, _, height, _ in
//            let size = text.boundingRect(with: CGSize(width: width, height: height), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: nil, context: nil).size
//            return YGSize(size)
//        }
//        YGNodeSetNodeType(node, .text)
//        return node
//    }
//}
//
//let label = YGNodeRef.makeLabel(text: "Hello World!")
//
//YGNodeCalculateLayout(label, YGUndefined, YGUndefined, .LTR)
//
//YGNodeLayoutGetWidth(label)
//YGNodeLayoutGetHeight(label)












//// sizeThatFits()
//
//extension YGNodeRef {
//    func sizeThatFits(width: Float, height: Float) -> YGSize {
//        YGNodeCalculateLayout(self, width, height, .LTR)
//        return YGSize(width: YGNodeLayoutGetWidth(self), height: YGNodeLayoutGetHeight(self))
//    }
//}
//
//let label2 = YGNodeRef.makeLabel(text: "Hello World!")
//
//label2.sizeThatFits(width: YGUndefined, height: YGUndefined)












//// Nodes containing nodes
//
//let nodeA = YGNodeRef.makeSizedBox(size: YGSize(width: 100, height: 100))
//let nodeB = YGNodeRef.makeSizedBox(size: YGSize(width: 150, height: 150))
//let nodeC = YGNodeRef.makeSizedBox(size: YGSize(width: 200, height: 200))
//
//let container1 = YGNodeNew()!
//
//YGNodeInsertChild(container1, nodeA, 0)
//YGNodeInsertChild(container1, nodeB, 1)
//YGNodeInsertChild(container1, nodeC, 2)
//
//container1.sizeThatFits(width: YGUndefined, height: YGUndefined)











//// Printing the tree of nodes
//
//YGNodeCalculateLayout(container1, YGUndefined, YGUndefined, .LTR)
//
//YGNodePrint(container1, YGPrintOptions(rawValue: YGPrintOptions.layout.rawValue|YGPrintOptions.children.rawValue|YGPrintOptions.style.rawValue)!)










//// YogaView: drawing the frames of nodes (ONLY for visualization)
//
//final class YogaView: UIView {
//    let node: YGNodeRef
//
//    init(node: YGNodeRef) {
//        self.node = node
//        let size = CGSize(node.sizeThatFits(width: YGUndefined, height: YGUndefined))
//        super.init(frame: CGRect(origin: .zero, size: size))
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        YGNodeCalculateLayout(node, Float(bounds.width), Float(bounds.height), .LTR)
//        setNeedsDisplay()
//    }
//
//    override func draw(_ rect: CGRect) {
//        let context = UIGraphicsGetCurrentContext()!
//        context.setFillColor(UIColor.yellow.cgColor)
//        context.fill(rect)
//        node.draw(in: context)
//    }
//}
//
//extension YGNodeRef {
//
//    var rect: CGRect {
//        let x = YGNodeLayoutGetLeft(self)
//        let y = YGNodeLayoutGetTop(self)
//        let width = YGNodeLayoutGetWidth(self)
//        let height = YGNodeLayoutGetHeight(self)
//        return CGRect(x: x, y: y, width: width, height: height)
//    }
//
//    func draw(in context: CGContext, offset: CGPoint = .zero) {
//        context.saveGState()
//        defer { context.restoreGState() }
//
//        let absoluteRect = rect.offsetBy(dx: offset.x, dy: offset.y)
//
//        let nChildren = YGNodeGetChildCount(self)
//        if nChildren == 0 {
//            context.setFillColor(UIColor.magenta.cgColor)
//            context.setStrokeColor(UIColor.green.cgColor)
//            context.fill(absoluteRect)
//            context.stroke(absoluteRect, width: 1)
//        } else {
//            (0..<nChildren).forEach {
//                let child = YGNodeGetChild(self, $0)!
//                child.draw(in: context, offset: absoluteRect.origin)
//            }
//        }
//    }
//}












//// Drawing container1
//
//import PlaygroundSupport
//
////YGNodeStyleSetAlignItems(container1, .flexStart)
//let view = YogaView(node: container1)
//PlaygroundPage.current.liveView = view










// Wrapping
























//let words = YGNodeNew()!
//"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.".components(separatedBy: .whitespaces).map { YGNodeRef.makeLabel(text: $0) }.enumerated().forEach { pair in
//    let (offset, node) = pair
//    YGNodeInsertChild(words, node, UInt32(offset))
//    YGNodeStyleSetMargin(node, .all, 5)
//}
//YGNodeStyleSetAlignItems(words, .flexStart)
//YGNodeStyleSetFlexDirection(words, .row)
//YGNodeStyleSetFlexWrap(words, .wrap)
//let wordsView = YogaView(node: words)
//wordsView.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 800))
//PlaygroundPage.current.liveView = wordsView
