//
//  ElloScrollLogic.swift
//  Ello
//
//  Created by Colin Gray on 2/24/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class ElloScrollLogic: NSObject, UIScrollViewDelegate {
    // for running specs
    public var isRunningSpecs = false

    public var prevOffset: CGPoint?
    var shouldIgnoreScroll: Bool = false
    var navBarHeight: CGFloat = 44
    var tabBarHeight: CGFloat = 49
    var barHeights: CGFloat { return navBarHeight + tabBarHeight }
    var lastStateChange = CACurrentMediaTime() - 1

    // showingState starts as "indeterminate".  That means that the first time
    // 'show' or 'hide' is called, it will call the appropriate handler no
    // matter what.
    private var showingState: Bool?
    var isShowing: Bool {
        get { return self.showingState ?? true }
        set { showingState = newValue }
    }

    private var onShow: ((Bool) -> Void)!
    private var onHide: (() -> Void)!

    public init(onShow: (Bool) -> Void, onHide: () -> Void) {
        self.onShow = onShow
        self.onHide = onHide
    }

    func onShow(handler: (Bool) -> Void) {
        self.onShow = handler
    }

    func onHide(handler: () -> Void) {
        self.onHide = handler
    }

    private func changedRecently() -> Bool {
        if isRunningSpecs {
            return false
        }

        let now = CACurrentMediaTime()
        return now - lastStateChange < 0.5
    }

    private func show(scrollToBottom: Bool = false) {
        let wasShowing = self.showingState ?? false

        if !changedRecently() {
            if !wasShowing {
                let prevIgnore = self.shouldIgnoreScroll
                self.shouldIgnoreScroll = true
                self.onShow(scrollToBottom)
                self.shouldIgnoreScroll = prevIgnore
                lastStateChange = CACurrentMediaTime()
            }
            showingState = true
        }
    }

    private func hide() {
        let wasShowing = self.showingState ?? true

        if !changedRecently() {
            if wasShowing {
                let prevIgnore = self.shouldIgnoreScroll
                self.shouldIgnoreScroll = true
                self.onHide()
                self.shouldIgnoreScroll = prevIgnore
                lastStateChange = CACurrentMediaTime()
            }
            showingState = false
        }
    }

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if !scrollView.dragging && !isRunningSpecs {
            return
        }

        let nextOffset = scrollView.contentOffset
        let shouldAcceptScroll = self.shouldAcceptScroll(scrollView)

        if shouldAcceptScroll {
            if let prevOffset = prevOffset {
                let didScrollDown = self.didScrollDown(scrollView.contentOffset, prevOffset)

                if didScrollDown {
                    let isAtTop = self.isAtTop(scrollView)
                    if !isAtTop {
                        hide()
                    }
                }
                else {
                    let isAtTop = self.isAtTop(scrollView)
                    let movedALittle = self.movedALittle(scrollView.contentOffset, prevOffset)
                    let movedALot = self.movedALot(scrollView.contentOffset, prevOffset)

                    if isAtTop || !movedALittle && !movedALot {
                        show()
                    }
                }
            }
        }

        prevOffset = nextOffset
    }

    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        shouldIgnoreScroll = false
    }

    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        if self.isAtTop(scrollView) {
            show(false)
        }
        shouldIgnoreScroll = true
    }

    private func shouldAcceptScroll(scrollView: UIScrollView) -> Bool {
        let nearBottom = self.nearBottom(scrollView)
        if shouldIgnoreScroll || nearBottom {
            return false
        }

        let contentSizeHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        let buffer = CGFloat(10)
        return scrollViewHeight + barHeights + buffer < contentSizeHeight
    }

    private func nearBottom(scrollView: UIScrollView) -> Bool {
        let contentOffsetBottom = scrollView.contentOffset.y + scrollView.frame.size.height
        let contentSizeHeight = scrollView.contentSize.height
        return contentSizeHeight - contentOffsetBottom < 50
    }

    private func didScrollDown(contentOffset: CGPoint, _ prevOffset: CGPoint) -> Bool {
        let contentOffsetY = contentOffset.y
        let prevOffsetY = prevOffset.y
        return contentOffsetY > prevOffsetY
    }

    private func isAtTop(scrollView: UIScrollView) -> Bool {
        let contentOffsetTop = scrollView.contentOffset.y
        return contentOffsetTop < 0
    }

    private func isAtBottom(scrollView: UIScrollView) -> Bool {
        let contentOffsetBottom = scrollView.contentOffset.y + scrollView.frame.size.height
        let contentSizeHeight = scrollView.contentSize.height
        return contentOffsetBottom > contentSizeHeight
    }

    private func movedALittle(contentOffset: CGPoint, _ prevOffset: CGPoint) -> Bool {
        return prevOffset.y - contentOffset.y < 5
    }

    private func movedALot(contentOffset: CGPoint, _ prevOffset: CGPoint) -> Bool {
        return prevOffset.y - contentOffset.y > 10
    }

}
