//
//  ConstraintHelper.swift
//  constraintHelper
//
//  Created by Derrick  Ho on 4/16/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

import UIKit

private func +<KEY,VALUE>(a: [KEY:VALUE], b: [KEY:VALUE]) -> [KEY:VALUE] {
	var d = a
	for (k, v) in b {
		d[k] = v
	}
	return d
}

func -<T>(lhs: ConstraintHelper, rhs: T) -> ConstraintHelper {
	return "\(lhs)-\(rhs)"
}

//prefix operator |- {}
//prefix func |-<T>(rhs: T) -> ConstraintHelper {
//	return "|-\(rhs)"
//}

infix operator |- { associativity left }
func |-<T>(lhs: (Void), rhs: T) -> ConstraintHelper {
	return "|-\(rhs)"
}

//postfix operator -| {}
//postfix func -|<T>(lhs: T) -> ConstraintHelper {
//	return "\(lhs)-|"
//}

infix operator -| { associativity left }
func -|<T>(lhs: T, rhs: (Void)) -> ConstraintHelper {
	return "\(lhs)-|"
}

infix operator ->= { associativity left precedence 140 }
func ->=<T>(lhs: ConstraintHelper, rhs: T) -> ConstraintHelper {
	return "\(lhs)->=\(rhs)"
}

infix operator -<= { associativity left precedence 140 }
func -<=<T>(lhs: ConstraintHelper, rhs: T) -> ConstraintHelper {
	return "\(lhs)-<=\(rhs)"
}

struct ConstraintHelper: StringInterpolationConvertible {
	
	let constraintString: String
	var options: NSLayoutFormatOptions = NSLayoutFormatOptions(rawValue: 0)
	private var metricDict = [String : Int]()
	private var viewDict = [String : UIView]()
	private struct __ {
		static var count: Int = 0
	}
	
	/// every segment created by init<T>(stringInterpolationSegment expr: T) will come here as an array of Segments.
	init(stringInterpolation strings: ConstraintHelper...) {
		constraintString = strings.map({ $0.constraintString }).reduce("", combine: +)
		viewDict = strings.map({ $0.viewDict }).reduce([:], combine:+)
		metricDict = strings.map({ $0.metricDict }).reduce([:], combine:+)
	}
	
	/// the string literal is broken up into intervals of all string and \(..) which are called segments
	init<T>(stringInterpolationSegment expr: T) {
		let uuid = __.count
		__.count = __.count &+ 1
		if let ch = expr as? ConstraintHelper {
			constraintString = ch.constraintString
			options = ch.options
			metricDict = ch.metricDict
			viewDict = ch.viewDict
		} else if let v = expr as? UIView {
			viewDict = ["view_\(uuid)" : v]
			constraintString = "[view_\(uuid)]"
		} else if let s = expr as? String {
			constraintString = "\(s)"
		} else {
			constraintString = "\(String(expr))"
		}
	}
	
	init(_ view: UIView? = nil, length: Int? = nil, priority: Int = 1000) {
		let uuid = __.count
		__.count = __.count &+ 1
		view?.translatesAutoresizingMaskIntoConstraints = false
		switch (view, length) {
		case let (v?, l?):
			viewDict = ["view_\(uuid)" : v]
			metricDict = ["metric_\(uuid)" : l]
			constraintString = "[view_\(uuid)(metric_\(uuid)@\(priority))]"
		case let (v?, nil):
			viewDict = ["view_\(uuid)" : v]
			constraintString = "[view_\(uuid)]"
		case let (nil, l?):
			metricDict = ["metric_\(uuid)" : l]
			constraintString = "(metric_\(uuid)@\(priority))"
		case (nil, nil):
			assertionFailure("at least view or length must be added.  Having both non existent is not allowed")
			constraintString = ""
		}
	}
	
}

extension UIView {
	func addConstraints_H(constraintHelper: ConstraintHelper) {
		addConstraints("H:\(constraintHelper)")
	}
	func addConstraints_V(constraintHelper: ConstraintHelper) {
		addConstraints("V:\(constraintHelper)")
	}
	func addConstraints(constraintsHelper: ConstraintHelper) {
		constraintsHelper.viewDict.forEach({
			$1.translatesAutoresizingMaskIntoConstraints = false
			if self.subviews.contains($1) == false {
				self.addSubview($1)
			}
		})
		addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(constraintsHelper.constraintString,
			options: constraintsHelper.options,
			metrics: constraintsHelper.metricDict,
			views: constraintsHelper.viewDict))
		print(constraintsHelper)
	}
}

