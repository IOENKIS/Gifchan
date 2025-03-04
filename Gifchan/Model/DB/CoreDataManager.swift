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
    
    // 🔹 Додає GIF до улюблених (FavoriteGif)
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

    // 🔹 Додає GIF до SavedGif (Giphy, Uploaded, Created)
    func addToSavedGifs(gifURL: String, type: String) {
        guard !isGifSaved(gifURL: gifURL) else { return }

        let newGif = SavedGif(context: context)
        newGif.id = UUID().uuidString
        newGif.url = gifURL
        newGif.type = type
        save()
    }

    // 🔹 Видаляє GIF із SavedGif
    func removeFromSavedGifs(gifURL: String) {
        let request: NSFetchRequest<SavedGif> = SavedGif.fetchRequest()
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

    // 🔹 Отримує всі SavedGif
    func fetchSavedGifs() -> [SavedGif] {
        let request: NSFetchRequest<SavedGif> = SavedGif.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Помилка отримання SavedGif: \(error)")
            return []
        }
    }
    
    // 🔹 Отримує GIF за категорією
    func fetchSavedGifsByType(type: String) -> [SavedGif] {
        let request: NSFetchRequest<SavedGif> = SavedGif.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type)
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Помилка отримання GIF за категорією \(type): \(error)")
            return []
        }
    }

    // 🔹 Перевіряє, чи GIF вже є в SavedGif
    func isGifSaved(gifURL: String) -> Bool {
        let request: NSFetchRequest<SavedGif> = SavedGif.fetchRequest()
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
