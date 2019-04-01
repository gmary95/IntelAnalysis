import Foundation

class CUSUM: DecompositionChecker {
    let k = 0.5
    
    var y: [Double]
    var m1: Double
    var m2: Double
    
    init(y: [Double], m1: Double, m2: Double) {
        self.y = y
        self.m1 = m1
        self.m2 = m2
    }
    
    func calcS(t: Int) -> Double {
        var S = 0.0
        if m2 > m1 {
            S = calcS1(t: t)
        } else {
            S = calcS2(t: t)
        }
        return S
    }
    
    func calcS1(t: Int) -> Double {
        if t == 0 {
            return 0.0
        }
        let S = calcS1(t: t - 1) + (y[t] - m1) - k
        return max(0, S)
    }
    
    func calcS2(t: Int) -> Double {
        if t == 0 {
            return 0.0
        }
        
        let S = calcS2(t: t - 1) - (y[t] - m1) + k
        return max(0, S)
    }
    
    func getResult(result s: Double, eps h: Double) -> String {
        var text = ""
        if s > h {
            text = "Has decomposition"
        } else {
            text = "Hasn't decomposition"
        }
        return text
    }
}
