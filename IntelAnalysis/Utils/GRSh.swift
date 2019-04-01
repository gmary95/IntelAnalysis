import Foundation

class GRSh: DecompositionChecker {
    func w(f0: Double, f1: Double) -> Double {
        return f0 / f1
    }
    
    func w(yt: Double) -> Double {
        return exp(yt)
    }
    
    func calcW(t: Int) -> Double {
        if t == 0 { return 0 }
        let Wt = w(f0: 0.0, f1: 0.0) * (1 + calcW(t: t - 1 ))
        return Wt
    }
    
    func calcW(t: Int, y:[Double]) -> Double {
        if t == 0 { return 0 }
        let Wt = w(yt: y[t]) * (1 + calcW(t: t - 1, y: y))
        return Wt
    }
    
    func getResult(result W: Double, eps b: Double) -> String {
        var text = ""
        if W >= b {
            text = "Has decomposition"
        } else {
            text = "Hasn't decomposition"
        }
        return text
    }
}
