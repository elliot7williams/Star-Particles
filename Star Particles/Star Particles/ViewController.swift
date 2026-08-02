//
//  ViewController.swift
//  Star Particles
//
//  Created by Elliot Williams on 2025-06-22.
//

import UIKit

class ParticleSystemView: UIView {
    // Particle system properties
    private var particles: [Particle] = []
    private var attractors: [Attractor] = []
    private var displayLink: CADisplayLink?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSystem()
        startAnimation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSystem()
        startAnimation()
    }
    
    private func setupSystem() {
        // Initialize particles
        for _ in 0..<100 {
            particles.append(
                Particle(
                    position: CGPoint(
                        x: CGFloat.random(in: 0..<bounds.width),
                        y: CGFloat.random(in: 0..<bounds.height)
                    ),
                    velocity: CGVector(dx: CGFloat.random(in: -1...1), dy: CGFloat.random(in: -1...1))
                )
            )
        }
        
        // Initialize attractors
        for _ in 0..<5 {
            attractors.append(
                Attractor(position: CGPoint(
                    x: CGFloat.random(in: 0..<bounds.width),
                    y: CGFloat.random(in: 0..<bounds.height)
                ))
            )
        }
    }
    
    private func startAnimation() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func update() {
        particles.forEach { particle in
            attractors.forEach { attractor in
                let force = attractor.attract(particle: particle)
                particle.applyForce(force)
            }
            particle.update()
            particle.checkEdges(bounds: bounds)
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Draw particles
        particles.forEach { particle in
            context.setFillColor(UIColor(
                red: 0.96, green: 0.3, blue: 0.73, alpha: 0.8
            ).cgColor)
            context.addArc(
                center: particle.position,
                radius: 4,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            )
            context.fillPath()
        }
        
        // Draw attractors
        attractors.forEach { attractor in
            context.setFillColor(UIColor.yellow.cgColor)
            context.addArc(
                center: attractor.position,
                radius: 10,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            )
            context.fillPath()
        }
    }
}

// MARK: - Particle Physics
class Particle {
    var position: CGPoint
    var velocity: CGVector
    var acceleration: CGVector = .zero
    let maxSpeed: CGFloat = 4
    let mass: CGFloat = 1.0
    
    init(position: CGPoint, velocity: CGVector) {
        self.position = position
        self.velocity = velocity
    }
    
    func applyForce(_ force: CGVector) {
        acceleration.dx += force.dx
        acceleration.dy += force.dy
    }
    
    func update() {
        velocity.dx += acceleration.dx
        velocity.dy += acceleration.dy
        
        // Limit velocity
        let speed = hypot(velocity.dx, velocity.dy)
        if speed > maxSpeed {
            velocity.dx = velocity.dx / speed * maxSpeed
            velocity.dy = velocity.dy / speed * maxSpeed
        }
        
        position.x += velocity.dx
        position.y += velocity.dy
        acceleration = .zero
    }
    
    func checkEdges(bounds: CGRect) {
        if position.x > bounds.width { position.x = 0 }
        if position.x < 0 { position.x = bounds.width }
        if position.y > bounds.height { position.y = 0 }
        if position.y < 0 { position.y = bounds.height }
    }
}

class Attractor {
    let position: CGPoint
    let mass: CGFloat = 20
    let G: CGFloat = 0.5
    
    init(position: CGPoint) {
        self.position = position
    }
    
    func attract(particle: Particle) -> CGVector {
        var force = CGVector(
            dx: position.x - particle.position.x,
            dy: position.y - particle.position.y
        )
        
        var distance = hypot(force.dx, force.dy)
        distance = distance < 5 ? 5 : distance > 25 ? 25 : distance
        
        let strength = (G * mass * particle.mass) / (distance * distance)
        let magnitude = hypot(force.dx, force.dy)
        
        force.dx = force.dx / magnitude * strength
        force.dy = force.dy / magnitude * strength
        
        return force
    }
}

// MARK: - Usage Example
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let particleView = ParticleSystemView(frame: view.bounds)
        view.addSubview(particleView)
    }
}
