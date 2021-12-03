import Foundation

public struct Table<Element: Equatable & Hashable>: ExpressibleByArrayLiteral {
    private var store: NSMutableOrderedSet
    
    public var count: Int { store.count }
    
    public init() {
        self.store = NSMutableOrderedSet()
    }
    
    public init(_ elements: [Element]) {
        self.store = NSMutableOrderedSet(array: elements)
    }
    
    public init(_ elements: [Element], filter: @escaping (Element) -> Bool) {
        self.store = NSMutableOrderedSet(array: elements.filter(filter))
    }
    
    public init(arrayLiteral elements: Element...) {
        self.store = NSMutableOrderedSet(array: elements)
    }
    
    public mutating func insert(_ element: Element, at index: Int) {
        store.insert(element, at: index)
    }
    
    public mutating func push(_ element: Element) {
        store.add(element)
    }
    
    public mutating func push(contentsOf elements: [Element]) {
        for element in elements {
            push(element)
        }
    }
    
    @discardableResult
    public mutating func pop() -> Element? {
        if let last = store.lastObject as? Element {
            pop(last)
            return last
        }
        return nil
    }
    
    @discardableResult
    public mutating func pop(_ element: Element) -> Element? {
        if store.contains(element) {
            store.remove(element)
            return element
        }
        return nil
    }
    
    public mutating func remove(at index: Int) {
        store.removeObject(at: index)
    }
}

extension Table: Sequence {
    public typealias Iterator = AnyIterator<Any>
    
    public func makeIterator() -> Iterator {
        var iterator = store.makeIterator()
        
        return AnyIterator {
            return iterator.next()
        }
    }
}

extension Table: Equatable { }

extension Table: CustomStringConvertible {
    public var description: String {
        var result = ""
        
        for row in store {
            result += "\(row)\n"
        }
        
        return result
    }
}
