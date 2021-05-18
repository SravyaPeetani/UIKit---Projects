//
//  File.swift
//  
//
//  Created by Jastin on 16/5/21.
//

import Fluent
import Vapor

final class UserToken: ContenModel
{
   static var schema: String = "user_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Parent(key: "user_id")
    var user: User
    
    init() { }
    
    init(id: UUID? = nil, value: String, UserID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = UserID
    }
}

extension UserToken: ModelTokenAuthenticatable {
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user
 
    var isValid: Bool {
        true
    }
}
