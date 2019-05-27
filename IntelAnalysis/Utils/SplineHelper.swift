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
    
    static func bSpline2D(data:[[Double]], d: Int, multCountT: Double, multCountY: Double) -> [[Double]]{
        let n = data.count
        let m = data.first!.count
        let newCountOfT: Int = Int(ceil(Double(n) * multCountT))
        let newCountOfY: Int = Int(ceil(Double(m) * multCountY))
        var spline:[[Double]] = []
        
        for _ in 0 ..< newCountOfT {
            spline.append([Double](repeating: 0.0, count: newCountOfY))
        }
        
        let countOfU = n + d
        let countOfV = m + d
        var nbasis: [Double] = []
        var mbasis: [Double] = []
        var P_ik = 0.0
        
        let U = createU(n: n, c: d)
        let V = createU(n: m, c: d)
        
        let stepu: Double = U[countOfU] / Double(newCountOfT)
        let stepv: Double = V[countOfV] / Double(newCountOfY)
        var t1 = 0.0
        var t2 = 0.0
        
        for i in 0 ..< newCountOfT {
            t1 += stepu
            nbasis = calcBSpline(d: d, t: t1, pointCount: n, u: U)
            t2 = 0.0
            for j in 0 ..< newCountOfY {
                t2 += stepv
                mbasis = calcBSpline(d: d, t: t2, pointCount: m, u: V)
                spline[i][j] = 0.0
                for k1 in 0 ..< n {
                    for k2 in 0 ..< m {
                        P_ik = nbasis[k1] * mbasis[k2]
                        spline[i][j] += P_ik * data[k1][k2]
                    }
                }
            }
        }
        return spline
    }
    
    static func calcBSpline(d: Int, t: Double, pointCount: Int, u: [Double]) -> [Double] {
        var countOfPoint: Int = 0
        var a = 0.0
        var b = 0.0
        
        countOfPoint = pointCount + d
        var pointVector = [Double](repeating: 0.0, count: countOfPoint)
        var basisVector = [Double](repeating: 0.0, count: pointCount)
        
        for i in 1 ... countOfPoint - 1 {
            if t >= u[i] && t < u[i + 1] {
                pointVector[i] = 1.0
            } else {
                pointVector[i] = 0.0
            }
        }
        
        for k in 2 ... d {
            for i in 1 ... countOfPoint - k {
                if pointVector[i] != 0 {
                    a = ((t - u[i]) * pointVector[i]) / (u[i + k - 1] - u[i])
                } else {
                    a = 0.0
                }
                
                if  pointVector[i + 1] != 0 {
                    b = ((u[i + k] - t) * pointVector[i + 1]) / (u[i + k] - u[i + 1])
                } else {
                    b = 0
                }
                
                pointVector[i] = a + b
            }
        }
        
        if t == u[countOfPoint] {
            pointVector[pointCount] = 1
        }
        
        for i in 0 ..< pointCount {
            basisVector[i] = pointVector[i + 1]
        }
        
        return basisVector
    }
}
