//
//  ViewController.swift
//  WordScramble
//
//  Created by Noah Balsmeyer on 4/4/17.
//  Copyright © 2017 nbalsmeyer. All rights reserved.
//

import GameplayKit
import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    var wordIdx = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Word", style: .plain, target: self, action: #selector(startGame))
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
            } else {
                loadDefaultWords()
            }
        } else {
            loadDefaultWords()
        }
        
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        
        startGame()
    }
    
    func loadDefaultWords() {
        allWords = ["silkworm", "agencies", "dirtgrub"]
    }
    
    func startGame() {
        if wordIdx >= allWords.count {
            wordIdx = 0
        }
        title = allWords[wordIdx]
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
        wordIdx += 1
    }
    
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction) in
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    func submit(answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isValidWord(word: lowerAnswer) {
            usedWords.insert(answer, at: 0)
            
            let indexPath = IndexPath(item: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    func isValidWord(word: String) -> Bool {
        var isValid = true
        if isStartWord(word: word) {
            showError(title: "Word is default", message: "Try harder than that!")
            isValid = false
        } else if isTooShort(word: word) {
            showError(title: "Word is too short", message: "Words must be longer than 2 letters!")
            isValid = false
        } else if !isPossible(word: word) {
            showError(title: "Word not possible", message: "You can't spell that word from '\(title!.lowercased())'!")
            isValid = false
        } else if !isOriginal(word: word) {
            showError(title: "Word used already", message: "Be more original!")
            isValid = false
        } else if !isReal(word: word) {
            showError(title: "Word not recognized", message: "You can't just make them up, you know!")
            isValid = false
        }
        
        return isValid
    }
    
    func isStartWord(word: String) -> Bool {
        return word == title!.lowercased()
    }
    
    func isTooShort(word: String) -> Bool {
        return word.utf16.count < 3
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = title!.lowercased()
        
        for letter in word.characters {
            if let pos = tempWord.range(of: String(letter)) {
                tempWord.remove(at: pos.lowerBound)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func showError(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

