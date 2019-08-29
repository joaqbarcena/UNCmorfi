//
//  UNCComedor.swift
//  UNCmorfi
//
//  Created by George Alegre on 4/23/17.
//
//  LICENSE is at the root of this project's repository.
//

import Foundation
import UIKit

public enum Result<A> {
    case success(A)
    case failure(Error)
}

public final class UNCComedor {
    // MARK: Singleton
    public static let api = UNCComedor()
    private init() {}
    
    // MARK: URLSession
    private let session = URLSession.shared
    
    // MARK: API endpoints
    private static let baseURL = URL(string: "https://frozen-sierra-45328.herokuapp.com/")!
    private static let baseImageURL = URL(string: "https://asiruws.unc.edu.ar/foto/")!

    // MARK: Helpers
    
    /**
     Use as first error handling method of any type of URLSession task.
     - Parameters:
        - error: an optional error found in the task completion handler.
        - res: the `URLResponse` found in the task completion handler.
     - Returns: if an error is found, a custom error is returned, else `nil`.
     */
    private static func handleAPIResponse(error: Error?, res: URLResponse?) -> Error? {
        guard error == nil else {
            // TODO handle client error
            //            handleClientError(error)
            return error!
        }
        
        guard let httpResponse = res as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                print("response = \(res!)")
                // TODO: create my own errors
                //            handleServerError(res)
                return NSError()
        }
        
        return nil
    }
    
    // MARK: - Public API methods
    func getUsers(from codes: [String], callback: @escaping (_ result: Result<[User]>) -> Void) {
        guard !codes.isEmpty else {
            callback(.success([]))
            return
        }
        
        // Prepare the request and its parameters.
        var request = URLComponents(string: UNCComedor.baseURL.appendingPathComponent("users").absoluteString)!
        request.queryItems = [URLQueryItem(name: "codes", value: codes.joined(separator: ","))]
        
        // Send the request and setup the callback.
        let task  = session.dataTask(with: request.url!) { data, res, error in
            // Check for errors and exit early.
            let customError = UNCComedor.handleAPIResponse(error: error, res: res)
            guard customError == nil else {
                callback(.failure(customError!))
                return
            }
            
            guard let data = data else {
                callback(.failure(NSError()))
                // TODO: create my own errors
                return
            }
            
            // Decode data.
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let users: [User]
            do {
                users = try decoder.decode([User].self, from: data)
            } catch {
                callback(.failure(NSError()))
                return
            }

            callback(.success(users))
        }
        
        task.resume()
    }
    
    func getUserImage(from code: String, callback: @escaping (_ result: Result<UIImage>) -> Void) {
        let url = UNCComedor.baseImageURL.appendingPathComponent(code)
        let task = session.dataTask(with: url) { data, res, error in
            // Check for errors and exit early.
            let customError = UNCComedor.handleAPIResponse(error: error, res: res)
            guard customError == nil else {
                callback(.failure(customError!))
                return
            }
            
            guard let data = data else {
                callback(.failure(NSError()))
                // TODO create my own errors
                return
            }
            
            guard let image = UIImage(data: data) else {
                callback(.failure(NSError()))
                return
            }
            
            callback(.success(image))
        }
        
        task.resume()
    }
    
    func getMenu(callback: @escaping (_ result: Result<Menu>) -> Void) {
        let task = session.dataTask(with: UNCComedor.baseURL.appendingPathComponent("menu")) { data, res, error in
            // Check for errors and exit early.
            let customError = UNCComedor.handleAPIResponse(error: error, res: res)
            guard customError == nil else {
                callback(.failure(customError!))
                return
            }
            
            guard let data = data else {
                    callback(.failure(NSError()))
                    // TODO create my own errors
                    return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let menu: Menu
            do {
                menu = try decoder.decode(Menu.self, from: data)
            } catch {
                callback(.failure(NSError()))
                return
            }

            callback(.success(menu))
        }
        
        task.resume()
    }
    
    func getServings(callback: @escaping (_ result: Result<Servings>) -> Void) {
        let task: URLSessionDataTask = session.dataTask(with: UNCComedor.baseURL.appendingPathComponent("servings")) { data, res, error in
            // Check for errors and exit early.
            let customError = UNCComedor.handleAPIResponse(error: error, res: res)
            guard customError == nil else {
                callback(.failure(customError!))
                return
            }
            
            guard let data = data else {
                callback(.failure(NSError()))
                // TODO create my own errors
                return
            }
            
            // Parse received data.
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let servings: Servings
            do {
                servings = try decoder.decode(Servings.self, from: data)
            } catch {
                callback(.failure(NSError()))
                return
            }

            callback(.success(servings))
        }
        
        task.resume()
    }
}

