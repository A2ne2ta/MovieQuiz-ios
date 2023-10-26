//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Анна on 25.10.2023.
//

import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
//    var totalQuestions: Int { get }
//    var totalCorrectAnswers: Int { get }
}

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    // метод сравнения по кол-ву верных ответов
    func isBetterThan(_ another: GameRecord) -> Bool {
        correct > another.correct
    }
    
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var totalCorrectAnswers: Int {
        get { userDefaults.integer(forKey: Keys.correct.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.correct.rawValue) }
    }
    
    var totalQuestions: Int {
        get { userDefaults.integer(forKey: Keys.total.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.total.rawValue) }
    }
    
    var totalAccuracy: Double {
        get { (Double(totalCorrectAnswers)/Double(totalQuestions)) * 100 }
    }
    
    var gamesCount: Int {
        get { userDefaults.integer(forKey: Keys.gamesCount.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    func store(correct count: Int, total amount: Int) {
        let currentGame = GameRecord(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
        gamesCount += 1
        totalCorrectAnswers += count
        totalQuestions += amount
    }
    
}

