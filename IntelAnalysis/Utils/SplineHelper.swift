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
    
//    func createMatrix(k: Int, t: Double) {
//        var array:[[Double]] = [[]]
//        var arr: [Double] = []
//        for j in 0 ... d {
//            var result = 0.0
//            if ((U[k] <= t) && (t < U[k+1])) {
//                result = 1.0
//            } else {
//                result = 0.0
//            }
//            arr.append(result)
//        }
//        array.append(arr)
//        for i in 1 ..< d {
//            var arr: [Double] = []
//            for j in 1 ... d - i {
//                var result = 0.0
//                var memb1, memb2: Double
//                if(u[j + k - 1]==u[i]) {
//                    memb1 = 0
//                } else {
//                    let b = calcB(i: i, k: k - 1, u: u, t: t)
//                    memb1 = ((t - u[j]) / (u[i+k - 1] - u[i])) * b
//                }
//                if (u[i+k] == u[i+1]) {
//                    memb2 = 0
//                } else {
//                    let b = calcB(i: i + 1, k: k - 1, u: u, t: t)
//                    memb2 = ((u[i+k] - t) / (u[i+k] - u[i+1])) * b
//                }
//                result = memb1 + memb2
//                arr.append(result)
//            }
//            array.append(arr)
//        }
//    }
    
    func calcZ(t: Double) -> Double {
        var result = 0.0
//        P.append(P.last!)
        for i in 0 ..< P.count {
            let b = calcB(i: i, k: d, u: U, t: t)
            result += P[i] * b
        }
        
        return result
    }
}
