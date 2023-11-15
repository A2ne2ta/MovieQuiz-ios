//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Анна on 24.10.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? { get set }
    
    func requestNextQuestion()
    
    func loadData()
}
