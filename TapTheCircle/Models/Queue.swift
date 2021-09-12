//
//  Queue.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/11/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import Foundation

struct QueueArray<T> {
    private var items = [T]()

    mutating func enQueue(item: T) {
        items.append(item)
    }

    mutating func deQueue() -> T? {
        if !isEmpty() {
            return items.removeFirst()
        }
        return nil
    }

    func isEmpty() -> Bool {
        return items.isEmpty
    }

    func peek() -> T? {
        return items.first
    }
}
