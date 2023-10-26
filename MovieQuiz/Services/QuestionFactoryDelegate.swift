//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Анна on 24.10.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
