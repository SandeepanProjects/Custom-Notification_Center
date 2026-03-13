
import Foundation

protocol CustomNotificationCenterProtocol: class {
    func post(name: String, object: Any?, userInfo: [AnyHashable : Any]?)
    func addObserver(forName name: String, object: Any?, queue: OperationQueue?, completion: (CustomNotification) -> Void)
    func removeObservers(name: String)
}

struct CustomNotification {
    var name: String
    var userInfo: [AnyHashable: Any]?
}

struct CustomObserver {
    var name: String
}

class CustomNotificationCenter: CustomNotificationCenterProtocol {
    static let shared = CustomNotificationCenter()
    
    private init() {}
    
    var notificationsMap: [String: CustomNotification]  = [:]
    
    // Preserving thread safety for Observers
    private var queue = DispatchQueue(label: "observerMapQueue", qos:   .default, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    
    private var _observersMap: [String : [CustomObserver]] = [:]
    private var observersMap: [String : [CustomObserver]] {
        get {
            var map: [String : [CustomObserver]] = [:]
            queue.async {
                map = self._observersMap
            }
            return map
        } set {
            queue.sync(flags: .barrier) {
                _observersMap = newValue
            }
        }
    }

    
   func postNotification(_ name: String, object: Any) throws {
    
    var atLeastOneNotificationFound = false
    for (_, notificationData) in notificationsStorage {
        // Go through all the notifications and do the
        // Matching with name
        for (notificationName, closures) in notificationData {
            // Check if the notification name matches
            guard notificationName == name else { continue }
            for closure in closures {
                atLeastOneNotificationFound = true
                closure(name, object)
            }
        }
    }
    
    if !atLeastOneNotificationFound {
        throw NotificationCenterError.notificationNotFound
    }
}
    
    func addObserver(forName name: String, object: Any?, queue: OperationQueue?, completion: (CustomNotification) -> Void) {
        guard let notification = notificationsMap[name] else {
            assertionFailure("Notification is not Posted")
            return
        }
        
        let currentObserver = CustomObserver(name: name)
        
        if observersMap[name] == nil {
            observersMap[name] = [currentObserver]
        } else {
            observersMap[name]!.append(currentObserver)
        }
        
        completion(notification)
    }
    
    func removeObservers(name: String) {
        observersMap[name] = nil
    }
    
}




new code 


import Foundation

protocol CustomNotificationCenterProtocol: AnyObject {
    func post(name: String, object: Any?, userInfo: [AnyHashable: Any]?)
    func addObserver(
        forName name: String,
        queue: OperationQueue?,
        using: @escaping (CustomNotification) -> Void
    )
    func removeObservers(name: String)
}

struct CustomNotification {
    let name: String
    let object: Any?
    let userInfo: [AnyHashable: Any]?
}

class CustomNotificationCenter: CustomNotificationCenterProtocol {
    
    static let shared = CustomNotificationCenter()
    
    private init() {}
    
    private struct Observer {
        let queue: OperationQueue?
        let handler: (CustomNotification) -> Void
    }
    
    private let syncQueue = DispatchQueue(
        label: "custom.notification.center",
        attributes: .concurrent
    )
    
    private var observers: [String: [Observer]] = [:]
    
    // MARK: - Post
    
    func post(name: String, object: Any?, userInfo: [AnyHashable : Any]?) {
        
        let notification = CustomNotification(
            name: name,
            object: object,
            userInfo: userInfo
        )
        
        var currentObservers: [Observer] = []
        
        syncQueue.sync {
            currentObservers = observers[name] ?? []
        }
        
        for observer in currentObservers {
            if let queue = observer.queue {
                queue.addOperation {
                    observer.handler(notification)
                }
            } else {
                observer.handler(notification)
            }
        }
    }
    
    // MARK: - Add Observer
    
    func addObserver(
        forName name: String,
        queue: OperationQueue?,
        using: @escaping (CustomNotification) -> Void
    ) {
        let observer = Observer(queue: queue, handler: using)
        
        syncQueue.async(flags: .barrier) {
            self.observers[name, default: []].append(observer)
        }
    }
    
    // MARK: - Remove
    
    func removeObservers(name: String) {
        syncQueue.async(flags: .barrier) {
            self.observers[name] = nil
        }
    }
}

use this code

func fetchProfile() {

    CustomNotificationCenter.shared.post(
        name: "profileUpdated",
        object: nil,
        userInfo: ["name": "John"]
    )
}


CustomNotificationCenter.shared.addObserver(
    forName: "profileUpdated",
    queue: .main
) { notification in

    if let name = notification.userInfo?["name"] as? String {
        print("Profile updated:", name)
    }
}