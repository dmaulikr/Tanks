//
//  Player.swift
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

class Player : Tank {

	override func update(keys: [UInt16 : Bool]) {
		super.update(keys: keys)
		if turnEnded || hasFired {
			return
		}
		if keys[GameMgr.upArrow]! && cannonAngle > 0 {
			cannonAngle -= Tank.radian
		} else if keys[GameMgr.downArrow]! && cannonAngle < Float.pi {
			cannonAngle += Tank.radian
		}
		if keys[GameMgr.pgUpKey]! && firepower < 100 {
			firepower++
		} else if keys[GameMgr.pgDnKey]! && firepower > 0 {
			firepower--
		}
		if keys[GameMgr.spaceBar]! {
			fireProjectile()
		}
		if keys[GameMgr.rightArrow]! {
			move(1)
		} else if keys[GameMgr.leftArrow]! {
			move(-1)
		}
	}

}
