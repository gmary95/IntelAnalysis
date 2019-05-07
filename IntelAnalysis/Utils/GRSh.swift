import Foundation

class GRSh: DecompositionChecker {
    let y: [Double]!
    
    init(y: [Double]) {
        self.y = y
    }
    
    func w(yt: Double) -> Double {
        return exp(yt)
    }
    
    func calcW(t: Int) -> Double {
        if t == 0 { return 0 }
        let Wt = w(yt: y[t - 1]) * (1 + calcW(t: t - 1))
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
