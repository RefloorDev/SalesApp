//
//  SubSqureView.swift
//  Refloor
//
//  Created by sbek on 23/04/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SubSqureView: UIView {
    
    var lastLocation = CGPoint(x: 0, y: 0)
    var custom_width: CGFloat = 0
    var custom_hight: CGFloat  = 0
    var addViewHeight : String = "0"
    var transitionHeightId : Int = 0
    var tooltipView: OpeningTooltipView?
    var object:OpeningCustomObject? {
        didSet {
            updateTooltipText()
        }
    }
    var getSize:CGFloat{
        return self.isVertical ?  custom_hight : custom_width
    }
    var customDelegate:CustomViewDelegate?
    var isMoved = true
    var color:UIColor = .red
    let layerSharae:CAShapeLayer = CAShapeLayer()
    let dashedLayer:CAShapeLayer = CAShapeLayer()
    var isVertical = false
    
    init(frame: CGRect, isVertical:Bool,color:UIColor) {
        let fixedThickness: CGFloat = 20.0
        let variableLength = max(frame.size.width, frame.size.height)
        let adjustedFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: variableLength, height: fixedThickness)
        super.init(frame: adjustedFrame)
        
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
        self.gestureRecognizers = [panRecognizer]
        
        self.color = color
        self.isVertical = isVertical
        
        layerSharae.path = getSolidPath().cgPath
        layerSharae.fillColor = UIColor.clear.cgColor
        layerSharae.strokeColor = getLineColor().cgColor
        layerSharae.lineWidth = 3.0
        self.layer.addSublayer(layerSharae)
        
        dashedLayer.path = getDashedPath().cgPath
        dashedLayer.fillColor = UIColor.clear.cgColor
        dashedLayer.strokeColor = getLineColor().cgColor
        dashedLayer.lineWidth = 3.0
        let space = NSNumber(value: 4.0 / 3.0)
        dashedLayer.lineDashPattern = [NSNumber(value: 3.0), space, NSNumber(value: 5.0), space, NSNumber(value: 5.0), space, NSNumber(value: 3.0), NSNumber(value: 1000.0)]
        self.layer.addSublayer(dashedLayer)
        
        self.backgroundColor = self.getOpeningBackgroundColor()
    }
    
    func getOpeningBackgroundColor() -> UIColor {
        let baseColor = getLineColor()
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        baseColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let bgR: CGFloat = 35/255.0
        let bgG: CGFloat = 43/255.0
        let bgB: CGFloat = 53/255.0
        
        let mixFactor: CGFloat = 0.35
        
        let mixedR = (r * mixFactor) + (bgR * (1 - mixFactor))
        let mixedG = (g * mixFactor) + (bgG * (1 - mixFactor))
        let mixedB = (b * mixFactor) + (bgB * (1 - mixFactor))
        
        return UIColor(red: mixedR, green: mixedG, blue: mixedB, alpha: 1.0)
    }
    
    func changeOriantation(_ isVertical:Bool)
    {
        self.isVertical = isVertical
        self.custom_size_reload()
    }
    
    func getSolidPath() -> UIBezierPath
    {
        let path = UIBezierPath()
        // The straight lines along the wall are now removed, leaving it empty
        return path
    }
    
    func getDashedPath() -> UIBezierPath
    {
        let path = UIBezierPath()
        let halfWidth: CGFloat = 1.5 // half of lineWidth 3.0
        
        // Left jamb
        path.move(to: CGPoint(x: halfWidth, y: 0))
        path.addLine(to: CGPoint(x: halfWidth, y: self.bounds.height))
        
        // Right jamb
        path.move(to: CGPoint(x: self.bounds.width - halfWidth, y: 0))
        path.addLine(to: CGPoint(x: self.bounds.width - halfWidth, y: self.bounds.height))
        
        return path
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func detectPan(_ recognizer:UIPanGestureRecognizer) {
        if !isMoved
        {
            return
        }
        let translation  = recognizer.translation(in: self.superview)
        if recognizer.state == .began {
            lastLocation = self.center
            if let lineView = self.superview as? LineView {
                lineView.saveState()
            }
        }
        let proposedCenter = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
        alignAndSnap(toProposedCenter: proposedCenter)
    }
    
    var touchOffset: CGPoint = .zero
    var hasMovedDuringTouch: Bool = false
    var touchStartLocation: CGPoint = .zero

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isMoved { return }
        self.superview?.bringSubviewToFront(self)
        hasMovedDuringTouch = false
        if let touch = touches.first {
            let location = touch.location(in: self.superview)
            touchStartLocation = location
            touchOffset = CGPoint(x: self.center.x - location.x, y: self.center.y - location.y)
        }
        lastLocation = self.center
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isMoved { return }
        if let touch = touches.first {
            let location = touch.location(in: self.superview)
            
            let distanceX = abs(location.x - touchStartLocation.x)
            let distanceY = abs(location.y - touchStartLocation.y)
            if distanceX > 5 || distanceY > 5 {
                hasMovedDuringTouch = true
            }
            
            let proposedCenter = CGPoint(x: location.x + touchOffset.x, y: location.y + touchOffset.y)
            alignAndSnap(toProposedCenter: proposedCenter)
            lastLocation = self.center
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isMoved { return }
        if let touch = touches.first {
            let location = touch.location(in: self.superview)
            let proposedCenter = CGPoint(x: location.x + touchOffset.x, y: location.y + touchOffset.y)
            alignAndSnap(toProposedCenter: proposedCenter)
            lastLocation = self.center
        }
        
        if !hasMovedDuringTouch {
            customDelegate?.customViewDelegateResult(self.tag)
        }
    }
    
    func change_color_of_path(_ color:UIColor)
    {
        layerSharae.strokeColor = getLineColor().cgColor
        dashedLayer.strokeColor = getLineColor().cgColor
        self.backgroundColor = self.getOpeningBackgroundColor()
    }
    
    func custom_size_reload()
    {
        let fixedThickness: CGFloat = 20.0
        let variableLength = max(self.custom_width, self.custom_hight) * 40
        // Width is along the wall (grows with UI width/height)
        // Height is perpendicular to the wall (fixed thickness)
        self.bounds.size = CGSize(width: variableLength, height: fixedThickness)
        
        self.layerSharae.path = getSolidPath().cgPath
        self.dashedLayer.path = getDashedPath().cgPath
        
        self.alignAndSnap(toProposedCenter: self.center)
        self.updateTooltipText()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layerSharae.path = getSolidPath().cgPath
        dashedLayer.path = getDashedPath().cgPath
        
        if let tooltip = tooltipView {
            let currentAngle = atan2(self.transform.b, self.transform.a)
            
            let targetWidth: CGFloat = 130.0
            var scale: CGFloat = 1.0
            if self.bounds.width < targetWidth {
                scale = max(0.6, self.bounds.width / targetWidth)
            }
            
            tooltip.transform = CGAffineTransform(scaleX: scale, y: scale).rotated(by: -currentAngle)
            
            let dx = self.transform.a
            let dy = self.transform.b
            
            var shouldFlip = false
            var centroid: CGPoint?
            
            if let lineView = self.superview as? LineView {
                var totalX: CGFloat = 0
                var totalY: CGFloat = 0
                var count = 0
                for pt in lineView.pointPath {
                    if !pt.isCorved {
                        totalX += pt.point.x
                        totalY += pt.point.y
                        count += 1
                    }
                }
                if count >= 3 {
                    centroid = CGPoint(x: totalX / CGFloat(count), y: totalY / CGFloat(count))
                }
            }
            
            if let cent = centroid {
                let vcX = cent.x - self.center.x
                let vcY = cent.y - self.center.y
                let vyX = -dy
                let vyY = dx
                let dotP = vcX * vyX + vcY * vyY
                shouldFlip = (dotP < 0)
            } else {
                var ux = -dy
                var uy = dx
                if abs(dx) > abs(dy) {
                    if uy > 0 { ux = -ux; uy = -uy }
                } else {
                    if ux > 0 { ux = -ux; uy = -uy }
                }
                let dot = ux * (-dy) + uy * dx
                shouldFlip = dot > 0
            }
            
            let tooltipHeight = tooltip.bounds.height
            var yOffset = (self.bounds.height / 2.0) + 24.0 + (tooltipHeight / 2.0)
            
            if shouldFlip {
                yOffset = -yOffset
                if let t = tooltip as? OpeningTooltipView {
                    t.setDirection(pointsUp: false)
                }
            } else {
                if let t = tooltip as? OpeningTooltipView {
                    t.setDirection(pointsUp: true)
                }
            }
            
            tooltip.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY + yOffset)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil {
            DispatchQueue.main.async {
                self.custom_size_reload()
                self.layerSharae.strokeColor = self.getLineColor().cgColor
                self.dashedLayer.strokeColor = self.getLineColor().cgColor
                self.backgroundColor = self.getOpeningBackgroundColor()
            }
        }
    }
    
    func getLineColor() -> UIColor {
        guard let superview = self.superview else {
            return UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 1.0)
        }
        if let lineView = superview as? LineView {
            if let stroke = lineView.shapeLayere?.strokeColor {
                return UIColor(cgColor: stroke)
            }
            return UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 1.0)
        }
        if let nzView = superview as? NineZeroDrowingView {
            if let stroke = nzView.shapeLayere?.strokeColor {
                return UIColor(cgColor: stroke)
            }
            return .white
        }
        if let lShapeView = superview as? L_Shape_CustomView {
            if let stroke = lShapeView.layerSharae?.strokeColor {
                return UIColor(cgColor: stroke)
            }
            return .white
        }
        return UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 1.0)
    }
    
    enum DrawableSegment {
        case straight(p1: CGPoint, p2: CGPoint)
        case curve(start: CGPoint, end: CGPoint, control: CGPoint)
    }
    
    func getParentSegments() -> [DrawableSegment] {
        guard let superview = self.superview else {
            return []
        }
        
        var segments: [DrawableSegment] = []
        
        if let lineView = superview as? LineView {
            let count = lineView.pointPath.count
            if count >= 2 {
                let limit = lineView.isClosed ? count : count - 1
                for i in 0..<limit {
                    let currIdx = (i + 1) % count
                    let prevIdx = i
                    
                    if lineView.pointPath[prevIdx].isCorved {
                        continue
                    }
                    
                    if lineView.pointPath[currIdx].isCorved {
                        let startPt = lineView.pointPath[prevIdx].point
                        let midPt = lineView.pointPath[currIdx].point
                        let endPt = lineView.pointPath[(currIdx + 1) % count].point
                        let curvpoints = lineView.getCurvePoints(startPoint: startPt, endPoint: endPt, midilePoint: midPt)
                        segments.append(.curve(start: startPt, end: curvpoints[0], control: curvpoints[1]))
                    } else {
                        let startPt = lineView.pointPath[prevIdx].point
                        let endPt = lineView.pointPath[currIdx].point
                        segments.append(.straight(p1: startPt, p2: endPt))
                    }
                }
            }
            return segments
        }
        
        if let nzView = superview as? NineZeroDrowingView {
            let pts = nzView.pointPath.map { $0.point }
            let count = pts.count
            if count >= 2 {
                let limit = nzView.isClosed ? count : count - 1
                for i in 0..<limit {
                    segments.append(.straight(p1: pts[i], p2: pts[(i + 1) % count]))
                }
            }
            return segments
        }
        
        if let lShapeView = superview as? L_Shape_CustomView {
            let pts = lShapeView.getDrawingPoints()
            let count = pts.count
            if count >= 2 {
                for i in 0..<count {
                    segments.append(.straight(p1: pts[i], p2: pts[(i + 1) % count]))
                }
            }
            return segments
        }
        
        return []
    }
    
    func alignAndSnap(toProposedCenter proposedCenter: CGPoint) {
        let segments = getParentSegments()
        guard !segments.isEmpty else {
            self.center = proposedCenter
            return
        }
        
        var closestPoint = proposedCenter
        var closestDistance = CGFloat.greatestFiniteMagnitude
        var closestAngle: CGFloat = 0
        var closestSegmentLength: CGFloat = 1000
        
        for segment in segments {
            switch segment {
            case .straight(let p1, let p2):
                let projected = projectPoint(proposedCenter, ontoSegmentFrom: p1, to: p2)
                let dist = distance(from: proposedCenter, to: projected)
                
                if dist < closestDistance {
                    closestDistance = dist
                    closestPoint = projected
                    closestAngle = atan2(p2.y - p1.y, p2.x - p1.x)
                    closestSegmentLength = distance(from: p1, to: p2)
                }
            case .curve(let startPt, let endPt, let ctrlPt):
                let steps = 50
                for i in 0...steps {
                    let t = CGFloat(i) / CGFloat(steps)
                    let mt = 1.0 - t
                    
                    let x = mt * mt * startPt.x + 2 * mt * t * ctrlPt.x + t * t * endPt.x
                    let y = mt * mt * startPt.y + 2 * mt * t * ctrlPt.y + t * t * endPt.y
                    let pt = CGPoint(x: x, y: y)
                    
                    let dist = distance(from: proposedCenter, to: pt)
                    if dist < closestDistance {
                        closestDistance = dist
                        closestPoint = pt
                        
                        // Tangent angle
                        let dx = 2 * mt * (ctrlPt.x - startPt.x) + 2 * t * (endPt.x - ctrlPt.x)
                        let dy = 2 * mt * (ctrlPt.y - startPt.y) + 2 * t * (endPt.y - ctrlPt.y)
                        closestAngle = atan2(dy, dx)
                        closestSegmentLength = distance(from: startPt, to: endPt)
                    }
                }
            }
        }
        
        self.center = closestPoint
        var scale: CGFloat = 1.5
        if let _ = self.superview as? LineView {
            let value = Float((closestSegmentLength / minimumValue) * 100).rounded() / 100
            if value <= 3.0 {
                scale = 0.65
            }
        }
        self.transform = CGAffineTransform(rotationAngle: closestAngle).scaledBy(x: scale, y: scale)
        self.layerSharae.strokeColor = getLineColor().cgColor
        self.dashedLayer.strokeColor = getLineColor().cgColor
        self.backgroundColor = self.getOpeningBackgroundColor()
        
        self.setNeedsLayout()
    }
    
    private func projectPoint(_ P: CGPoint, ontoSegmentFrom A: CGPoint, to B: CGPoint) -> CGPoint {
        let ab = CGPoint(x: B.x - A.x, y: B.y - A.y)
        let ap = CGPoint(x: P.x - A.x, y: P.y - A.y)
        
        let abLenSq = ab.x * ab.x + ab.y * ab.y
        if abLenSq == 0 {
            return A
        }
        
        var t = (ap.x * ab.x + ap.y * ab.y) / abLenSq
        t = max(0, min(1, t))
        
        return CGPoint(x: A.x + t * ab.x, y: A.y + t * ab.y)
    }
    
    private func distance(from P1: CGPoint, to P2: CGPoint) -> CGFloat {
        let dx = P2.x - P1.x
        let dy = P2.y - P1.y
        return sqrt(dx * dx + dy * dy)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let tooltip = tooltipView, !tooltip.isHidden {
            let pointInTooltip = convert(point, to: tooltip)
            if tooltip.bounds.contains(pointInTooltip) {
                return tooltip.hitTest(pointInTooltip, with: event) ?? self
            }
        }
        return super.hitTest(point, with: event)
    }
    
    func updateTooltipText() {
        guard let object = self.object else {
            tooltipView?.isHidden = true
            return
        }
        
        let name = object.name
        let parts = name.components(separatedBy: " to ")
        let openingName = parts.first ?? name
        let roomName = parts.count > 1 ? "Opening to \(parts[1])" : ""
        
        if tooltipView == nil {
            let tooltip = OpeningTooltipView()
            tooltip.translatesAutoresizingMaskIntoConstraints = true
            
            tooltip.onArrowTapped = { [weak tooltip, weak self] in
                guard let tooltip = tooltip else { return }
                UIView.animate(withDuration: 0.3) {
                    tooltip.containerView.isHidden.toggle()
                    tooltip.layoutIfNeeded()
                }
                // Optional: trigger layout on self if tooltip size changes
                self?.setNeedsLayout()
            }
            
            tooltip.onLabelTapped = { [weak self] in
                guard let self = self else { return }
                self.customDelegate?.customViewDelegateResult(self.tag)
            }
            
            self.addSubview(tooltip)
            self.tooltipView = tooltip
        }
        
        tooltipView?.titleLabel.text = openingName
        tooltipView?.subtitleLabel.text = roomName
        tooltipView?.isHidden = false
        
        if let tooltip = tooltipView {
            let currentTransform = tooltip.transform
            tooltip.transform = .identity
            let size = tooltip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            tooltip.bounds.size = CGSize(width: max(size.width + 10, 130), height: size.height)
            tooltip.transform = currentTransform
            self.setNeedsLayout()
        }
    }
    
    func configureForPreview(_ isPreview: Bool) {
        let goldColor = UIColor().colorFromHexString("#958E3E")
        if isPreview {
            self.tooltipView?.titleLabel.textColor = goldColor
            self.tooltipView?.subtitleLabel.textColor = goldColor
            self.tooltipView?.chevronImageView.tintColor = goldColor
        } else {
            self.tooltipView?.titleLabel.textColor = .white
            self.tooltipView?.subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
            self.tooltipView?.chevronImageView.tintColor = .white
        }
    }
}

