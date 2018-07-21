import UIKit

// https://gist.github.com/FredrikSjoberg/ced4ad5103863ab95dc8b49bdfd99eb2
extension CGPoint : Hashable {
    public var hashValue: Int {
        // iOS Swift Game Development Cookbook
        // https://books.google.se/books?id=QQY_CQAAQBAJ&pg=PA304&lpg=PA304&dq=swift+CGpoint+hashvalue&source=bl&ots=1hp2Fph274&sig=LvT36RXAmNcr8Ethwrmpt1ynMjY&hl=sv&sa=X&ved=0CCoQ6AEwAWoVChMIu9mc4IrnxgIVxXxyCh3CSwSU#v=onepage&q=swift%20CGpoint%20hashvalue&f=false
        return x.hashValue << 32 ^ y.hashValue
    }
    
    static func ==(lhs: CGPoint, rhs: CGPoint) -> Bool {
        return MathHelperImplementation.sharedInstance.calculateDistanceBetween(point1: lhs, point2: rhs) < epsilon
    }
}
