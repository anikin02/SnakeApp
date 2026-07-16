//
//  GameViewModel.swift
//  SnakeApp
//
//  Created by Данил on 15/07/2026.
//

import Combine
import Foundation

class GameViewModel: ObservableObject {
  private let scoreKey = "saved_game_score"
  
  let size: Int = 15
  @Published var score: Int = 0
  @Published var bestScore: Int = 0
  @Published var grid: [[Plate]] = Array(repeating: Array(repeating: .empty, count: 15), count: 15)
  @Published var snake: [Body] = []
  
  @Published var deltaX: Int = 0
  @Published var deltaY: Int = 1
  
  @Published var speed: Speed = .normal
  
  @Published var gameState: GameState = .waiting
  @Published var isGameOver: Bool = false
  
  private var timerCancellable: AnyCancellable?
  
  init() {
    self.bestScore = loadScore()
  }
  
  func startNewGame() {
    score = 0
    gameState = .playing
    isGameOver = false
    grid = Array(repeating: Array(repeating: .empty, count: size), count: size)
    snake.removeAll()
    
    snake.append(Body(x: grid.count / 2 - 2, y: grid.count / 2))
    snake.append(Body(x: grid.count / 2 - 1, y: grid.count / 2))
    snake.append(Body(x: grid.count / 2, y: grid.count / 2))
    
    grid[grid.count / 2][grid.count / 2] = .snake
    grid[grid.count / 2][grid.count / 2 - 1] = .snake
    grid[grid.count / 2][grid.count / 2 - 2] = .snake
    
    generateFood()
    
    gameLoop()
  }
  
  func generateFood() {
    
    var isGenerated: Bool = false
    
    while !isGenerated {
      let x = Int.random(in: 0..<size)
      let y = Int.random(in: 0..<size)
      if grid[y][x] == .empty {
        grid[y][x] = .food
        isGenerated = true
      }
    }
  }
  
  private func saveScore() {
    UserDefaults.standard.set(score, forKey: scoreKey)
  }
  
  private func loadScore() -> Int {
    return UserDefaults.standard.integer(forKey: scoreKey)
  }
  
  func setDirection(direction: Direction) {
    switch (direction) {
      case .up:
        guard grid[snake[0].y + -1][snake[0].x + 0] != .snake else {
          return
        }
        deltaX = 0
        deltaY = -1
      case .down:
        guard grid[snake[0].y + 1][snake[0].x + 0] != .snake else {
          return
        }
        deltaX = 0
        deltaY = 1
      case .left:
        guard grid[snake[0].y + 0][snake[0].x + -1] != .snake else {
          return
        }
        deltaX = -1
        deltaY = 0
      case .right:
        guard grid[snake[0].y + 0][snake[0].x + 1] != .snake else {
          return
        }
        deltaX = 1
        deltaY = 0
    }
  }
  
  private func gameOver() {
    isGameOver = true
    gameState = .waiting
    
    timerCancellable?.cancel()
    timerCancellable = nil
    saveScore()
  }
  
  private func gameLoop() {
    timerCancellable?.cancel()
    
    timerCancellable = Timer.publish(every: speed.rawValue, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        self?.moveSnake()
      }
  }
  
  func setSpeed(to newSpeed: Speed) {
    guard speed != newSpeed else { return }
    
    self.speed = newSpeed
    
    if gameState == .playing {
      gameLoop()
    }
  }
  
  private func eatFood(x: Int, y: Int) {
    snake.append(Body(x: x, y: y))
    score += 1
    if score > bestScore {
      bestScore = score
    }
    
  }
  
  private func moveSnake() {
    guard snake[0].x + deltaX < size
            && snake[0].x + deltaX >= 0
            && snake[0].y + deltaY < size
            && snake[0].y + deltaY >= 0 else {
      gameOver()
      return
    }
    var previous: Body = snake[0]
    var isEating: Bool = false
    
    if grid[snake[0].y + deltaY][snake[0].x + deltaX] == .food {
      isEating = true
    }
    
    snake[0].x += deltaX
    snake[0].y += deltaY
    if grid[snake[0].y][snake[0].x] == .snake {
      gameOver()
      return
    }
    grid[snake[0].y][snake[0].x] = .snake
    
    if isEating {
      eatFood(x: snake.last!.x + deltaX, y: snake.last!.y + deltaY)
      generateFood()
    } else {
      grid[snake.last!.y][snake.last!.x] = .empty
    }
    
    for i in 1..<snake.count {
      let temp = snake[i]
      snake[i] = previous
      previous = temp
    }
  }
}

enum Plate {
  case snake
  case food
  case empty
}

enum Direction {
  case up
  case down
  case left
  case right
}

enum Speed: Double {
  case easy = 0.8
  case normal = 0.5
  case hard = 0.25
  case extreme = 0.15
}

enum GameState {
  case waiting
  case playing
}
