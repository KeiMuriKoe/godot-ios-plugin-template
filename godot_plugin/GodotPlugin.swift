import Foundation

@objcMembers public class GodotPluginSwift: NSObject {
    
    // 1. Simple Swift Action -> Signal (No parameters)
    // We simulate a background task (like a network request)
    public func doSwiftTask(completion: @escaping @Sendable () -> Void) {
        print("Swift: Starting background task...")
        
        DispatchQueue.global().async {
            // Simulate waiting for 1 second
            Thread.sleep(forTimeInterval: 1.0)
            
            print("Swift: Task finished. Calling completion block.")
            // Return to the caller
            completion()
        }
    }
    
    // 2. Swift Action with Data -> Signal (With String parameter)
    public func getSwiftData(completion: @escaping (String) -> Void) {
        print("Swift: Generating data...")
        
        let resultString = "Data from Swift at \(Date())"
        
        // Return the data to the caller
        completion(resultString)
    }
    
    // Static test (old one)
    public static func helloWorldFromSwift() {
        print("Hello World from Swift!")
    }
}
