import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
   
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    // переменная с индексом текущего вопроса, начальное значение 0 (так как индекс в массиве начинается с 0)
//    private var currentQuestionIndex = 0
//    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    
    private let presenter = MovieQuizPresenter()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        imageView.layer.cornerRadius = 20
         questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
         statisticService = StatisticServiceImplementation()

         showLoadingIndicator()
         questionFactory?.loadData()
        
//        questionFactory = QuestionFactory()
//        questionFactory?.delegate = self
//        // берём текущий вопрос из массива вопросов по индексу текущего вопроса
//        questionFactory?.requestNextQuestion()
//
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self

        statisticService = StatisticServiceImplementation()
    }
    
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - AlertPresenterProtocol
    func alertClosed() {
        correctAnswers = 0
        
        questionFactory?.requestNextQuestion()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect { // 1
            correctAnswers += 1 // 2
        }
        imageView.layer.masksToBounds = true // 1
        imageView.layer.borderWidth = 8 // 2
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor // 3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            imageView.layer.borderWidth = 0
            
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let totalAccuracy = statisticService?.totalAccuracy ?? (Double(correctAnswers)/Double(presenter.questionsAmount)) * 100
            
            let bestGame = statisticService?.bestGame
            let text = """
                            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                            Количество сыграных квизов: \(statisticService?.gamesCount ?? 1)
                            Рекорд: \(bestGame?.correct ?? correctAnswers)/\(bestGame?.total ?? presenter.questionsAmount) (\(bestGame?.date.dateTimeString ?? Date().dateTimeString))
                            Средняя точность: \(String(format: "%.2f", totalAccuracy))%
                            """
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз")
            
            alertPresenter?.show(alert: alertModel, on: self)
            presenter.resetQuestionIndex()
        } else {
            presenter.switchToNextQuestion()
            imageView.layer.borderWidth = 0
            questionFactory?.requestNextQuestion()
        }
    }
    
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func showNetworkError(message: String) {
        didLoadDataFromServer() // скрываем индикатор загрузки
        
        self.presenter.resetQuestionIndex()
        self.correctAnswers = 0
        
        let model = AlertModel(
            title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз"
        )
        
        alertPresenter?.show(alert: model, on: self)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
}
