//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 23/05/21.
//

import Foundation
import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    var localFeed: [LocalFeedImage] {
        feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func delete(in context: NSManagedObjectContext, andSave save: Bool) throws {
        try ManagedCache.find(in: context).map(context.delete)
        if save { try context.save() }
    }
}
