//
//  CODUserDefault+Extension.swift
//  COD
//
//  Created by XinHoo on 2019/3/6.
//  Copyright © 2019 XinHoo. All rights reserved.
//

public var CODUserDefaults = UserDefaults.standard

public extension UserDefaults {
    
    class func cod_objectForKey(_ key: String, defaultValue: AnyObject? = nil) -> AnyObject? {
        if (defaultValue != nil) && cod_objectForKey(key) == nil {
            return defaultValue
        }
        return CODUserDefaults.object(forKey: key) as AnyObject?
    }
    
    class func cod_integerForKey(_ key: String, defaultValue: Int? = nil) -> Int {
        if (defaultValue != nil) && cod_objectForKey(key) == nil {
            return defaultValue!
        }
        return CODUserDefaults.integer(forKey: key)
    }
    
    class func cod_boolForKey(_ key: String, defaultValue: Bool? = nil) -> Bool {
        if (defaultValue != nil) && cod_objectForKey(key) == nil {
            return defaultValue!
        }
        return CODUserDefaults.bool(forKey: key)
    }
    
    class func cod_floatForKey(_ key: String, defaultValue: Float? = nil) -> Float {
        if (defaultValue != nil) && cod_objectForKey(key) == nil {
            return defaultValue!
        }
        return CODUserDefaults.float(forKey: key)
    }
    
    class func cod_doubleForKey(_ key: String, defaultValue: Double? = nil) -> Double {
        if (defaultValue != nil) && cod_objectForKey(key) == nil {
            return defaultValue!
        }
        return CODUserDefaults.double(forKey: key)
    }
    
    class func cod_stringForKey(_ key: String, defaultValue: String? = nil) -> String? {
        if (defaultValue != nil) && cod_objectForKey(key) == nil {
            return defaultValue!
        }
        return CODUserDefaults.string(forKey: key)
    }
    
    class func cod_dataForKey(_ key: String, defaultValue: Data? = nil) -> Data? {
        if (defaultValue != nil) && cod_objectForKey(key) == nil {
            return defaultValue!
        }
        return CODUserDefaults.data(forKey: key)
    }
    
    class func cod_URLForKey(_ key: String, defaultValue: URL? = nil) -> URL? {
        if (defaultValue != nil) && cod_objectForKey(key) == nil {
            return defaultValue!
        }
        return CODUserDefaults.url(forKey: key)
    }
    
    class func cod_arrayForKey(_ key: String, defaultValue: [AnyObject]? = nil) -> [AnyObject]? {
        if (defaultValue != nil) && cod_objectForKey(key) == nil {
            return defaultValue!
        }
        return CODUserDefaults.array(forKey: key) as [AnyObject]?
    }
    
    class func cod_dictionaryForKey(_ key: String, defaultValue: [String : AnyObject]? = nil) -> [String : AnyObject]? {
        if (defaultValue != nil) && cod_objectForKey(key) == nil {
            return defaultValue!
        }
        return CODUserDefaults.dictionary(forKey: key) as [String : AnyObject]?
    }

    
    class func cod_setObject(_ key: String, value: AnyObject?) {
        if value == nil {
            CODUserDefaults.removeObject(forKey: key)
        } else {
            CODUserDefaults.set(value, forKey: key)
        }
        CODUserDefaults.synchronize()
    }
    
    class func cod_setInteger(_ key: String, value: Int) {
        CODUserDefaults.set(value, forKey: key)
        CODUserDefaults.synchronize()
    }
    
    class func cod_setBool(_ key: String, value: Bool) {
        CODUserDefaults.set(value, forKey: key)
        CODUserDefaults.synchronize()
    }
    

    class func cod_setFloat(_ key: String, value: Float) {
        CODUserDefaults.set(value, forKey: key)
        CODUserDefaults.synchronize()
    }
    

    class func cod_setString(_ key: String, value: String?) {
        CODUserDefaults.set(value, forKey: key)
        CODUserDefaults.synchronize()
    }
    

    class func cod_setData(_ key: String, value: Data) {
        self.cod_setObject(key, value: value as AnyObject?)
    }
    

    class func cod_setArray(_ key: String, value: [AnyObject]) {
        self.cod_setObject(key, value: value as AnyObject?)
    }

    class func cod_setDictionary(_ key: String, value: [String : AnyObject]) {
        self.cod_setObject(key, value: value as AnyObject?)
    }


    class func clearAllUserDefaultsData() {
        let userDefaults = CODUserDefaults
        let dic = userDefaults.dictionaryRepresentation()
        for item in dic {
            userDefaults.removeObject(forKey: item.key)
        }
        userDefaults.synchronize()
    }
}
