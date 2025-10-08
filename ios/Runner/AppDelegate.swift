import UIKit
import Flutter
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import GoogleMaps
import workmanager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure();
//     GMSServices.provideAPIKey("AIzaSyCQQs_4Y1HdX2DwNQV846H1mZ4vY3lQAS0")
    GMSServices.provideAPIKey("AIzaSyAICTA0Z26Zfr0trCQGuK8RP3jrlJq6XIg")
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
                // Registry in this case is the FlutterEngine that is created in Workmanager's
                // performFetchWithCompletionHandler or BGAppRefreshTask.
                // This will make other plugins available during a background operation.
                GeneratedPluginRegistrant.register(with: registry)
    }
    //WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "rw.lipaquick.contact.sync")
    WorkmanagerPlugin.registerTask(withIdentifier: "rw.lipaquick.contact.sync")
        
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    // ✅ Forward remote notification to Firebase Auth
     override func application(_ application: UIApplication,
                               didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                               fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
         print("[Notifications] 📩 Received remote notification: \(userInfo)")
       if Auth.auth().canHandleNotification(userInfo) {
           print("[FirebaseAuth] ✅ Notification handled by Firebase Auth")
           completionHandler(.noData)
           return
       }

        print("[Notifications] ℹ️ Notification not handled by Firebase Auth, processing normally")
    
       completionHandler(.newData)
     }

     // ✅ Forward incoming URLs (used for Firebase Phone Auth reCAPTCHA)
     override func application(_ app: UIApplication,
                               open url: URL,
                               options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

         print("[DeepLink] 🔗 Received URL: \(url)")

            if Auth.auth().canHandle(url) {
              print("[FirebaseAuth] ✅ URL handled by Firebase Auth")
              return true
            }

            print("[DeepLink] ❌ URL not handled by Firebase Auth")
            return super.application(app, open: url, options: options)
     }
}
