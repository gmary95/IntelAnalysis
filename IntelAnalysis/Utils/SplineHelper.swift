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
    
    static func createU(count: Int, d: Int) -> [Double] {
        var u = [Double](repeating: 0.0, count:  count + d + 1)

        let arraySize = count + d
        let rightLine = count + 2
        let leftLine = d
        
        u[1] = 0
        for i in 2 ... arraySize {
            if i > leftLine && i < rightLine {
                u[i] = u[i - 1] + 1
            } else {
                u[i] = u[i - 1]
            }
        }
        return u
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
    
    static func calcZArray(data:[[Double]], d: Int, multCountT: Int, multCountY: Int) -> [[Double]]{
        let n = data.count
        let m = data.first!.count
        let newCountOfT: Int = n * multCountT
        let newCountOfY: Int = m * multCountY
        
        var spline:[[Double]] = []
        for _ in 0 ..< newCountOfT {
            spline.append([Double](repeating: 0.0, count: newCountOfY))
        }
        
        let countOfU = n + d
        let countOfV = m + d
        var nbasis: [Double] = []
        var mbasis: [Double] = []
        
        let U = createU(count: n, d: d)
        let V = createU(count: m, d: d)
        
        let stepForT: Double = U[countOfU] / Double(newCountOfT)
        let stepForY: Double = V[countOfV] / Double(newCountOfY)
        var dT = 0.0
        var dY = 0.0
        
        for i in 0 ..< newCountOfT {
            dT += stepForT
            nbasis = calcBSpline(d: d, t: dT, pointCount: n, u: U)
            dY = 0.0
            for j in 0 ..< newCountOfY {
                dY += stepForY
                mbasis = calcBSpline(d: d, t: dY, pointCount: m, u: V)
                for k in 0 ..< n {
                    for b in 0 ..< m {
                        let P_kb = nbasis[k] * mbasis[b]
                        spline[i][j] += P_kb * data[k][b]
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
