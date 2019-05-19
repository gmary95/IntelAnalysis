import Foundation

class LinearRegresion
{
    var selection: [Double]
    var a: Double?
    var b: Double?
    
    init(selection: [Double]) {
        self.selection = selection
    }
    
    public func initAllParam() {
        self.a = CalculateA()
        self.b = CalculateB()
    }
    
    private func CalculateAvaregeOfSelection() -> Double {
        var sum = 0.0
        for i in 0 ..< selection.count {
            sum += selection[i]
        }
        sum /= Double(selection.count)
        return sum
    }
    
    private func CalculateAvaregeOfTime() -> Double {
        var sum = 0.0
        for i in 0 ..< selection.count {
            sum += Double(i + 1)
        }
        sum /= Double(selection.count)
        return sum
    }
    
    private func CalculateAvaregeOfSelectionAndTime() -> Double {
        var sum = 0.0
        for i in 0 ..< selection.count {
            sum += selection[i] * Double(i + 1)
        }
        sum /= Double(selection.count)
        return sum
    }
    
    private func CalculateAvaregeOfPowTime() -> Double{
        var sum = 0.0
        for i in 0 ..< selection.count {
            sum += pow(Double(i + 1), 2)
        }
        sum /= Double(selection.count)
        return sum
    }
    
    private func CalculateSum() -> Double {
        var sum = 0.0
        for i in 0 ..< selection.count {
            sum += selection[i] * Double(i)
        }
        return sum
    }
    
    public func CalculateA() -> Double {
        var result = 0.0
        result = CalculateAvaregeOfSelection() - CalculateB() * CalculateAvaregeOfTime()
        return result
    }
    
    public func CalculateB() -> Double {
        var result = 0.0
        result = (CalculateAvaregeOfSelectionAndTime() - CalculateAvaregeOfSelection() * CalculateAvaregeOfTime()) /
            (CalculateAvaregeOfPowTime() - pow(CalculateAvaregeOfTime(), 2))
        return result
    }
    
    //            public double CalculateFTestValue()
    //        {
    //            double SSR = 0;
    //            double a = CalculateA();
    //            double b = CalculateB();
    //
    //            for (int i = 0; i < selection.Count; i++)
    //            {
    //            SSR += Math.Pow((a + b * (i + 1)) - CalculateAvaregeOfSelection(), 2);
    //            }
    //            double MSE = 0;
    //            for (int i = 0; i < selection.Count; i++)
    //            {
    //            MSE += Math.Pow(selection[i].data[0] - (a + b * (i + 1)), 2);
    //            }
    //            MSE /= (selection.Count - 2);
    //            //if (MSE == 0)
    //            //{
    //            //    return 100;
    //            //}
    //            return SSR / MSE;
    //            }
    //
    //            public double CalculateR2()
    //        {
    //            double SSR = 0;
    //            double a = CalculateA();
    //            double b = CalculateB();
    //
    //            for (int i = 0; i < selection.Count; i++)
    //            {
    //            SSR += Math.Pow((a + b * (i + 1)) - CalculateAvaregeOfSelection(), 2);
    //            }
    //            double SST = 0;
    //            for (int i = 0; i < selection.Count; i++)
    //            {
    //            SST += Math.Pow(selection[i].data[0] - CalculateAvaregeOfSelection(), 2);
    //            }
    //            if (SST == 0)
    //            {
    //            return 1;
    //            }
    //            return SSR / SST;
    //            }
    //
    //        }
}
