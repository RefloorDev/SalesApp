import Foundation

struct CGPoint {
    var x: CGFloat
    var y: CGFloat
}

func halfPoint1D(p0: CGFloat, p2: CGFloat, control: CGFloat) -> CGFloat {
    return 2 * control - p0 / 2 - p2 / 2
}

let p0 = CGPoint(x: 0, y: 0)
let p2 = CGPoint(x: 100, y: 0)
let midilePoint = CGPoint(x: 50, y: 50)

let p1 = CGPoint(x: halfPoint1D(p0: p0.x, p2: p2.x, control: midilePoint.x),
                 y: halfPoint1D(p0: p0.y, p2: p2.y, control: midilePoint.y))

print("p0: \(p0)")
print("p2: \(p2)")
print("mid: \(midilePoint)")
print("p1 (control): \(p1)")
