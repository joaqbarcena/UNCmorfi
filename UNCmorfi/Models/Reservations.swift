import Foundation

struct ReservationLogin {
    //The image path of captcha also needs session info, so instead sending cookies...
    let path:String
    let token:String
    let captchaText:String?
    let captchaImage:Data?
    let cookies:[CodableCookie]?
    let code:String
    
    private enum CodingKeys: String, CodingKey {
        case path
        case token
        case captchaText
        case captchaImage
        case cookies
        case code
    }
}

extension ReservationLogin {
    func copy(withPath:String?=nil,
              withToken:String?=nil,
              withCaptchaText:String?=nil,
              withCaptchaImage:Data?,
              withCookies:[CodableCookie]?=nil,
              withCode:String?=nil
              ) -> ReservationLogin {
        return ReservationLogin(path: withPath ?? self.path, token: withToken ?? self.token, captchaText: withCaptchaText ?? self.captchaText, captchaImage: withCaptchaImage, cookies: withCookies ?? self.cookies, code: withCode ?? self.code)
    }
}

//Codable extension
//Get out her a bailar swift jaja https://stackoverflow.com/questions/34728518/swift-can-i-call-a-struct-default-memberwise-init-from-my-custom-init-method
extension ReservationLogin:Codable {

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        path = try values.decode(String.self, forKey: .path)
        token = try values.decode(String.self, forKey: .token)
        code = try values.decode(String.self, forKey: .code)

        if let captchaTextTry = try values.decodeIfPresent(String.self, forKey: .captchaText){
            captchaText = captchaTextTry
        } else {
            captchaText = nil
        }

        if let captchaImageb64 = try values.decodeIfPresent(String.self, forKey: .captchaImage){
            captchaImage = Data(base64Encoded: captchaImageb64)
        } else {
            captchaImage = nil
        }

        if let cookiesPresent = try values.decodeIfPresent([CodableCookie].self, forKey: .cookies){
            cookies = cookiesPresent
        } else {
            cookies = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        try container.encode(token, forKey: .token)
        try container.encode(code, forKey: .code)
        try container.encode(cookies, forKey: .cookies)
        if let captchaText = captchaText {
            try container.encode(captchaText, forKey: .captchaText)
        }
    }
    
    public static func load(code:String) -> ReservationLogin? {
        let reservationLoginString = UserDefaults.standard.data(forKey: code)
        if reservationLoginString != nil {
            return try? JSONDecoder().decode(ReservationLogin.self, from: reservationLoginString!)
        }
        return nil
    }
    
    public func save() {
        let lastReservationLogin = try? JSONEncoder().encode(self)
        if lastReservationLogin != nil {
            UserDefaults.standard.set(lastReservationLogin!, forKey: self.code)
        }
    }
    
    public func deleteFromStorage() {
        UserDefaults.standard.removeObject(forKey: self.code)
    }
}

struct CodableCookie {
    let name:String
    let value:String
    //let sessionOnly:Bool
    let domain:String
    //let created:String //This is date so must parse
    
    private enum CodingKeys: String, CodingKey {
        case name
        case value
        case domain
    }
}

extension CodableCookie : Codable{
    init (from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        value = try values.decode(String.self, forKey:.value)
        domain = try values.decode(String.self, forKey: .domain)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(value, forKey: .value)
        try container.encode(domain, forKey: .domain)
    }
}

extension CodableCookie {
    func toCookie() -> HTTPCookie? {
        return HTTPCookie(properties:[
            HTTPCookiePropertyKey.name : self.name,
            HTTPCookiePropertyKey.value : self.value,
            HTTPCookiePropertyKey.domain : self.domain,
            //Harcodeo cosmico, without this httpCookie is nil
            HTTPCookiePropertyKey.path : "/",
            HTTPCookiePropertyKey.secure : "FALSE",
            HTTPCookiePropertyKey.expires : "(null)"
            ])
    }
    
    public static func fromCookie(cookie:HTTPCookie) -> CodableCookie {
        return CodableCookie(name: cookie.name, value:cookie.value, domain:cookie.domain)
    }
}

struct ReservationStatus : Codable {
    let reservationResult:ReservationResult?
    let path:String?
    let token:String?
}

enum ReservationResult : String, Codable {
    case reserved
    case unavailable
    case soldout
    case invalid
    case redoLogin
    
    //this is to complain kitura 's test
    case empty = ""
}

// MARK: Reservation actions

enum ReservationAction {
    case getLogin
    case doLogin
    case getReservation
    case doReservation
    //case doCancel ?
}
