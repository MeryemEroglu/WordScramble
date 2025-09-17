//
//  ContentView.swift
//  WordScramble
//
//  Created by Meryem Eroğlu on 6.09.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var maxWords = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            
            Text("Score: \(score)")
                .font(.headline)
                .fontWeight(.bold)
                .padding()
            Text("Max possible words: \(maxWords)")
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            .navigationTitle(rootWord)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        startGame()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onSubmit(addNewWord)
        .onAppear(perform: startGame)
        .alert(errorTitle, isPresented: $showingError) { } message: {
            Text(errorMessage)
        }
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count >= 3 else {
            wordError(title: "Word too short", message: "Words must be at least 3 letters long")
            return
        }
        guard answer.lowercased() != rootWord.lowercased() else {
            wordError(title: "That's the start word", message: "You cannot use the start word itself.")
            return
        }
        
        guard answer.count>0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            score += answer.count * 10
        }
        newWord = ""
    }
    
    func calculateMaxWords(from root: String) {
        if let startWords = Bundle.main.url(forResource: "english-words", withExtension: "txt") {
            if let allText = try? String(contentsOf: startWords, encoding: .utf8) {
                    let allWords = allText.components(separatedBy: "\n")
                    
                    let validWords = allWords.filter { word in
                        word.count >= 3 && isPossible(word: word) && isReal(word: word)
                    }
                    
                    maxWords = validWords.count
                    for word in validWords {
                        print(word)
                    }
            }
        }
    }
    
    func startGame() {
        usedWords.removeAll()
        if let startWords = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWords, encoding: .utf8) {
                let allWords = startWords.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "silkworm"
                calculateMaxWords(from: rootWord)
                return
            }
        }
        fatalError( "Could not load start.txt from bundle." )
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

#Preview {
    ContentView()
}
