//
//  iGridsRetrieveData.swift
//  iGrids Energy Monitor
//
//  Created by Steven Chiu on 2022-02-21.
//

import Foundation

class iGridsRetrieveData : NSObject,  URLSessionDelegate
{
    
    public var get_data_activity_flag = false
    public var status_msg = ""
    public var dataloaded = false
    public var jsonString:String
    
    override init() {
        self.jsonString = ""
        super.init()

        
    }
    
//    func getClientUrlCredential()->URLCredential {
//
//            let userCertificate = certificateHelper.getCertificateNSData(withName: "userCertificateName",
//                                                                         andExtension: "pfx")
//            let userIdentityAndTrust = certificateHelper.extractIdentityAndTrust(fromCertificateData: userCertificate, certPassword: "cert_psw")
//            //Create URLCredential
//            let urlCredential = URLCredential(identity: userIdentityAndTrust.identityRef,
//                                              certificates: userIdentityAndTrust.certArray as [AnyObject],
//                                              persistence: URLCredential.Persistence.permanent)
//
//            return urlCredential
//        }
//
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        
        let authenticationMethod = challenge.protectionSpace.authenticationMethod
        print("authenticationMethod=\(authenticationMethod)")
        if authenticationMethod == NSURLAuthenticationMethodClientCertificate {

            completionHandler(.performDefaultHandling, nil)

        } else if authenticationMethod == NSURLAuthenticationMethodServerTrust {
       //Trust the certificate even if not valid
       //let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust)
            let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, urlCredential)

        }
        
        
    }
    
    func getData(host: String = "", in_query : String = "") -> Void
    {
        self.get_data_activity_flag = true
        self.status_msg = "Refreshing data..."
        self.dataloaded = false
        print("[getDAta]: Remote Host is \(host)")
        if let url = URL( string: "https://\(host)/api?" + in_query) {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            session.dataTask(with: url) { data, response, error in
                if let data = data {
                    if let jsonString1 = String(data: data, encoding: .utf8) {
                        self.jsonString = jsonString1
                        self.status_msg = ""
                        print(self.jsonString)
                        self.get_data_activity_flag = false

                    }
                    
                } else {
                    self.status_msg = "Failed to retrieve..."
                    self.get_data_activity_flag = false

                }
                self.dataloaded = true
                self.get_data_activity_flag = false

                
            }.resume()
        } else {
            self.status_msg = "Connection to Energy Monitor Service failed..."
            self.get_data_activity_flag = false

        }

    }
}

//extension SecTrust {
//
//    var isSelfSigned: Bool? {
//        guard SecTrustGetCertificateCount(self) == 1 else {
//            return false
//        }
//        guard let cert = SecTrustGetCertificateAtIndex(self, 0) else {
//            return nil
//        }
//        return cert.isSelfSigned
//    }
//}
//
//extension SecCertificate {
//
//    var isSelfSigned: Bool? {
//        guard
//            let subject = SecCertificateCopyNormalizedSubjectSequence(self),
//            let issuer = SecCertificateCopyNormalizedIssuerSequence(self)
//        else {
//            return nil
//        }
//        return subject == issuer
//    }
//}


extension Date {
    func getFormattedDate(format: String)-> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