// MARK: Reservation API'S
extension UNCComedor {
    static var remote = true
    private static let successLogin = "3616" //3614 es que esta todo mal
    private static let baseReservationURL = "http://comedor.unc.edu.ar/reserva"
    
    //Sesssion that doesnt persist cookies, so they are saved at real end-client
    private static let restSession:URLSession = {
        let defaultRestConfig = URLSessionConfiguration.default.copy() as! URLSessionConfiguration
        defaultRestConfig.httpCookieAcceptPolicy = .never
        defaultRestConfig.httpCookieStorage = nil
        defaultRestConfig.httpShouldSetCookies = true
        return URLSession(configuration: defaultRestConfig)
    }()
    
    
    // MARK: Reservations APIError
    
    enum ReservationAPIError : Error {
        //Unparsable reservation token/path
        case pathUnparseable
        case tokenUnparseable
        case captchaUnparseable
        
        //Captcha/Session inconsistences
        case captchaTextEmpty
        case cookiesEmpty
        case cookiesInvalid
        
        case unimplementedFunction
    }
    
    func getReservationLogin(to code: String, callback: @escaping (_ result: Result<ReservationLogin>) -> Void) {
        if UNCComedor.remote {
            getReservationLoginRemote(to: code, callback: callback)
        } else {
            getReservationLogin(of: code, callback: callback)
        }
    }
    
    func getReservation(with reservationLogin:ReservationLogin, doInBackground:Bool = false, callback: @escaping (_ result: Result<ReservationStatus>) -> Void){
        if UNCComedor.remote {
            getReservationRemote(with: reservationLogin, doInBackground: doInBackground, callback: callback)
        } else {
            doReservation(withAction: .doReservation, reservationLogin: reservationLogin, callback: callback)
        }
    }
    
    // MARK: Helper functions
    
    static func reservationResult(_ result:Result<ReservationStatus>) -> (String, Bool){
        let resultText:String
        var redoLogin = false
        switch result {
        case let .success(reservationStatus):
            switch reservationStatus.reservationResult {
            case .reserved?:
                resultText = "balance.reservation.reserved.label".localized()
            case .soldout?:
                resultText = "balance.reservation.soldout.label".localized()
            case .unavailable?:
                resultText = "balance.reservation.unavailable.label".localized()
            case .redoLogin?:
                resultText = "balance.reservation.redoLogin.label".localized()
                redoLogin = true
            default:
                resultText = "balance.reservation.error.label".localized()
                //redoLogin = true
            }
        case .failure(_):
            resultText = "balance.reservation.error.label".localized()
        }
        return (resultText, redoLogin)
    }
    
