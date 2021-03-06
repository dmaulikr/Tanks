//
//  CCTank.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 25/07/2017.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2017 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation (version 3)

//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//See README and LICENSE for more details

import Cocoa

class CCTank : Tank {

	var aiLevel: AILevel! = .LOW

	var target: Tank?

	var targetAngle: Float = 0
	var targetFirepower: Int = 0

	var needsRecalc = true

	init(color: NSColor, pNum: Int, lvl: AILevel, name: String) {
		aiLevel = lvl
		super.init(color: color, pNum: pNum, name: name)
	}

	private static func uncertaintyForLevel(_ lvl: AILevel, rad: Bool) -> Float {
		let k = rad ? Tank.radian : 1
		switch lvl {
		case .LOW:
			return 10 * k
		case .MED:
			return 5 * k
		case .HIGH:
			return k
		}
	}

	func chooseNewTarget() {
		var possibleTargets: [Tank] = []
		for tank in tanks! {
			if tank.hp > 0 && tank.playerNum != playerNum {
				possibleTargets.append(tank)
			}
		}
		target = possibleTargets[Int(arc4random_uniform(UInt32(possibleTargets.count)))]

		recalculate(tx: target!.position.x, ty: target!.position.y, a: CGFloat(terrain!.windAcceleration))
	}

	private func recalculate(tx: CGFloat, ty: CGFloat, a: CGFloat) {
		let x = tx - position.x
		let y = ty - position.y

		let b = (y / -x) - x
		var a1: CGFloat = 0.01

		var range: CountableClosedRange<Int>?
		if x < 0 {
			range = (Int(tx) / terrain!.chunkSize + 1)...(Int(position.x) / terrain!.chunkSize - 1)
		} else {
			range = (Int(position.x) / terrain!.chunkSize + 1)...(Int(tx) / terrain!.chunkSize - 1)
		}

		for i in range! {
			let xc = CGFloat(i * terrain!.chunkSize) - position.x
			let h = terrain!.terrainControlHeights[i] - position.y
			if -a1 * xc * (xc + b) < h {
				a1 = -(h + 10) / (xc * (xc + b))
			}
		}

		targetAngle = Float(atan(-a1 * b))
		if x < 0 {
			targetAngle += .pi
		}

		let s = CGFloat(sin(targetAngle))
		let c = CGFloat(cos(targetAngle))
		let sc = s * c

		let den1 = 2 * a * (x * s * s - y * sc)
		let den2 = 2 * 9.81 * (x * sc - y * c * c)

		if den1 + den2 < 0 {
			targetFirepower = 100
		} else {
			targetFirepower = abs(Int(round((a * y + 9.81 * x) / sqrt(den1 + den2))))
		}

		targetAngle += Float(arc4random_uniform(1000)) / 1000 * CCTank.uncertaintyForLevel(aiLevel, rad: true)
		targetFirepower += Int(arc4random_uniform(UInt32(CCTank.uncertaintyForLevel(aiLevel, rad: false))))

		assert(targetAngle >= 0 && targetAngle <= .pi)
		if targetFirepower > 100 {
			Swift.print(targetFirepower)
		}

		needsRecalc = false
	}

	override func fireProjectile() {
		super.fireProjectile()
		needsRecalc = true
	}

	override func update(keys: [UInt16 : Bool]) {
		super.update(keys: keys)
		//skip update if tank is falling, the turn is over, or a shot has already been taken
		if lastY != position.y || turnEnded || hasFired {
			return
		}
		//if no target chosen or previous target is dead, retarget
		if target == nil || target!.hp <= 0 {
			chooseNewTarget()
		}
		//needs to recalculate firepower and cannon angle?
		if needsRecalc {
			recalculate(tx: target!.position.x, ty: target!.position.y, a: CGFloat(terrain!.windAcceleration))
		}

		if abs(targetAngle - cannonAngle) <= Tank.radian * 2 {
			cannonAngle = targetAngle
			if firepower == targetFirepower {
				fireProjectile()
			} else {
				if firepower < targetFirepower {
					firepower++
				} else {
					firepower--
				}
			}
		} else {
			if cannonAngle < targetAngle {
				cannonAngle += Tank.radian / 2
			} else {
				cannonAngle -= Tank.radian / 2
			}
		}
	}
	
}
