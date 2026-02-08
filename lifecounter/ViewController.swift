import UIKit

struct Player {
    var name: String
    var life: Int

    var isAlive: Bool {
        return life > 0
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var playersStackView: UIStackView!
    @IBOutlet weak var playersScrollView: UIScrollView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var addPlayerButton: UIButton!

    var players: [Player] = []
    var gameStarted = false
    var chunkFields: [Int: UITextField] = [:]
    var chunkValues: [Int: Int] = [:]
    var historyEntries: [String] = []
    private var gameOverAlertShown = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialPlayers()
        updateUI()
        renderPlayers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollContentSize()
    }

    private func updateScrollContentSize() {
        guard let scrollView = playersScrollView else { return }
        view.layoutIfNeeded()
        let contentHeight = playersStackView.bounds.height
        let width = scrollView.bounds.width
        scrollView.contentSize = CGSize(width: width, height: max(contentHeight + 24, scrollView.bounds.height))
    }

    func setupInitialPlayers() {
        players = [
            Player(name: "Player 1", life: 20),
            Player(name: "Player 2", life: 20),
            Player(name: "Player 3", life: 20),
            Player(name: "Player 4", life: 20)
        ]
        gameStarted = false
        historyEntries = []
        chunkValues = [:]
        gameOverAlertShown = false
    }