    /**
     Boundary generator
     returns a boundary with 16 trailing random characters
     */
    private static func boundary() -> String {
        return "----WebKitFormBoundary\(String((0..<16).map{ _ in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()!}))"
    }
    /**
     Parser to get application submit path, token and alert message
     This is done by regex, but i would like replace it with soup parser
     - Parameters:
     - page : the html page
     - getAlertMessage? : the last stage has an alert message, and this search
     and retrieve that message
     */
    private static func parseReservationPage(page:String, getAlertMessage:Bool=false) -> Result<(path:String, token:String, alertMessage:String?)> {
        
        //Search/scrap submit path
        guard let pathRange = page.range(of: "/aplicacion\\.php.*onsubmit", options: .regularExpression)
            else {
                return .failure(ReservationAPIError.pathUnparseable)
        }
        let path = String(page[pathRange].dropLast("' onsubmit".count))
        
        //Search/scrap token
        guard let tokenRange = page.range(of: "id='cstoken'.*/>", options: .regularExpression)
            else {
                return .failure(ReservationAPIError.tokenUnparseable)
        }
        let token = String(page[tokenRange][page[tokenRange].range(of: "value='.*'", options: .regularExpression)!]
            .dropFirst("value='".count)
            .dropLast("'".count))
        
        var alertMessage:String? = nil
        if getAlertMessage {
            if let alertRange = page.range(of: "<script language='JavaScript'>alert\\(.*;</script></div>", options: .regularExpression){
                let alert = page[alertRange]
                if let idxL = alert.range(of: "alert('"),
                    let idxU = alert.range(of: ");") {
                    alertMessage = String(alert[idxL.upperBound..<idxU.lowerBound])
                }
                // else { return .failure(APIError.alertUnparseable) } ???
            }
        }
        //<td class="ei-cuadro-fila 4">CONSUMIDO</td>
        return .success((path, token, alertMessage))
    }
    
    /**
     Request builder for differents stages
     - Parameters:
     -  action : ReservationAction = (getLogin, doLogin, doProcess)
     -  withPath : String = Path where it sends the form data
     -  withToken : String = Token sended inside the form data (always)
     - Returns: The request ready to use with dataTask
     */
    private static func buildRequest(_ action:ReservationAction, _ reservationLogin:ReservationLogin, withBoundary boundary:String="") -> URLRequest {
        return buildRequest(action,
                            withPath: reservationLogin.path,
                            withToken: reservationLogin.token,
                            withBoundary:boundary,
                            withCode: reservationLogin.code,
                            withCaptcha: reservationLogin.captchaText ?? "",
                            withCookies: reservationLogin.cookies ?? [])
    }
    
