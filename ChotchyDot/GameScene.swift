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
    //var lineNodes:[SKShapeNode] = []
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
    //タッチした座標配列
    var touchPoint:CGPoint = CGPointZero
    
    var btn: UIButton!
    
    var btn2: UIButton!
    
    
    
    
    override func didMoveToView(view: SKView) {
        
        // 下方向への重力を設定
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -3.8)
        self.physicsWorld.contactDelegate = self
        
        btn = UIButton(frame: CGRectMake((self.view?.frame.width)! - 100,40,50,50))
        btn.backgroundColor = UIColor.redColor()
        btn.layer.cornerRadius = 25
        btn.addTarget(self, action: "refall:", forControlEvents: .TouchUpInside)
        self.view?.addSubview(btn)
        
        btn2 = UIButton(frame: CGRectMake(50,40,50,50))
        btn2.backgroundColor = UIColor.greenColor()
        btn2.layer.cornerRadius = 25
        btn2.addTarget(self, action: "refresh:", forControlEvents: .TouchUpInside)
        self.view?.addSubview(btn2)
        
        
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
        
        let blockShape = SKShapeNode(rectOfSize: CGSize(width: self.size.width * 0.7, height: 20))
        blockShape.position = CGPoint(x: 0, y: 300)  // 画面外に配置
        blockShape.fillColor = UIColor.redColor()
        let blockPhysics = SKPhysicsBody(rectangleOfSize: blockShape.frame.size)
        blockPhysics.dynamic = false
        blockPhysics.restitution = 0.9
        blockShape.physicsBody = blockPhysics
        self.addChild(blockShape)
        
        
        
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
        //fallBoll()
        
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
        sprite.position = CGPoint(x: self.size.width*0.2, y: self.size.height)
        sprite.size = CGSize(width: texture.size().width * 0.2, height: texture.size().height *  0.2)
        sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)     // テクスチャの不透過部分の形状で物理シミュレーションを行う
        sprite.physicsBody!.mass = CGFloat(Int(arc4random() % 100) + 1)
        sprite.physicsBody!.linearDamping = 1.0
        sprite.physicsBody?.friction = 100.0
        sprite.physicsBody!.restitution = 0.1
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
            
            //タッチ開始ポイントを保存
            touchPoint = location
            
        }
    }
    
    // 指を動かしたときに呼ばれるメソッド
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch: AnyObject = touches.first {
            // シーン上のタッチされた位置を取得する
            let location = touch.locationInNode(self)
            
            
            //線を描画
            var touchPoints:[CGPoint] = [touchPoint,location]
            let Line = SKShapeNode(points: &touchPoints, count: touchPoints.count)
            // ShapeNodeの線の色を白色に指定.
            Line.strokeColor = UIColor.whiteColor()
            Line.fillColor = UIColor.blueColor()
            // ShapeNodeの線の太さを指定
            Line.lineWidth = 3.0
            //  physicsBodyの設定
            // シェイプの大きさで物理シミュレーションを行う
            let physicsBody = SKPhysicsBody(edgeFromPoint:touchPoint , toPoint: location)
            // 落下しないよう固定
            physicsBody.dynamic = false
            Line.physicsBody = physicsBody
            // ShapeNpdeをsceneに追加.
            self.addChild(Line)
            
            //現在のタッチポイントを保存
            touchPoint = location
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch: AnyObject = touches.first {
            // シーン上のタッチされた位置を取得する
            let location = touch.locationInNode(self)
            
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
            //self.bolls.last?.removeFromParent()
            //再びボールを落とす
            //fallBoll()
            
            
        }
        
    }
    
    func refall(sender:UIButton){
        self.fallBoll()
    }
    
    func refresh(sender: UIButton){
        let scene = GameScene(size: self.scene!.size)
        //呼び出すSceneをJumpScene classにしただけ
        scene.scaleMode = SKSceneScaleMode.AspectFill
        self.view!.presentScene(scene)
    }
    
    
    
}
