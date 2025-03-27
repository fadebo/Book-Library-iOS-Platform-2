//
//  HalfSizePresentationController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-17.
//


import UIKit

class HalfSizePresentationController: UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        
        let containerBounds = containerView.bounds
        let height: CGFloat = containerBounds.height / 2
        let frame = CGRect(x: 0, y: containerBounds.height - height, width: containerBounds.width, height: height)
        
        return frame
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView = containerView else { return }
        
        // Add a dimming view
        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.alpha = 0.0
        containerView.addSubview(dimmingView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            dimmingView.alpha = 1.0
        })
        
        self.dimmingView = dimmingView
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = 0.0
        })
    }
    
    // MARK: - Private
    private var dimmingView: UIView?
}