    private static func buildRequest(_ action:ReservationAction, withPath path:String = "/",
                                     withToken token:String = "",
                                     withBoundary boundary:String="",
                                     withCode code:String="",
                                     withCaptcha captcha:String="",
                                     withCookies cookies:[CodableCookie]=[]) -> URLRequest {
        
        var infoRequest:(httpMethod: String, httpBody: String)
        var headers = [
            "cache-control": "no-cache"
        ]
        switch action {
        case .getLogin:
            infoRequest = ("GET","")
        case .doLogin:
            infoRequest = ("POST","--\(boundary)\nContent-Disposition: form-data; name=\"cstoken\"\n\n\(token)\n--\(boundary)\nContent-Disposition: form-data; name=\"form_2689_datos\"\n\n\("ingresar")\n--\(boundary)\nContent-Disposition: form-data; name=\"form_2689_datos_implicito\"\n\n\n--\(boundary)\nContent-Disposition: form-data; name=\"ef_form_2689_datosusuario\"\n\n\(code)\n--\(boundary)\nContent-Disposition: form-data; name=\"ef_form_2689_datoscontrol\"\n\n\(captcha)\n--\(boundary)--")
        case .doReservation:
            infoRequest = ("POST","--\(boundary)\nContent-Disposition: form-data; name=\"cstoken\"\n\n\(token)\n--\(boundary)\nContent-Disposition: form-data; name=\"ci_2695\"\n\n\("procesar")\n--\(boundary)\nContent-Disposition: form-data; name=\"ci_2695__param\"\n\n\("undefined")\n--\(boundary)--")
        case .getReservation:
            infoRequest = ("POST","--\(boundary)\nContent-Disposition: form-data; name=\"cstoken\"\n\n\(token)\n--\(boundary)\nContent-Disposition: form-data; name=\"ci_2695\"\n\n\("consu_rese")\n--\(boundary)\nContent-Disposition: form-data; name=\"ci_2695__param\"\n\n\("undefined")\n--\(boundary)--")
        }
        
        var request = URLRequest(url: URL(string: UNCComedor.baseReservationURL + path)!)
        if infoRequest.httpMethod == "POST" {
            //TODO read meta header in response
            request.httpBody = infoRequest.httpBody.data(using: .isoLatin1)
            headers["Content-Type"] = "multipart/form-data; boundary=" + boundary
        }
        //mapea las codableCookies a cookies que no sean nil
        let cookies = cookies.compactMap({ $0.toCookie() })
        if !cookies.isEmpty {
            headers.merge(HTTPCookie.requestHeaderFields(with: cookies)){ (_,new) in new }
        }
        request.httpMethod = infoRequest.httpMethod
        request.allHTTPHeaderFields = headers
        
        return request
    }
    
    
    // MARK: Public Reservation API's
    
    
    // MARK: Reservation api's
    func getReservationLoginRemote(to code:String, callback: @escaping (_ result: Result<ReservationLogin>) -> Void){
        
        var request = URLComponents(string: UNCComedor.baseURL.appendingPathComponent("reservation").appendingPathComponent("login").absoluteString)!
        request.queryItems = [URLQueryItem(name: "code", value: code)]
        
        let task = session.dataTask(with: request.url!) {
            data, res, error in
            let customError = UNCComedor.handleAPIResponse(error: error, res: res)
            guard customError == nil else {
                callback(.failure(customError!))
                return
            }
            
            guard let data = data else {
                callback(.failure(NSError()))
                // TODO: follow the same criteria
                return
            }
            // Decode data.
            let decoder = JSONDecoder()
            
            let reservationLogin:ReservationLogin
            do {
                reservationLogin = try decoder.decode(ReservationLogin.self, from: data)
            } catch {
                callback(.failure(NSError()))
                return
            }
            
            callback(.success(reservationLogin))
            
        }
        task.resume()
    }
    
    func getReservationRemote(with reservationLogin:ReservationLogin, doInBackground:Bool = false, callback: @escaping (_ result: Result<ReservationStatus>) -> Void){
        
        let requestUrl = URLComponents(string: UNCComedor.baseURL.appendingPathComponent("reservation").appendingPathComponent("reserve").absoluteString)!
        
        var request = URLRequest(url: requestUrl.url!)
        request.allHTTPHeaderFields = ["Content-Type" : "application/json"]
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(reservationLogin)
        
        let completionClosure:(Data?,URLResponse?,Error?) -> Void = {
            data, res, error in
            //print(error,data,res)
            let customError = UNCComedor.handleAPIResponse(error: error, res: res)
            guard customError == nil else {
                callback(.failure(customError!))
                return
            }
            
            guard let data = data else {
                callback(.failure(NSError()))
                // TODO: follow the same criteria
                return
            }
            // Decode data.
            let decoder = JSONDecoder()
            
            let reservationStatus:ReservationStatus
            do {
                reservationStatus = try decoder.decode(ReservationStatus.self, from: data)
            } catch {
                callback(.failure(NSError()))
                return
            }
            callback(.success(reservationStatus))
        }
        
        let task:URLSessionTask
        if doInBackground {
            task = URLSessionBackground(withId: reservationLogin.code, completionHandler: completionClosure)
                .urlSession
                .downloadTask(with: request)
            
        } else {
            task = session.dataTask(with: request, completionHandler: completionClosure)
        }
        task.resume()
    }
    
