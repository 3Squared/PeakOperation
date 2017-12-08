//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
import Operation

class DelayOperation: BlockResultOperation<Void> {
    init(_ delay: TimeInterval) {
        super.init { () -> (Void) in
            Thread.sleep(until: Date(timeIntervalSinceNow: delay))
        }
        self.estimatedExecutionSeconds = Int64(delay)
    }
}

let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: 200, height: 1))
progressView.trackTintColor = .red
progressView.progressTintColor = .blue


let all = DelayOperation(1)
    .then(do: DelayOperation(2))
    .then(do: DelayOperation(3))
    .then(do: DelayOperation(1))
    .then(do: DelayOperation(1))
    .then(do: DelayOperation(1))
    .then(do: DelayOperation(3)) as! ConcurrentOperation

progressView.observedProgress = all.enqueueWithProgress()

PlaygroundPage.current.liveView = progressView
