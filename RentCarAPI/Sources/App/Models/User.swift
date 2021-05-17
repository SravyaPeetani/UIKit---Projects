//
//  File.swift
//  
//
//  Created by Jastin on 16/5/21.
//

import Fluent
import Vapor

final class User: ContenModel {
    
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "user_name")
    var name: String
    
    @Field(key: "user_email")
    var email: String
    
    @Field(key: "user_password_hash")
    var passwordHash: String
    
    init() {
    }
     init(id: UUID? = nil, name: String, email: String,passwordHash: String)
    {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}

// MARK: Creaation parameters
extension User {
    struct Create: Content {
        var name: String
        var email: String
        var password: String
        var confirmPassword: String
    }
}

// MARK: Validation

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}



