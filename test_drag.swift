import Foundation

// Math simulation of the drag logic
let snapUnit: Double = 20.0
var points = [(0.0, 0.0), (100.0, 0.0), (100.0, 50.0), (0.0, 50.0)]
var currentCenter = points[1]
var translation = (20.0, 10.0) // Drag point 1

let targetX = currentCenter.0 + translation.0
let targetY = currentCenter.1 + translation.1

let xAnchor = points[0] // Because points[0].0 != points[1].0 ? No, point 0 and 3 are xAnchors
let yAnchor = points[2]

let snappedX = xAnchor.0 + round((targetX - xAnchor.0) / snapUnit) * snapUnit
let snappedY = yAnchor.1 + round((targetY - yAnchor.1) / snapUnit) * snapUnit

print("snappedX: \(snappedX), snappedY: \(snappedY)")
print("actualDx: \(snappedX - currentCenter.0), actualDy: \(snappedY - currentCenter.1)")
