//
//  ConfigurationProxy.swift
//  YggdrasilNetwork
//
//  Created by Neil Alexander on 07/01/2019.
//

import UIKit
import Yggdrasil
import NetworkExtension

class ConfigurationProxy {

    private var json: Data? = nil
    private var dict: [String: Any]? = nil
    
    init() {
        self.json = MobileGenerateConfigJSON()
        do {
            try self.convertToDict()
        } catch {
            NSLog("ConfigurationProxy: Error deserialising JSON (\(error))")
        }
        self.fix()
    }
    
    init(json: Data) throws {
        self.json = json
        try self.convertToDict()
        self.fix()
    }
    
    private func fix() {
        self.set("AdminListen", to: "none")
        self.set("IfName", to: "none")
        self.set("IfMTU", to: 65535)
                
        if self.get("AutoStart") == nil {
            self.set("AutoStart", to: ["WiFi": false, "Mobile": false] as [String: Bool])
        }
        
        let interfaces = self.get("MulticastInterfaces") as? [String] ?? []
        if interfaces.contains(where: { $0 == "lo0" }) {
            self.add("lo0", in: "MulticastInterfaces")
        }
    }
    
    func get(_ key: String) -> Any? {
        if let dict = self.dict {
            if dict.keys.contains(key) {
                return dict[key]
            }
        }
        return nil
    }
    
    func get(_ key: String, inSection section: String) -> Any? {
        if let dict = self.get(section) as? [String: Any] {
            if dict.keys.contains(key) {
                return dict[key]
            }
        }
        return nil
    }
    
    func add(_ value: Any, in key: String) {
        if self.dict != nil {
            if self.dict![key] as? [Any] != nil {
                var temp = self.dict![key] as? [Any] ?? []
                temp.append(value)
                self.dict!.updateValue(temp, forKey: key)
            }
        }
    }
    
    func remove(_ value: String, from key: String) {
        if self.dict != nil {
            if self.dict![key] as? [String] != nil {
                var temp = self.dict![key] as? [String] ?? []
                if let index = temp.firstIndex(of: value) {
                    temp.remove(at: index)
                }
                self.dict!.updateValue(temp, forKey: key)
            }
        }
    }
    
    func remove(index: Int, from key: String) {
        if self.dict != nil {
            if self.dict![key] as? [Any] != nil {
                var temp = self.dict![key] as? [Any] ?? []
                temp.remove(at: index)
                self.dict!.updateValue(temp, forKey: key)
            }
        }
    }
    
    func set(_ key: String, to value: Any) {
        if self.dict != nil {
            self.dict![key] = value
        }
    }
    
    func set(_ key: String, inSection section: String, to value: Any?) {
        if self.dict != nil {
            if self.dict!.keys.contains(section), let value = value {
                var temp = self.dict![section] as? [String: Any] ?? [:]
                temp.updateValue(value, forKey: key)
                self.dict!.updateValue(temp, forKey: section)
            }
        }
    }
    
    func data() -> Data? {
        do {
            try self.convertToJson()
            return self.json
        } catch {
            return nil
        }
    }
    
    func save(to manager: inout NETunnelProviderManager) throws {
        self.fix()
        if let data = self.data() {
            let providerProtocol = NETunnelProviderProtocol()
            providerProtocol.providerBundleIdentifier = "org.jimber.threebot.extension"
            providerProtocol.providerConfiguration = [ "json": data ]
            providerProtocol.serverAddress = "yggdrasil"
            providerProtocol.username = self.get("EncryptionPublicKey") as? String ?? "(unknown public key)"
            
            let disconnectrule = NEOnDemandRuleDisconnect()
            var rules: [NEOnDemandRule] = [disconnectrule]

            if self.get("WiFi", inSection: "AutoStart") as? Bool ?? false {
                let wifirule = NEOnDemandRuleConnect()
                wifirule.interfaceTypeMatch = .wiFi
                rules.insert(wifirule, at: 0)
            }

            if self.get("Mobile", inSection: "AutoStart") as? Bool ?? false {
                let mobilerule = NEOnDemandRuleConnect()
                mobilerule.interfaceTypeMatch = .cellular
                rules.insert(mobilerule, at: 0)
            }

            manager.onDemandRules = rules
            manager.isOnDemandEnabled = rules.count > 1
            providerProtocol.disconnectOnSleep = rules.count > 1
            
            manager.protocolConfiguration = providerProtocol
            
            manager.saveToPreferences(completionHandler: { (error:Error?) in
                if let error = error {
                    print(error)
                } else {
                    print("Save successfully")
                    NotificationCenter.default.post(name: NSNotification.Name.YggdrasilSettingsUpdated, object: self)
                }
            })
        }
    }
    
    private func convertToDict() throws {
        self.dict = try JSONSerialization.jsonObject(with: self.json!, options: []) as? [String: Any]
    }
    
    private func convertToJson() throws {
        self.json = try JSONSerialization.data(withJSONObject: self.dict as Any, options: .prettyPrinted)
    }
}
