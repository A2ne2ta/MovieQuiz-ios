//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Анна on 24.10.2023.
//

import Foundation

protocol AlertPresenterProtocol {
    var delegate: AlertPresenterDelegate? { get set }
    
    func show(alert: AlertModel, on controller: MovieQuizViewController)
}
