import Foundation

class GRSh: DecompositionChecker {
    let y: [Double]!
    
    init(y: [Double]) {
        self.y = y
    }
    
    func w(yt: Double) -> Double {
        return exp(yt)
    }
    
    func calcW(t: Int, WPrev: Double) -> Double {
        let Wt = w(yt: y[t]) * (1 + WPrev)
        return Wt
    }
    
    static func getResult(result W: Double, eps b: Double) -> String {
        var text = ""
        if W >= b {
            text = "Has decomposition"
        } else {
            text = "Hasn't decomposition"
        }
        return text
    }
}
