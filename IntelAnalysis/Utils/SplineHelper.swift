class SplineHelper {
    var P: [Double]!
    var U: [Int]!
    let count: Int!
    var d: Int!
    
    init(P: [Double], d: Int) {
        self.P = P
        self.U = []
        self.d = d
        self.count = P.count + 2 * d - 2
        for _ in 0 ..< d {
            U.append(0)
        }
        for i in 1 ..< P.count {
            U.append(i)
        }
        for _ in 0 ..< d {
            U.append(P.count)
        }
    }
    
    func div(a: Double, b: Double) -> Double {
        return a / b
    }
    
    func calcB(k: Int, d: Int, t: Int, u: [Int]) -> Double {
        if d == 0 {
            return (u[k] <= t) && (t <= u[k + 1]) ? 1.0 : 0.0
        }
        
        let a =
            div(a: Double(t - u[k]), b: Double(u[k + d - 1] - u[k])) *
                calcB(k: k, d: d - 1, t: t, u: u)
        let b =
            div(a: Double(u[k + d] - t), b: Double(u[k + d] - u[k + 1])) *
                calcB(k: k + 1, d: d - 1, t: t, u: u)
        
        return a + b
    }
    
    func calcZ(t: Int) -> Double {
        var result = 0.0
        for k in 0 ..< P.count {
            result += P[k] * calcB(k: k, d: d, t: t, u: U)
        }
        
        return result
    }
}
