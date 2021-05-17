//
//  File.swift
//  
//
//  Created by Jastin on 16/5/21.
//

import Foundation
import Vapor

struct UserController: RouteCollection
{
    func boot(routes: RoutesBuilder) throws {
        
        routes.post("signup", use: signUp)
        routes.grouped(User.authenticator()).post("sign", use: signIn)
    }
    
    func signUp(req: Request) throws -> EventLoopFuture<User>  {
        
        try User.Create.validate(content: req)
        
        let create = try req.content.decode(User.Create.self)
        
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Contraseñas no coinciden")
        }
        
        let user = try User (
            name: create.name,
            email: create.email,
            passwordHash: Bcrypt.hash(create.password)
        )
        return user.save(on: req.db).map{ user }
    }
    
    func signIn(req: Request) throws -> User {
        try req.auth.require(User.self)
    }
}
