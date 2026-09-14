extension LineView {
    func getCircleIntersections(center1: CGPoint, radius1: CGFloat, center2: CGPoint, radius2: CGFloat) -> [CGPoint] {
        let dx = center2.x - center1.x
        let dy = center2.y - center1.y
        let d = hypot(dx, dy)
        if d > radius1 + radius2 || d < abs(radius1 - radius2) || d == 0 { return [] }
        let a = (radius1 * radius1 - radius2 * radius2 + d * d) / (2 * d)
        let h = sqrt(max(0, radius1 * radius1 - a * a))
        let p2x = center1.x + a * (center2.x - center1.x) / d
        let p2y = center1.y + a * (center2.y - center1.y) / d
        let p3x1 = p2x + h * (center2.y - center1.y) / d
        let p3y1 = p2y - h * (center2.x - center1.x) / d
        let p3x2 = p2x - h * (center2.y - center1.y) / d
        let p3y2 = p2y + h * (center2.x - center1.x) / d
        return [CGPoint(x: p3x1, y: p3y1), CGPoint(x: p3x2, y: p3y2)]
    }
}
