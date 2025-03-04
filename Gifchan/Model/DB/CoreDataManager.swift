//
//  CoreDataManager.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import CoreData
import SwiftUI

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "GifDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ Помилка ініціалізації CoreData: \(error)")
            }
        }
        context = container.viewContext
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print("❌ Помилка збереження в CoreData: \(error)")
        }
    }
    
    func addToFavorites(gifURL: String) {
        let newGif = FavoriteGif(context: context)
        newGif.id = UUID().uuidString
        newGif.url = gifURL
        newGif.isFavorite = true
        save()
    }

    func removeFromFavorites(gifURL: String) {
        let request: NSFetchRequest<FavoriteGif> = FavoriteGif.fetchRequest()
        request.predicate = NSPredicate(format: "url == %@", gifURL)
        
        do {
            let results = try context.fetch(request)
            for gif in results {
                context.delete(gif)
            }
            save()
        } catch {
            print("❌ Помилка видалення GIF: \(error)")
        }
    }

    func fetchFavorites() -> [FavoriteGif] {
        let request: NSFetchRequest<FavoriteGif> = FavoriteGif.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Помилка отримання улюблених GIF: \(error)")
            return []
        }
    }
    func isGifFavorite(gifURL: String) -> Bool {
        let request: NSFetchRequest<FavoriteGif> = FavoriteGif.fetchRequest()
        request.predicate = NSPredicate(format: "url == %@", gifURL)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("❌ Помилка перевірки GIF у CoreData: \(error)")
            return false
        }
    }
}

