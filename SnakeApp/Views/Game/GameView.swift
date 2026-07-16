//
//  GameView.swift
//  SnakeApp
//
//  Created by Данил on 15/07/2026.
//

import SwiftUI

struct GameView: View {
  @ObservedObject var viewModel = GameViewModel()
  var body: some View {
    VStack {
      Spacer()
      
      speedPickerView()
      
      HStack {
        Text("Score: \(viewModel.score)")
          .font(.largeTitle.bold())
          .foregroundStyle(Color.black)
      }
      
      VStack(spacing: 1) {
        ForEach(0..<viewModel.grid.count, id: \.self) { rowIndex in
          HStack(spacing: 1) {
            ForEach(0..<viewModel.grid[rowIndex].count, id: \.self) { columnIndex in
              let cell = viewModel.grid[rowIndex][columnIndex]
              
              Rectangle()
                .frame(width: 25, height: 25)
                .foregroundStyle(cell == .snake ? Color.green : (cell == .food ? Color.red : Color.gray))
            }
          }
        }
      }
      .background(.black)
      
      HStack {
        Text("High score: \(viewModel.bestScore)")
          .font(.title3.bold())
          .foregroundStyle(Color.black)
      }
      .padding(4)
      
      Spacer()
      
      newGameButton()
      
      Spacer()
    }
    .background(.white)
    .gesture(
      DragGesture(minimumDistance: 30, coordinateSpace: .local)
        .onEnded { value in
          let horizontal = value.translation.width
          let vertical = value.translation.height
          
          if abs(horizontal) > abs(vertical) {
            if horizontal > 0 {
              self.viewModel.setDirection(direction: .right)
            } else {
              self.viewModel.setDirection(direction: .left)
            }
          } else {
            if vertical > 0 {
              self.viewModel.setDirection(direction: .down)
            } else {
              self.viewModel.setDirection(direction: .up)
            }
          }
        }
    )
    .alert("Game Over", isPresented: $viewModel.isGameOver) {
      Button("Back", role: .cancel) {
        
      }
    } message: {
      Text("You lost the fucking game. Try again!")
    }
  }
  
  private func speedButton(title: String, speed: Speed) -> some View {
    Button {
      viewModel.setSpeed(to: speed)
    } label: {
      Text(title)
        .font(.headline)
        .foregroundStyle(viewModel.speed == speed ? .black : .accentColor)
    }
  }
  
  private func speedPickerView() -> some View {
    HStack {
      Spacer()
      
      speedButton(title: "Easy", speed: .easy)
      Spacer()
      speedButton(title: "Normal", speed: .normal)
      Spacer()
      speedButton(title: "Hard", speed: .hard)
      Spacer()
      speedButton(title: "Extreme", speed: .extreme)
      
      Spacer()
    }
    .padding(5)
  }
  
  private func newGameButton() -> some View {
    Button {
      viewModel.startNewGame()
    } label: {
      Text(viewModel.gameState == .waiting ? "Start Game" : "Restart")
        .font(.title.bold())
    }
  }
}

#Preview {
  GameView()
}
