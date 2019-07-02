//
//  Manager.swift
//  Storage
//
//  Created by Valo on 2019/6/25.
//

import SQLiteORM

public struct Manager {
    static let shared = Manager()
    
    var orm: Orm {
        return Orm(config: Config(DBModel.Message.self))
    }
    
}