    /**
     First stage to get the reservation
     of (code):String = Code of user
     */
    func getReservationLogin(of code: String, callback: @escaping (_ result: Result<ReservationLogin>) -> Void) {
        //Check empty-ness, maybe it's unnecesary
        guard !code.isEmpty else {
            callback(.failure(NSError())) //TODO: Change this
            return
        }
        
        let task = UNCComedor.restSession.dataTask(with: UNCComedor.buildRequest(.getLogin)){ data, res, error in
            //Exit early
            let httpError = UNCComedor.handleAPIResponse(error: error, res: res)
            guard httpError == nil else {
                callback(.failure(httpError!))
                return
            }
            
            guard let data = data,
                let dataString = String(data: data, encoding: .isoLatin1) else {
                    callback(.failure(NSError()))
                    return
            }
            
            guard let res = res as? HTTPURLResponse else {
                callback(.failure(NSError()))
                return
            }
            
            var cookies:[CodableCookie] = []
            if let headers = res.allHeaderFields as? [String:String] {
                let httpCookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: res.url!)
                cookies = httpCookies.map({
                    CodableCookie.fromCookie(cookie: $0)//🍪
                })
            }
            
            guard !cookies.isEmpty else {
                callback(.failure(ReservationAPIError.cookiesEmpty))
                return
            }
            
            switch(UNCComedor.parseReservationPage(page: dataString)){
            //Parsing error
            case .failure(let parserError):
                callback(.failure(parserError))
                
            //getLogin results succesfully
            case .success(let (path,token,_)):
                guard let captchaRange = dataString.range(of: "/aplicacion\\.php.*?ts=mostrar_captchas_efs.*?>", options: .regularExpression) else {
                    callback(.failure(ReservationAPIError.captchaUnparseable))
                    return
                }
                let captchaPath = String(dataString[captchaRange].dropLast(4))
                let task = UNCComedor.restSession.dataTask(with: UNCComedor.buildRequest(.getLogin, withPath:captchaPath, withCookies:cookies)) {
                    data, res, error in
                    
                    //Exit Early
                    let httpError = UNCComedor.handleAPIResponse(error: error, res: res)
                    guard httpError == nil else {
                        callback(.failure(httpError!))
                        return
                    }
                    guard let data = data else {
                        callback(.failure(ReservationAPIError.captchaUnparseable)) //TODO: maybe this should never fire
                        return
                    }
                    
                    callback(.success(ReservationLogin(path:path, token:token, captchaText:nil, captchaImage:data, cookies:cookies, code:code)))
                }
                task.resume()
                
            }
        }
        task.resume()
    }
    
    /**
     Does the reservation login for now its used internally
     takes the reservationLogin resolved from getLogin (and correct captcha)
     */
    func doReservationLogin(with reservationLogin:ReservationLogin, callback: @escaping(_ result:Result<ReservationLogin>) -> Void){
        
        //Exit early
        guard reservationLogin.captchaText != nil else {
            callback(.failure(ReservationAPIError.captchaTextEmpty))
            return
        }
        guard let cookies = reservationLogin.cookies else {
            callback(.failure(ReservationAPIError.cookiesEmpty))
            return
        }
        guard !cookies.filter({$0.name == "TOBA_SESSID"}).isEmpty else {
            callback(.failure(ReservationAPIError.cookiesInvalid))
            return
        }
        
        //Generate a random boundary
        let boundary = UNCComedor.boundary()
        
        //Makes sure than will not reuse another session cookies
        let task = UNCComedor.restSession.dataTask(with: UNCComedor.buildRequest(.doLogin, reservationLogin, withBoundary: boundary)){
            data, res, error in
            
            //Exit early
            let httpError = UNCComedor.handleAPIResponse(error: error, res: res)
            guard httpError == nil else {
                callback(.failure(httpError!))
                return
            }
            
            guard let data = data,
                let dataString = String(data: data, encoding: .isoLatin1) else {
                    callback(.failure(NSError()))
                    return
            }
            
            switch(UNCComedor.parseReservationPage(page: dataString)){
            //doLogin results (almost) succesfully
            case .success(let (path,token,_)) where path.hasSuffix(UNCComedor.successLogin):
                callback(.success(ReservationLogin(path: path, token: token, captchaText: nil, captchaImage: nil, cookies: reservationLogin.cookies, code: reservationLogin.code)))
                return
                
            //Parsing error, analizar que tipo de error expiro la session ?
            case .failure(let parserError):
                callback(.failure(parserError))
                
            default:
                callback(.failure(ReservationAPIError.pathUnparseable))
            }
        }
        task.resume()
    }
    
    
    /**
     Do reservation (getStatus/doReservation)
     Checks if path ends with 3616, this means that doReservationLogin was made before, and user is logged
     
     Flows :
     - 1st enrty after getLogin -> nextPath == nil => doReservationLogin{ doReservation (status, nextPath) }
     - 2nd entry after 1st entr -> nextPath != nil => doReservation (status, nextPath)
     
     */
    func doReservation(withAction action:ReservationAction, reservationLogin:ReservationLogin,
                       callback: @escaping (_ result:Result<ReservationStatus>) -> Void){
        
        let doReservationClosure:(ReservationLogin,Bool) -> Void = { reservationLogin, sendToken in
            switch action {
                
            case .doReservation:
                let task = UNCComedor.restSession.dataTask(with:
                UNCComedor.buildRequest(.doReservation, reservationLogin, withBoundary: UNCComedor.boundary())){
                    data, res, error in
                    
                    //Exit early, Here maybe the server is down so cookies are no longer valid ...
                    let httpError = UNCComedor.handleAPIResponse(error: error, res: res)
                    guard httpError == nil else {
                        callback(.failure(httpError!))
                        return
                    }
                    
                    guard let data = data,
                        let dataString = String(data: data, encoding: .isoLatin1) else {
                            callback(.failure(NSError()))
                            return
                    }
                    
                    //Parse and get the alertmessage if it's present
                    /*
                     May have 2 errors :
                     - Session expires (tokenUnparseable? luckly)
                     - incorrectPath (throws alertMessage = nil)
                     */
                    switch(UNCComedor.parseReservationPage(page: dataString, getAlertMessage: true)){
                        
                    //doProcess results (almost) succesfully
                    case .success(let (path,token,alert?)):
                        //NSLog(alert)
                        let result:ReservationResult
                        if alert.contains("SE REALIZO LA RESERVA") {
                            result = .reserved
                        } else if alert.contains("NO HAY MAS RESERVAS DISPONIBLES") {
                            result = .soldout
                        } else {
                            result = .unavailable
                        }
                        callback(.success(ReservationStatus(reservationResult:result, path:path,
                            token: reservationLogin.token != token || sendToken ? token : nil)))
                        
                    case .success(let (path,token,nil)) where path.hasSuffix(UNCComedor.successLogin):
                        print(dataString)
                        callback(.success(ReservationStatus(reservationResult:.invalid, path:path, token: sendToken ? token : nil)))
                        
                    default: //case .failure(_): //This is pathUnparseable or tokenUnparseable
                        callback(.success(ReservationStatus(reservationResult:.redoLogin, path:nil, token:nil))) //callback(.failure(parserError))
                    }
                }
                task.resume()
                
                //Get reservation
                //case .getReservation:
                
            default :
                callback(.failure(ReservationAPIError.unimplementedFunction))
            }
        }
        
        //If path is updated inside the profile panel
        if reservationLogin.path.hasSuffix(UNCComedor.successLogin) {
            doReservationClosure(reservationLogin,false)
        } else {
            doReservationLogin(with: reservationLogin){
                result in
                switch result {
                case let .success(reservationLogin):
                    doReservationClosure(reservationLogin,true)
                case .failure(let error) where error is ReservationAPIError : //Session expires (done by tokenUnparseable), captcha could change or empty cookie
                    callback(.success(ReservationStatus(reservationResult:.redoLogin, path:nil, token: nil)))
                case .failure(let error):
                    callback(.failure(error))
                }
            }
        }
    }
    
}


