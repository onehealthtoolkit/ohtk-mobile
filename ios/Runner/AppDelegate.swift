import UIKit
import Flutter
import GoogleMaps
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let mapsApiKey: String = Bundle.main.infoDictionary?["GoogleMapApiKey"] as? String ?? "";
    GMSServices.provideAPIKey(mapsApiKey);
    
    FirebaseApp.configure()
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
