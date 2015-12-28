//
//  GameViewController.swift
//  ChotchyDot
//
//  Created by 冨平準喜 on 2015/12/26.
//  Copyright (c) 2015年 冨平準喜. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class GameScene : SKScene, SKPhysicsContactDelegate {
    
    
    // ゴール判定用ノード
    var goalShape:SKShapeNode?
    //線のnode配列
    var lineNodes:[SKShapeNode] = []
    // 線の存続タイマー
    var lineTimer:NSTimer?
    // ゴール移動タイマー
    var goalMoveTimer:NSTimer?
    //ゴールの移動する方向(右:プラス 左:マイナス)
    var moveDirection:CGFloat = 1
    // 落下判定用シェイプ
    var lowestShape:SKShapeNode?
    //ボールnode配列
    var bolls:[SKSpriteNode] = []
    //線のパス配列
    var pathToDraw:CGMutablePath?
    //タッチした座標配列
    var touchPoints:[CGPoint] = []
    
    
    override func didMoveToView(view: SKView) {
        
        // 下方向への重力を設定
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        self.physicsWorld.contactDelegate = self
        
        
        // Goal判定シェイプ
        let goalShape = SKShapeNode(rectOfSize: CGSize(width: self.size.width/6, height: 20))
        goalShape.position = CGPoint(x: self.size.width*0.5, y: 20)  // 画面外に配置
        goalShape.fillColor = UIColor.redColor()
        let physicsBody = SKPhysicsBody(rectangleOfSize: goalShape.frame.size)    // シェイプの大きさで物理シミュレーションを行う
        physicsBody.dynamic = false                 // 落下しないよう固定
        physicsBody.contactTestBitMask = 0x1 << 1   // 名古屋名物との衝突を検知する
        goalShape.physicsBody = physicsBody
        self.addChild(goalShape)
        self.goalShape = goalShape
        
        // 落下判定用シェイプ
        let lowestShape = SKShapeNode(rectOfSize: CGSize(width: self.size.width*3, height: 10))
        lowestShape.position = CGPoint(x: self.size.width*0.5, y: -100)  // 画面外に配置
        let lowestPhysicsBody = SKPhysicsBody(rectangleOfSize: lowestShape.frame.size)    // シェイプの大きさで物理シミュレーションを行う
        lowestPhysicsBody.dynamic = false                 // 落下しないよう固定
        lowestPhysicsBody.contactTestBitMask = 0x1 << 1   // 名古屋名物との衝突を検知する
        lowestShape.physicsBody = lowestPhysicsBody
        self.addChild(lowestShape)
        self.lowestShape = lowestShape
        
        //一回目のボール落下
        fallBoll()
        
        // タイマーを作成し一定時間ごとにdeleteLineメソッドを呼ぶ
        //self.lineTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "deleteLine", userInfo: nil, repeats: true)
        // タイマーを作成し一定時間ごとにmoveGoalメソッドを呼ぶ
        self.goalMoveTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "moveGoal", userInfo: nil, repeats: true)
        
    }
    //ボールを落下させるメソッド
    func fallBoll()
    {
        let texture = SKTexture(imageNamed: "dot") // テクスチャを読み込む
        // テクスチャからスプライトを生成する
        let sprite = SKSpriteNode(texture: texture)
        sprite.position = CGPoint(x: self.size.width*0.5, y: self.size.height)
        sprite.size = CGSize(width: texture.size().width * 0.5, height: texture.size().height * 0.5)
        sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)     // テクスチャの不透過部分の形状で物理シミュレーションを行う
        sprite.physicsBody?.contactTestBitMask = 0x1 << 1   // 落下判定用シェイプとの衝突を検知する
        self.bolls.append(sprite)
        self.addChild(bolls.last!)
        
    }
    
    //タイマーでLineを消す
    //    func deleteLine()
    //    {
    //        if lineNodes.count > removeCounter
    //        {
    //            // 配列の一番上の線を消す
    //            self.lineNodes[removeCounter].removeFromParent()
    //            //どこまで消したかをカウント
    //            removeCounter++
    //        }
    //
    //
    //    }
    
    func moveGoal()
    {
        var moveRight = SKAction()
        if goalShape?.position.x > self.frame.width - (goalShape?.frame.width)!/2
        {
            moveDirection = -3
        }
        else if goalShape?.position.x < (goalShape?.frame.width)!/2
        {
            moveDirection = 3
        }
        moveRight = SKAction.moveByX(moveDirection, y:0, duration:1.0)
        self.goalShape?.runAction(moveRight)
    }
    
    // タッチ開始時に呼ばれるメソッド
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch: AnyObject = touches.first {
            // シーン上のタッチされた位置を取得する
            let location = touch.locationInNode(self)
            
            pathToDraw = CGPathCreateMutable()
            CGPathMoveToPoint(pathToDraw, nil, location.x, location.y)
            
            //線を描画
            let Line = SKShapeNode(path: pathToDraw!, centered: false)
            // ShapeNodeの線の色を白色に指定.
            Line.strokeColor = UIColor.whiteColor()
            Line.fillColor = UIColor.blueColor()
            // ShapeNodeの線の太さを指定
            Line.lineWidth = 10.0
            //  physicsBodyの設定
            let physicsBody = SKPhysicsBody(polygonFromPath: pathToDraw!)   // シェイプの大きさで物理シミュレーションを行う
            physicsBody.dynamic = false                 // 落下しないよう固定
            Line.physicsBody = physicsBody
            //lineNodes配列に追加
            self.lineNodes.append(Line)
            // ShapeNpdeをsceneに追加.
            self.addChild(lineNodes.last!)
            
        }
    }
    
    // 指を動かしたときに呼ばれるメソッド
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch: AnyObject = touches.first {
            // シーン上のタッチされた位置を取得する
            let location = touch.locationInNode(self)
            
            CGPathAddLineToPoint(pathToDraw, nil, location.x, location.y)

            lineNodes.last!.path = pathToDraw
            lineNodes.last!.physicsBody = SKPhysicsBody(edgeLoopFromPath: pathToDraw!)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch: AnyObject = touches.first {
            // シーン上のタッチされた位置を取得する
            let location = touch.locationInNode(self)
            
            
            CGPathCloseSubpath(pathToDraw)
            
            lineNodes.last!.path = pathToDraw
            lineNodes.last!.physicsBody = SKPhysicsBody(edgeLoopFromPath: pathToDraw!)
        }
    }
    
    // 衝突が発生したときに呼ばれるメソッド
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 衝突した一方が落下判定用シェイプだったら
        if contact.bodyA.node == self.goalShape || contact.bodyB.node == self.goalShape {
            // ゲームオーバースプライトを表示
            let sprite = SKSpriteNode(imageNamed: "gameclear")
            sprite.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.5)
            self.addChild(sprite)
            
            // アクションを停止させる
            //self.paused = true
            
            // タイマーを止める
            //self.lineTimer?.invalidate()
            //self.goalMoveTimer?.invalidate()
        }
            
        else if contact.bodyA.node == self.lowestShape || contact.bodyB.node == self.lowestShape {
            
            //ボールnodeを消す
            self.bolls.last?.removeFromParent()
            //再びボールを落とす
            fallBoll()
            
            
        }
        
    }
    
    
    
}
