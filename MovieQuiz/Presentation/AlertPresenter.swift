//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Анна on 24.10.2023.
//
import UIKit
import Foundation

class AlertPresenter : AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    func show(alert: AlertModel, on controller: MovieQuizViewController) {
        let view = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: alert.buttonText,
            style: .default
        ) { [weak self]_ in
            guard let self = self else {return}
            
            self.delegate?.alertClosed()
        }
        
        view.addAction(action)
        controller.present(view, animated: true, completion: nil)
    }
    
}
