import Foundation

precedencegroup ListPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

infix operator += : ListPrecedence
infix operator <<< : ListPrecedence

public func <<< <Key : Hashable, Value>(left: inout List<Key, Value>, right: [Key: Value]) {
    left.append(right)
}

public func <<< <Key : Hashable, Value>(left: inout List<Key, Value>, right: (Key, Value)) {
    left.append(right)
}

public func += <Key : Hashable, Value>(left: inout List<Key, Value>, right: [Key: Value]) {
    left <<< (right)
}

public func += <Key : Hashable, Value>(left: inout List<Key, Value>, right: (Key, Value)) {
    left <<< (right)
}

public typealias SortedDictionary<Key: Hashable, Value> = List<Key, Value>

public struct List<Key: Hashable, Value>: ExpressibleByDictionaryLiteral {
    var tag: String?
    var keys = [Key]() {
        didSet { assert(keys.count == Set(keys).count, "List duplicate key found in keys: \(keys)") }
    }
    var values = [Value]()
    
    public init() {}
    
    public init(_ array: [(Key, Value)]) {
        for (key, value) in array {
            keys.append(key)
            values.append(value)
        }
    }
    
    public init(_ keys: [Key], _ values: [Value]) {
        assert(keys.count == values.count, "List key count and value count are not equal ( \(keys.count) vs \(values.count) )")
        
        for (key, value) in zip(keys, values) {
            self.keys.append(key)
            self.values.append(value)
        }
    }
    
    public init(_ dictionary: [Key: Value]) {
        for (key, value) in dictionary {
            keys.append(key)
            values.append(value)
        }
    }
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(elements)
    }
}

extension List: Collection {
    public var startIndex: Int { return 0 }
    public var endIndex: Int {
        assert(keys.count == values.count, "List key count and value count are not equal ( \(keys.count) vs \(values.count) )")
        return keys.count
    }
}

extension List: MutableCollection {
    public subscript(_ index: Int) -> (Key, Value) {
        get { return (keys[index], values[index]) }
        set {
            let (key, value) = newValue
            updateValue(value, forKey: key)
        }
    }
    
    public func index(after i: Int) -> Int {
        return i+1 <= endIndex ? i+1 : endIndex
    }
    
    public func index(before i: Int) -> Int {
        return i > startIndex ? i-1 : startIndex
    }
    
    public var last: (Key, Value)? {
        guard let key = keys.last, let value = values.last else { return nil }
        return (key, value)
    }
}

extension List: RangeReplaceableCollection {
    @discardableResult
    public mutating func append(_ closure: () -> (Key, Value)) -> List<Key, Value> {
        let newElement = closure()
        append(newElement)
        return self
    }
    
    @discardableResult
    public mutating func append(_ closure: () -> [Key: Value]) -> List<Key, Value> {
        let newElement = closure()
        append(newElement)
        return self
    }
    
    public mutating func append(_ newElement: [Key: Value]) {
        keys.append(contentsOf: newElement.keys)
        values.append(contentsOf: newElement.values)
    }
    
    public mutating func append(_ newElement: (Key, Value)) {
        let (key, value) = newElement
        keys.append(key)
        values.append(value)
    }
    
    public mutating func append(_ newElement: (Key?, Value?)?) {
        guard let (key, value) = newElement else { return }
        self[key] = value
    }
    
    public mutating func append<S: Sequence>(contentsOf newElements: S)
        where S : Sequence, S.Iterator.Element == (Key, Value) {
            for element in newElements {
                append(element)
            }
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C)
        where C : Collection, C.Iterator.Element == (Key, Value) {
            var keys = [Key]()
            var values = [Value]()
            
            for (key, value) in newElements {
                keys.append(key)
                values.append(value)
            }
            
            keys.replaceSubrange(subrange, with: keys)
            values.replaceSubrange(subrange, with: values)
    }
    
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        keys.removeAll(keepingCapacity: keepCapacity)
        values.removeAll(keepingCapacity: keepCapacity)
    }
    
    public mutating func removeValue(forKey key: Key) {
        self[key] = nil
    }
    
    public func filter(_ isIncluded: ((Key, Value)) throws -> Bool) rethrows -> List<Key, Value> {
        let array: [(Key, Value)] = try filter(isIncluded)
        return List<Key, Value>(array)
    }
    
    public func map<K: Hashable, V>(_ transform: ((Key, Value)) throws -> (K?, V?)?) rethrows -> List<K, V> {
        var list = List<K, V>()
        
        try forEach {
            list.append(try transform($0))
        }
        
        return list
    }
    
    public func index(of element: (Key, Value)) -> Int? {
        let (key, _) = element
        return keys.index(of: key)
    }
}

public extension List where Value: Equatable {
    public func keys(for values: [Value]) -> [Key] {
        return flatMap { key, value -> Key? in
            values.contains(value) ? key : nil
        }
    }
}

public extension List {
    public func values(for keys: [Key]) -> [Value] {
        return flatMap { (key, value) -> Value? in
            keys.contains(key) ? value : nil
        }
    }
    
    public func toDict() -> [Key: Value] {
        var dictionary = [Key: Value]()
        
        forEach { key, value in
            dictionary[key] = value
        }
        
        return dictionary
    }
    
    public func toArray() -> [(Key, Value)] {
        return map { element -> (Key, Value) in element }
    }
}

public extension List {
    public subscript(_ key: Key?) -> Value? {
        get {
            if let key = key, let index = keys.index(of: key) {
                return values[index]
            } else {
                return nil
            }
        }
        
        set { updateValue(newValue, forKey: key) }
    }
    
    public mutating func updateValue(_ value: Value?, forKey key: Key?) {
        guard let key = key else { return }
        
        guard let index = keys.index(of: key) else {
            if let value = value {
                keys.append(key)
                updateValue(value, forKey: key)
            }
            
            return
        }
        
        if let value = value {
            if values.count - 1 >= index {
                values[index] = value
            } else {
                values.append(value)
            }
        } else {
            keys.remove(at: index)
            values.remove(at: index)
        }
    }
}
