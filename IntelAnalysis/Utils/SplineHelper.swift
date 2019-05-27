import Foundation

class SplineHelper {
    var P: [Double]!
    var U: [Double]!
    var n: Int!
    let count: Int!
    var d: Int!
    var c: Double!
    
    init(P: [Double], n: Int, d: Int) {
        self.P = P
        self.n = n
        self.U = []
        self.d = d
        self.count = P.count + 2 * d - 1
        self.c = 1.0 / Double(d)
        self.U = Array<Double>(repeating: 0, count: count)
        createU(n: P.count, d: d, step: 1)
    }
    
    func createU(x: [Double]) {
        self.U = []
        for i in 0 ..< U.count {
            U.append(x[i] - floor(x[i]))
        }
    }
    
    static func createU(n: Int, c: Int) -> [Double] {
        var x = [Double](repeating: 0.0, count:  n + c + 1)

        let nplusc = n + c
        let nplus2 = n + 2
        
        x[1] = 0
        for i in 2 ... nplusc {
            if i > c && i < nplus2 {
                x[i] = x[i - 1] + 1
            } else {
                x[i] = x[i - 1]
            }
        }
        return x
    }
    
    func createU(n: Int, d: Int, step: Double) {
        var arraySize: Int
        var rightLine: Int
        var leftLine: Int
        
        arraySize = count
        rightLine = arraySize - d + 1
        leftLine = d - 1
        
        U[0] = 0
        for i in 1 ..< arraySize {
            if ( (i > leftLine) && (i < rightLine) ) {
                U[i] = U[i-1] + step
            } else {
                U[i] = U[i-1]
            }
        }
    }
    
    func calcB(P: Matrix, t: Matrix) -> Matrix {
        var result: Matrix
        let matrix = Matrix([
            [-1, 3, -3, 1],
            [3, -6, 3, 0],
            [-3, 0, 3, 0],
            [1, 4, 1, 0]
            ])
        result = (1 / 6) * P * matrix * t
        return result
}
    
    private func calcB(i: Int, k: Int,  u: [Double], t: Double) -> Double {
        if k == 0 {
            if ((u[i] <= t) && (t < u[i+1])) {
                return 1.0
            } else {
                return 0.0
            }
        } else {
            var memb1, memb2: Double
            if(u[i + k]==u[i]) {
                memb1 = 0
            } else {
                let b = calcB(i: i, k: k - 1, u: u, t: t)
                memb1 = ((t - u[i]) / (u[i+k] - u[i])) * b
            }
            if (u[i+k + 1] == u[i+1]) {
                memb2 = 0
            } else {
                let b = calcB(i: i + 1, k: k - 1, u: u, t: t)
                memb2 = ((u[i+k + 1] - t) / (u[i+k + 1] - u[i+1])) * b
            }
            return memb1 + memb2
        }
    }
    
    func calcZ(t: Double) -> Double {
        var result = 0.0
//        P.append(P.last!)
        for i in 0 ..< P.count {
            let b = calcB(i: i + 1, k: d - 1, u: U, t: t)
            result += P[i] * b
        }
        
        return result
    }
    
    static func bSpline2D(data:[[Double]], c: Int, divx: Double, divy: Double) -> [[Double]]{
        let n = data.count
        let m = data.first!.count
        let p1: Int = Int(ceil(Double(n) * divx))//lengthx
        let p2: Int = Int(ceil(Double(m) * divy))//length y
        var spline:[[Double]] = []
        
        for _ in 0 ..< p1 {
            spline.append([Double](repeating: 0.0, count: p2))
        }
        
        let nplusc = n + c
        let mplusc = m + c
        var nbasis: [Double] = []
        var mbasis: [Double] = []
        var pbasis = 0.0
        
        let x = createU(n: n, c: c)
        let y = createU(n: m, c: c)
        
        let stepu: Double = x[nplusc] / Double(p1)
        let stepv: Double = y[mplusc] / Double(p2)
        var t1 = 0.0
        var t2 = 0.0
        
        for i in 0 ..< p1 {
            t1 += stepu
            nbasis = bSplineBasis(c: c, t: t1, pcnt: n, knots: x)
            t2 = 0.0
            for j in 0 ..< p2 {
                t2 += stepv
                mbasis = bSplineBasis(c: c, t: t2, pcnt: m, knots: y)
                spline[i][j] = 0.0
                for k1 in 0 ..< n {
                    for k2 in 0 ..< m {
                        pbasis = nbasis[k1] * mbasis[k2]
                        spline[i][j] += pbasis * data[k1][k2]
                    }
                }
            }
        }
        return spline
    }
    
    static func bSplineBasis(c: Int, t: Double, pcnt: Int, knots: [Double]) -> [Double] {
        var nplusc: Int = 0
        var d = 0.0
        var e = 0.0
        
        nplusc = pcnt + c
        var tmp = [Double](repeating: 0.0, count: nplusc)
        var bas = [Double](repeating: 0.0, count: pcnt)
        
        for i in 1 ... nplusc - 1 {
            if t >= knots[i] && t < knots[i + 1] {
                tmp[i] = 1.0
            } else {
                tmp[i] = 0.0
            }
        }
        
        for k in 2 ... c {
            for i in 1 ... nplusc - k {
                if tmp[i] != 0 {
                    d = ((t - knots[i]) * tmp[i]) / (knots[i + k - 1] - knots[i])
                } else {
                    d = 0.0
                }
                
                if  tmp[i + 1] != 0 {
                    e = ((knots[i + k] - t) * tmp[i + 1]) / (knots[i + k] - knots[i + 1])
                } else {
                    e = 0
                }
                
                tmp[i] = d + e
            }
        }
        
        if t == knots[nplusc] {
            tmp[pcnt] = 1
        }
        
        for i in 0 ..< pcnt {
            bas[i] = tmp[i + 1]
        }
        
        return bas
    }
}