class OpeningTooltipView: UIView {
    let containerView = UIView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let chevronImageView = UIImageView()
    let mainStack = UIStackView()
    
    var onArrowTapped: (() -> Void)?
    var onLabelTapped: (() -> Void)?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 120, height: 100))
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        mainStack.axis = .vertical
        mainStack.alignment = .center
        mainStack.spacing = -6
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        let t = mainStack.topAnchor.constraint(equalTo: topAnchor)
        t.priority = .init(999)
        let l = mainStack.leadingAnchor.constraint(equalTo: leadingAnchor)
        l.priority = .init(999)
        let tr = mainStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        tr.priority = .init(999)
        let b = mainStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        b.priority = .init(999)
        NSLayoutConstraint.activate([t, l, tr, b])
        
        containerView.backgroundColor = UIColor(red: 43/255.0, green: 48/255.0, blue: 56/255.0, alpha: 1.0)
        containerView.layer.cornerRadius = 14
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let labelStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 2
        labelStack.alignment = .center
        labelStack.distribution = .fill
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(labelStack)
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Avenir-Heavy", size: 15)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitleLabel.font = UIFont(name: "Avenir-Roman", size: 13)
        subtitleLabel.textAlignment = .center
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        containerView.widthAnchor.constraint(equalToConstant: 183).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 58).isActive = true
        
        NSLayoutConstraint.activate([
            labelStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            labelStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            labelStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
        
        chevronImageView.contentMode = .center
        chevronImageView.tintColor = .white
        chevronImageView.backgroundColor = UIColor(red: 43/255.0, green: 48/255.0, blue: 56/255.0, alpha: 1.0)
        chevronImageView.layer.cornerRadius = 18
        chevronImageView.layer.masksToBounds = true
        chevronImageView.layer.borderWidth = 1
        chevronImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        chevronImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        chevronImageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        mainStack.addArrangedSubview(containerView)
        mainStack.addArrangedSubview(chevronImageView)
        
        let contWidth = containerView.widthAnchor.constraint(equalTo: mainStack.widthAnchor)
        contWidth.priority = .init(999)
        contWidth.isActive = true
        if #available(iOS 13.0, *) {
            chevronImageView.image = UIImage(systemName: "chevron.down")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))
        } else {
            chevronImageView.image = UIImage(named: "dropDown")
        }
        
        self.isUserInteractionEnabled = true
        chevronImageView.isUserInteractionEnabled = true
        containerView.isUserInteractionEnabled = true
        
        let arrowTap = UITapGestureRecognizer(target: self, action: #selector(arrowClicked))
        chevronImageView.addGestureRecognizer(arrowTap)
        
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(labelClicked))
        containerView.addGestureRecognizer(labelTap)
    }
    
    @objc private func arrowClicked() {
        onArrowTapped?()
    }
    
    @objc private func labelClicked() {
        onLabelTapped?()
    }
    
    func setDirection(pointsUp: Bool) {
        mainStack.removeArrangedSubview(containerView)
        mainStack.removeArrangedSubview(chevronImageView)
        containerView.removeFromSuperview()
        chevronImageView.removeFromSuperview()
        
        if pointsUp {
            mainStack.addArrangedSubview(chevronImageView)
            mainStack.addArrangedSubview(containerView)
            if #available(iOS 13.0, *) {
                chevronImageView.image = UIImage(systemName: "chevron.up")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))
            } else {
                chevronImageView.image = UIImage(named: "dropUp") ?? UIImage(named: "dropDown")
            }
        } else {
            mainStack.addArrangedSubview(containerView)
            mainStack.addArrangedSubview(chevronImageView)
            if #available(iOS 13.0, *) {
                chevronImageView.image = UIImage(systemName: "chevron.down")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))
            } else {
                chevronImageView.image = UIImage(named: "dropDown")
            }
        }
    }
}