    func clearPlayersStackView() {
        for view in playersStackView.arrangedSubviews {
            playersStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    func renderPlayers() {
        clearPlayersStackView()
        chunkFields.removeAll()

        for i in 0..<players.count {
            let row = makePlayerRow(index: i)
            playersStackView.addArrangedSubview(row)
        }
        updateScrollContentSize()
    }

    func makePlayerRow(index: Int) -> UIView {
        let player = players[index]

        let nameButton = UIButton(type: .system)
        nameButton.setTitle(player.name, for: .normal)
        nameButton.tag = index
        nameButton.addTarget(self, action: #selector(nameTapped), for: .touchUpInside)
        nameButton.titleLabel?.textAlignment = .center

        let lifeLabel = UILabel()
        lifeLabel.text = "\(player.life)"
        lifeLabel.font = UIFont.boldSystemFont(ofSize: 28)
        lifeLabel.textAlignment = .center

        let labelStack = UIStackView(arrangedSubviews: [nameButton, lifeLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4
        labelStack.alignment = .center

        let plusButton = UIButton(type: .system)
        plusButton.setTitle("+", for: .normal)
        plusButton.tag = index
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)

        let minusButton = UIButton(type: .system)
        minusButton.setTitle("-", for: .normal)
        minusButton.tag = index
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)

        let plusMinusStack = UIStackView(arrangedSubviews: [plusButton, minusButton])
        plusMinusStack.axis = .horizontal
        plusMinusStack.spacing = 8

        let chunkValue = chunkValues[index] ?? 5
        let chunkField = UITextField()
        chunkField.text = "\(chunkValue)"
        chunkField.keyboardType = .numberPad
        chunkField.borderStyle = .roundedRect
        chunkField.textAlignment = .center
        chunkField.widthAnchor.constraint(equalToConstant: 50).isActive = true
        chunkFields[index] = chunkField

        let plusChunkButton = UIButton(type: .system)
        plusChunkButton.setTitle("+N", for: .normal)
        plusChunkButton.tag = index
        plusChunkButton.addTarget(self, action: #selector(plusChunkTapped), for: .touchUpInside)

        let minusChunkButton = UIButton(type: .system)
        minusChunkButton.setTitle("-N", for: .normal)
        minusChunkButton.tag = index
        minusChunkButton.addTarget(self, action: #selector(minusChunkTapped), for: .touchUpInside)

        let chunkStack = UIStackView(arrangedSubviews: [plusChunkButton, chunkField, minusChunkButton])
        chunkStack.axis = .horizontal
        chunkStack.spacing = 8

        let buttonStack = UIStackView(arrangedSubviews: [plusMinusStack, chunkStack])
        buttonStack.axis = .vertical
        buttonStack.spacing = 8

        let rowStack = UIStackView(arrangedSubviews: [labelStack, buttonStack])
        rowStack.axis = .horizontal
        rowStack.distribution = .fillEqually
        rowStack.spacing = 12

        return rowStack
    }

    @objc func nameTapped(_ sender: UIButton) {
        let index = sender.tag
        guard players.indices.contains(index) else { return }
        let currentName = players[index].name

        let alert = UIAlertController(title: "Rename Player", message: "Enter a new name for \(currentName).", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = currentName
            textField.placeholder = "Player name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self,
                  let newName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newName.isEmpty else { return }
            self.players[index].name = newName
            self.renderPlayers()
        })
        present(alert, animated: true)
    }

    @objc func plusTapped(_ sender: UIButton) {
        changeLife(for: sender.tag, by: 1)
    }

    @objc func minusTapped(_ sender: UIButton) {
        changeLife(for: sender.tag, by: -1)
    }

    @objc func plusChunkTapped(_ sender: UIButton) {
        let value = Int(chunkFields[sender.tag]?.text ?? "") ?? 0
        saveChunkValue(sender.tag, value)
        changeLife(for: sender.tag, by: value)
    }

    @objc func minusChunkTapped(_ sender: UIButton) {
        let value = Int(chunkFields[sender.tag]?.text ?? "") ?? 0
        saveChunkValue(sender.tag, value)
        changeLife(for: sender.tag, by: -value)
    }

    private func saveChunkValue(_ index: Int, _ value: Int) {
        chunkValues[index] = value
    }

    func changeLife(for index: Int, by amount: Int) {
        guard players.indices.contains(index) else { return }
        if amount == 0 { return }

        let name = players[index].name
        let absAmount = abs(amount)
        let lifeWord = absAmount == 1 ? "life" : "life"
        if amount > 0 {
            historyEntries.append("\(name) gained \(absAmount) \(lifeWord).")
        } else {
            historyEntries.append("\(name) lost \(absAmount) \(lifeWord).")
        }

        players[index].life += amount
        gameStarted = true

        updateUI()
        renderPlayers()
    }

    func updateUI() {
        let alivePlayers = players.filter { $0.isAlive }
        let playersAtZeroOrBelow = players.filter { $0.life <= 0 }

        if let loserIndex = players.firstIndex(where: { $0.life <= 0 }) {
            resultLabel.text = "\(players[loserIndex].name) LOSES!"
            resultLabel.textColor = .red
            resultLabel.isHidden = false
        } else if alivePlayers.count == 1 {
            resultLabel.text = "Game Over!"
            resultLabel.textColor = .red
            resultLabel.isHidden = false
        } else {
            resultLabel.isHidden = true
        }

        addPlayerButton?.isEnabled = !gameStarted && players.count < 8

        // BONUS: When all but one has lost, show "Game over!" alert with OK then reset (once per game)
        if !gameOverAlertShown, players.count > 1 {
            let allButOneLost = (players.count - playersAtZeroOrBelow.count) <= 1
            if allButOneLost {
                gameOverAlertShown = true
                showGameOverAlert()
            }
        }
    }

    private func showGameOverAlert() {
        guard presentedViewController == nil else { return }
        let alert = UIAlertController(title: "Game over!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.performReset()
        })
        present(alert, animated: true)
    }

    @IBAction func addPlayerTapped(_ sender: UIButton) {
        guard players.count < 8, !gameStarted else { return }

        let newNumber = players.count + 1
        players.append(Player(name: "Player \(newNumber)", life: 20))
        renderPlayers()
    }

    @IBAction func historyTapped(_ sender: UIButton) {
        let historyVC = HistoryViewController()
        historyVC.entries = historyEntries
        let nav = UINavigationController(rootViewController: historyVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    @IBAction func resetTapped(_ sender: UIButton) {
        performReset()
    }

    private func performReset() {
        setupInitialPlayers()
        updateUI()
        renderPlayers()
    }
}
