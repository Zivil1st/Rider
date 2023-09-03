//
//  Skater.swift
//  SchoolhouseSkateboarder
//
//  Created by Ilya baZeline on 07.08.2023.
//

import SpriteKit

class Skater: SKSpriteNode {
    var velocity = CGPoint.zero // Эта переменная обо- значает скорость, она будет отслеживать скорость перемещения скейтбордистки по оси x (слева направо) и оси y (сверху вниз). К при- меру, когда скейтбордистка подпрыгивает, значение скорости по y будет определять, насколько быстро она движется вверх.
    var minimumY: CGFloat = 0.0 // то CGFloat, которую мы используем для уточнения положения уровня земли по y
    var jumpSpeed: CGFloat = 20.0 // это CGFloat, которая задает, с какой скоростью может прыгнуть скейтбордистка
    var isOnGround = true // Переменная isOnGround имеет тип Bool, и мы будем использо- вать ее для отслеживания, находится ли скейтбордистка на земле
    
    
    func setupPhysicsBody() {
        if let skaterTexture = texture { // Чтобы создать физическое тело, основанное на текстуре спрайта skater, сначала проверьте, что эта текстура существует, поскольку texture — это опционал SKSpriteNode. Строка распаковывает текстуру какskaterTexture
            physicsBody = SKPhysicsBody(texture: skaterTexture, size: size) // Строка задает свойствоphysicsBody скейтбордистке в соответствии с новым SKPhysicsBody, созданным с помощью текстуры и размеров спрайта skater
            physicsBody?.isDynamic = true // Задаем спрайту некоторые свойства физического тела, чтобы он начал вести себя нужным нам образом. Устанавливая для свойства isDynamic значение true, мы подтверждаем, что движения этого объекта должны управляться физическим движком.
            physicsBody?.density = 6.0 // В строке задаем свойству density физического тела спрай- та skater значение 6.0. Плотность позволяет вычислить его массу, то есть насколько оно тяжелое, исходя из размеров.
            physicsBody?.allowsRotation = true // начениеtrueсвойстваallowsRotation сообщает физическому движку, что данное физическое тело может вращаться или повора- чиваться. Если бы мы не хотели, чтобы скейтбордистка опрокидывалась, то установили бы для этого свойства значение false.
            physicsBody?.angularDamping = 1.0
            
            
            physicsBody?.categoryBitMask = PhysicsCategory.skater // Задаем соответствие между категорией скейтбордистки и фи- зической категорией skater, которую создали в строке
            physicsBody?.collisionBitMask = PhysicsCategory.brick // Затем устанавливаем значение collisionBitMask равным значению категории brick (строка)
            physicsBody?.contactTestBitMask = PhysicsCategory.brick | PhysicsCategory.gem // В строке задаем условие, при котором свойство contactTestBitMask относится к обеим категориям: brick и gem // Вертикальная черта (|), или символ, который программисты иногда называют пайп (от pipe — «труба»), позволяет сохранить сразу множество значений в одном свойстве.
            
        }
        }
    }
