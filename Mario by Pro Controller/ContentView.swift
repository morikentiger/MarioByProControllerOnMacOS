//
//  ContentView.swift
//  Mario by Pro Controller
//
//  Created by 森田健太 on 8/18/24.
//

import SwiftUI
import GameController

struct ContentView: View {
    @State private var characterPosition = CGPoint(x: 400, y: 500)
    @State private var velocity = CGSize(width: 0, height: 0)
    @State private var onGround = false
    
    private let gravity: CGFloat = 9.8
    private let jumpStrength: CGFloat = -30.0
    private let acceleration: CGFloat = 2.0
    @State private var maxVelocity: CGFloat = 10.0
    private let friction: CGFloat = 0.9
    
    @State private var controller: GCController?
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.red)
                .frame(width: 40, height: 60)
                .position(characterPosition)
                .onAppear {
                    characterPosition = CGPoint(x: geometry.size.width / 2, y: geometry.size.height - 60)
                    setupControllerObservers()
                }
                .onReceive(Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()) { _ in
                    updateCharacterPosition(geometry: geometry)
                }
        }
        .background(Color.blue)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func setupControllerObservers() {
        NotificationCenter.default.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { _ in
            if let connectedController = GCController.controllers().first {
                controller = connectedController
            }
        }
        
        // コントローラーが既に接続されている場合も設定
        if let connectedController = GCController.controllers().first {
            controller = connectedController
        }
    }
    
    private func updateCharacterPosition(geometry: GeometryProxy) {
        // コントローラーの状態を確認し、処理を行う
        if let gamepad = controller?.extendedGamepad {
            if gamepad.buttonB.isPressed {
                maxVelocity = 20.0
            } else {
                maxVelocity = 10.0
            }
            
            // 左スティックの水平方向の入力
            let xValue = gamepad.leftThumbstick.xAxis.value
            if xValue < -0.1 {
                velocity.width -= acceleration
                if velocity.width <= -maxVelocity {
                    velocity.width = -maxVelocity
                }
            } else if xValue > 0.1 {
                velocity.width += acceleration
                if velocity.width >= maxVelocity {
                    velocity.width = maxVelocity
                }
            } else {
                velocity.width *= friction
            }
            
            // ジャンプボタン（Xボタン）の入力
            if gamepad.buttonA.isPressed {
                if onGround {
                    velocity.height = jumpStrength
                    onGround = false
                }
                velocity.height -= jumpStrength/15
            } else {
                velocity.height += gravity
            }
        }
        
//        // 重力の適用
//        velocity.height += gravity
        
        // 速度を位置に反映
        characterPosition.x += velocity.width
        characterPosition.y += velocity.height
        
        // 地面（画面下部）に着いたら位置を調整
        if characterPosition.y > geometry.size.height - 30 {
            characterPosition.y = geometry.size.height - 30
            velocity.height = 0
            onGround = true
        }
        
        // 画面外に出ないように制限
        characterPosition.x = min(max(characterPosition.x, 0), geometry.size.width)
    }
}


