//
//  ViewAdd.swift
//  NewsWithoutSaveData
//
//  Created by Nochnoy on 07/02/2019.
//  Copyright © 2019 Nochnoy. All rights reserved.
//

import Foundation
import UIKit

enum Anchor {
  case leading
  case trailing
  case top
  case bottom
}

extension UIView {
  func add(subview: UIView, with anchors: [Anchor]) {
    self.addSubview(subview)
    subview.translatesAutoresizingMaskIntoConstraints = false
    for anchor in anchors {
      applyAnchor(anchor: anchor, view: subview)
    }
  }
  
  func centerSubviewsVertically() {
    self.subviews.forEach({ $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true })
  }
  
  func removeView(with tag: Int) {
    if let view = self.viewWithTag(tag) {
      if
        let bar = self as? UINavigationBar,
        !ProcessInfo().isOperatingSystemAtLeast(
          OperatingSystemVersion(majorVersion: 11, minorVersion: 0, patchVersion: 0)) {
        // avoiding NSInternalInconsistencyException on iOS 10.3-
        bar.constraints.forEach({ $0.isActive = false })
      }
      view.removeFromSuperview()
    }
  }
  
  func removeAllSubviews() {
    let toRemove = self.subviews
    for v in toRemove {
      v.removeFromSuperview()
    }
  }
  
  func add(subview: UIView, with insets: UIEdgeInsets) {
    self.addSubview(subview)
    subview.translatesAutoresizingMaskIntoConstraints = false
    
    subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left).isActive = true
    subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -insets.right).isActive = true
    subview.topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top).isActive = true
    subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insets.bottom).isActive = true
  }
}

private func applyAnchor(anchor: Anchor, view: UIView) {
  switch anchor {
  case .leading:
    view.leadingAnchor.constraint(equalTo: view.superview!.leadingAnchor).isActive = true
  case .trailing:
    view.trailingAnchor.constraint(equalTo: view.superview!.trailingAnchor).isActive = true
  case .top:
    view.topAnchor.constraint(equalTo: view.superview!.safeAreaLayoutGuide.topAnchor).isActive = true
  case .bottom:
    view.bottomAnchor.constraint(equalTo: view.superview!.bottomAnchor).isActive = true
  }
}
