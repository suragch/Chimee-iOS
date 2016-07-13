
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // register user defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        let defaultValues = [
            UserDefaultsKey.mostRecentKeyboard : KeyboardType.Aeiou.rawValue,
            UserDefaultsKey.lastMessage : ""
        ]
        defaults.registerDefaults(defaultValues as! [String : AnyObject])
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }

}

