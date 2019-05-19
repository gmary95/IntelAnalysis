import Foundation

class CUSUM: DecompositionChecker {
    let k = 0.0
    
    var y: [Double]
    var m1: Double
    
    init(y: [Double], m1: Double) {
        self.y = y
        self.m1 = m1
    }
    
    func calcS(t: Int, SPrev: Double) -> Double {
        var S = 0.0
        S = calcS1(t: t, SPrev: SPrev) + calcS2(t: t, SPrev: SPrev)
        return S
    }
    
    func calcS1(t: Int, SPrev: Double) -> Double {
        if t == 0 {
            return 0.0
        }
        let S = SPrev + y[t] - m1 - k
        return max(0, S)
    }
    
    func calcS2(t: Int, SPrev: Double) -> Double {
        if t == 0 {
            return 0.0
        }
        
        let S = SPrev - y[t] + m1 + k
        return max(0, S)
    }
    
    static func getResult(result s: Double, eps h: Double) -> String {
        var text = ""
        if s > h {
            text = "Has decomposition"
        } else {
            text = "Hasn't decomposition"
        }
        return text
    }
}
