import UIKit
import SafariServices

public typealias TwitterLoginCompletion = ((TwitterLoginState) -> Void)

public class TwitterLoginKit: NSObject {
    public static let shared = TwitterLoginKit()
    private override init() {}

    private var authConfig: TwitterAuthConfig?
    private var urlParser: TwitterLoginURLParser?
    private var mobileSSO: TwitterMobileSSO?
    private var webAuthenticationFlow: TwitterWebAuthenticationFlow?

    public func start(withConsumerKey consumerKey: String, consumerSecret: String) {
        authConfig = TwitterAuthConfig(withConsumerKey: consumerKey, consumerSecret: consumerSecret)
    }

    public func login(withViewController viewController: UIViewController, completion: @escaping TwitterLoginCompletion) {
        guard let authConfig = authConfig else {
            assertionFailure("Attempted to call TwitterLoginKit methods before calling the requisite start method. You must call TwitterLoginKit.shared.start(withConsumerKey:consumerSecret:) before calling any other methods.")
            return
        }
        let urlParser = TwitterLoginURLParser(authConfig: authConfig)
        self.urlParser = urlParser
        assert(urlParser.hasValidURLScheme(), "Attempt made to Log in without a valid Twitter Kit URL Scheme set up in the app settings. Please see https://dev.twitter.com/twitterkit/ios/installation for more info.")
        mobileSSO = TwitterMobileSSO(authConfig: authConfig, urlParser: urlParser)
        mobileSSO!.attemptAppLogin(withCompletion: { [weak viewController] (state) in
            switch state {
            case .success:
                completion(state)
            case .failure(let error as NSError):
                if error.domain == TwitterLoginErrorDomain && error.code == TwitterLoginErrorCode.cancelled.rawValue {
                    // The user tapped "Cancel"
                    completion(state)
                } else {
                    // There wasn't a Twitter app
                    guard let viewController = viewController else {return}
                    self.performWebBasedLogin(viewController, completion: completion)
                }
            }
        })
    }

    public func performWebBasedLogin(_ viewController: UIViewController, completion: @escaping TwitterLoginCompletion) {
        guard let authConfig = authConfig, let urlParser = urlParser else {return}
        webAuthenticationFlow = TwitterWebAuthenticationFlow(authConfig: authConfig, urlParser: urlParser)
        webAuthenticationFlow?.beginAuthenticationFlow({ (vc) in
            viewController.present(vc, animated: true, completion: nil)
        }, completion: { (state) in
            if let vc = viewController.presentedViewController as? SFSafariViewController {
                DispatchQueue.main.async {
                    vc.dismiss(animated: true, completion: {
                        completion(state)
                    })
                }
            } else {
                completion(state)
            }
        })
    }
}

public extension TwitterLoginKit {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let mobileSSO = mobileSSO else {return false}
        if mobileSSO.verifyOauthTokenResponse(fromURL: url) {
            return webAuthenticationFlow?.resumeAuthentication(withRedirectURL: url) ?? false
        } else {
            return mobileSSO.process(redirectURL: url)
        }
    }
}
