//
//  GameScene.swift
//  SchoolhouseSkateboarder
//
//  Created by Ilya baZeline on 06.08.2023.
//

import SpriteKit
// import GameplayKit

/// Эта структура содержит различные физические категории,  и мы можем определить, какие типы объектов сталкиваются или контактируют друг с другом
struct PhysicsCategory {
    static let skater: UInt32 = 0x1 << 0
    static let brick: UInt32 = 0x1 << 1
    static let gem: UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Это действие создает класс под названием bricks, связывая его с пустым массивом спрайтов (поскольку наши секции будут спрайтами).
    var bricks = [SKSpriteNode]()
    
    // Эта переменная brickSize задает размер каждой секции. Она пригодится нам, когда мы начнем их передвигать. Пока же зададим для brickSize значение CGSize.zero, поскольку мы еще не знаем, каким будет реальный размер.
    var brickSize = CGSize.zero
    
    
    // Настройка скорости движения направо для игры
    // Это значение может увеличиваться по мере продвижения пользователя в игре
    var scrollSpeed: CGFloat = 5.0 // Помните, что вам нужно задать тип данных CGFloat, в противном случае Xcode предположит, что переменная имеет тип Double.
    
    let startingScrollSpeed: CGFloat = 5.0 // Теперь, увеличивая значение scrollSpeed, мы всегда знаем, какой должна быть скорость в начале игры.
    
    let gravitySpeed: CGFloat = 1.5 // Константа для гравитации (того, как быстро объекты падают на Землю)
    
    // Время последнего вызова для метода обновления
    var lastUpdateTime: TimeInterval?
    
    
    // Здесь мы создаем героя игры - скейтбордистку
    let skater = Skater(imageNamed: "skater") // Эта строка создает новое свойство класса skater — экземпляр нового класса Skater. Он использует изображение skater.png
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0) // то свойство задает направление гравитации с помощью CGVector, содержащего значения x и y. В нашей игре мы задаем значение x, равное 0.0, и значение y, равное –6.0. Это значит, что у нас отсутствует гравитация в горизонтальном направлении и есть умеренная гравитация по вертикали.
        physicsWorld.contactDelegate = self
        
        anchorPoint = CGPoint.zero
        
        let background = SKSpriteNode(imageNamed: "background") //Строка создает спрайт background
        let xMid = frame.midX
        let yMid = frame.midY // Создают константы xMid и yMid, представляющие положение центра экрана
        background.position = CGPoint(x: xMid, y: yMid) //задает положение нашего фонового изображения относительно середины экрана.
        addChild(background) //Добавляет фоновое изображение к сцене
        
        // Создаем скейтбордистку и добавляем ее к сцене
        skater.setupPhysicsBody()
        
        // Настраиваем свойства скейтбордистки и добавляем ее в сцену
        // resetSkater() // Поскольку теперь метод startGame() вызывает resetSkater(), нам больше не нужно вызывать его в didMove(to:). Удалите строку
        addChild(skater)
    
        
        // Добавляем распознаватель нажатия, чтобы знать, когда 8 пользователь нажимает на экран
        let tapMethod = #selector (Self.handleTap(tapGesture:)) // Создаем селектор под названием tapMethod (строка). Селектор представляет собой ссылку на название метода. Добавим к нему новый метод под именем handleTap(_:), и эта константа, tapMethod, будет ссылкой на этот метод. Ссылка позволит нам сообщить распознавателю нажатий, какой метод он должен вызвать, когда пользователь нажмет на экран.
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod) // В строке создаем распознаватель нажатий. Его инициализатор принимает цель (target) и селектор. Цель сообщает распознавателю жестов, для какого класса будет использоваться селектор, а селектор — это метод для вызова.
        
        
        view.addGestureRecognizer(tapGesture) // Поскольку мы собираемся добавить метод handleTap(_:) к классу GameScene, в котором сейчас и находимся, используем self как аргумент. И, наконец, строка добавляет новый распознаватель жестов к представлению сцены.
        
        startGame()
    }
    
    
    
    func resetSkater() {
        // Задаем начальное положение скейтбордистки, zPosition и minimumY
        
        let skaterX = frame.midX / 2.0 // Прежде всего определяем x-положение скейтбордистки, skaterX, задавая значения x в четверть горизонтали сцены, то есть половине от frame.midX
        
        let skaterY = skater.frame.height / 2.0 + 64.0 //  строкемы рассчитываем положение скейтбордистки по оси y, добавляя к половине высоты спрайта skater значение 64.
        
        skater.position = CGPoint(x: skaterX, y: skaterY) // Теперь, когда мы рассчитали координаты скейтбордист- ки по осям x и y, задаем ее начальное положение путем создания CGPoint, который принимает эти значения
        
        skater.zPosition = 10 // Зададим значение zPosition для спрайта skater, равное 10
        
        skater.minimumY = skaterY // В строке  мы задаем для свойства minimumY спрайта skater значение, равное ее положению по y. В ходе игры скейтбордистка будет прыгать, поэтому ее положение по y изменится
        
        skater.zRotation = 0.0 // Строка задает для свойства zRotation спрайта skater начальное значение 0.0. Свойство zRotation определяет, насколько сильно объект вращается вправо или влево.
        skater.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0) // Строка задает для свойстваvelocityее физического тела значение 0.0. Это заставит ее остановиться во время прыжка или падения
        skater.physicsBody?.angularVelocity = 0.0 // Строка задает для angularVelocity, или скорости вращения, начальное значение 0.0.
        
        
    }
    
    func startGame() {
        // Возвращение к начальным условиям при запуске новой игры
        resetSkater() // Прежде всего вызываем метод для перезагрузки скейтбордистки, в результате чего героиня перемещается обратно в стартовое положение.
        
        scrollSpeed = startingScrollSpeed // Затем сбрасываем переменные класса. Значение scrollSpeed устанавливается равным начальной скорости
        
        lastUpdateTime = nil
        for brick in bricks { // В строке запускаем цикл через все спрайты brick в нашем массиве bricks и удаляем каждый из них из сцены путем вызова removeFromParent().
            brick.removeFromParent()
        }
        bricks.removeAll(keepingCapacity: true) //Затем нужно убрать спрайты brick из массива bricks. Самый простой способ сделать это — вызвать removeAll(_:)для массиваbricks
    }
    
    func gameOver() {
        startGame()
    }
    
    func spawnBrick (atPosition position: CGPoint) -> SKSpriteNode { //В строке наш метод spawnBrick(atPosition:) принимает для ввода CGPoint (и таким образом знает, куда поместить объект brick) и возвращает только что созданный спрайт brick.
        
        
        // Создаем спрайт секции и добавляем его к сцене
        let brick = SKSpriteNode(imageNamed: "sidewalk") // Создаем спрайт brick в виде SKSpriteNode с использованием изображения sidewalk.png
        
        
        brick.position = position // В строке новый спрайт brick помещается в положение, ранее переданное в метод.
        
        brick.zPosition = 8 // В строке спрайт brick получает значение zPosition, равное 8. Помните, что мы помещаем наше фоновое изображение на zPosition, равное 0, а спрайт skater — на zPosition, равное 10, поэтому эти секции тротуара всегда будут находиться впереди фонового изображения, но за скейтбордисткой.
        
        addChild(brick) // После этого наш объект brick добавляется к сцене (в противном случае он просто не покажется на экране).
        
        
        // Обновляем свойство brickSize реальным значением размера секции
        brickSize = brick.size // Строка задает свойство класса brickSize, равное новому размеру секции, основанному на рельном размере sidewalk.png.
        
        
        // В строке спрайт brick добавляется к массиву bricks, созданному нами ранее.
        bricks.append(brick)
        
        // Настройка физического тела секции
        let center = brick.centerRect.origin // Строка задает центральную точку только что созданного объекта brick
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size, center: center) // Строка создает физическое тело и присоединяет его к спрайту brick. Для этого мы создаем прямоугольник того же размера и помещаем его в центре секции. Теперь это физическое тело находится поверх спрайта brick.
        brick.physicsBody?.affectedByGravity = false // Строка сообщает физическому телу спрайта brick, что на него не должна влиять гравитация
        
        brick.physicsBody?.categoryBitMask = PhysicsCategory.brick //Строка задает значение categoryBitMask физического тела для созданной нами категории brick. Она сообщает SpriteKit, к какому типу объекта принадлежит данное тело.
        brick.physicsBody?.collisionBitMask = 0 // Задание collisionBitMask 0 сообщает SpriteKit, что секции не должны сталкиваться с чем-либо еще.
        
        // И, наконец, в строке новый спрайт brick возвращается в код, который вызвал этот метод.
        
        return brick
        
    }
    
    func updateBricks(withScrollAmount currentScrollAmount: CGFloat) {
        
        // Эту переменную мы будем использовать для отслеживания положения по x-секции, находящейся на крайней правой позиции. Таким образом, мы будем знать, когда наступит время добавить еще одну секцию с правого края и где именно ее поместить.
        var farthestRightBrickX: CGFloat = 0.0
        
        
        
        for brick in bricks { // Этот код в строке обходит весь массив bricks с помощью цик- ла for-in
            
            let newX = brick.position.x - currentScrollAmount // В строке рассчитывается новое положение по оси x для спрайта brick.
            
            
            // Если секция сместилась слишком далеко влево (за пределы 8 экрана), удалите ее
            if newX < -brickSize.width { // мы используем выражение if, чтобы проверить, оказалось ли значение newX секции за пределами экрана. Для этого смотрим, меньше ли это значение, чем ширина секции со знаком «минус»
                
                
                
                brick.removeFromParent() //   Спрайты, которые больше нам не нужны, должны быть удалены, чтобы приложению не пришлось напрасно тратить ресурсы на отслеживание лишних узлов. Именно это делает строка. Для удаления любого спрайта из сцены мы вызываем метод removeFromParent()
                
                
                if let brickIndex = bricks.index(of: brick) { // Строка проверяет, находится ли этот brick в нашем массиве bricks. Для этого производится поиск его индекса в массиве
                    
                    bricks.remove(at: brickIndex) // после чего строка использует данный индекс для исключения спрайта из массива bricks
                    
                    
                } else {
                    // Для секции, оставшейся на экране, обновляем положение
                    brick.position = CGPoint(x: newX, y: brick.position.y) // Строка задает новое положение относительно оси x для спрайта brick путем создания CGPoint на основе уже рассчитанного нами значения newX.
                    
                    
                    //Обновляем значение для крайней правой секции
                    if brick.position.x > farthestRightBrickX { // Последнее, что нужно сделать внутри блока else, это обновить значение переменной farthestRightBrickX. Для этого мы проверим, больше ли новое значение спрайта brick по оси x, чем значение farthestRightBrickX в строке
                        farthestRightBrickX = brick.position.x // Если больше, задаем farthestRightBrickX значение, равное значению по оси x этого спрайта brick в строке. Таким образом, когда цикл for-in закон- чится и мы произведем итерацию по всем секциям в нашем массиве
                        
                        
                    } }
            }
            
        }
        
        // Цикл while, обеспечивающий постоянное наполнение экрана 8 секциями
        while farthestRightBrickX < frame.width { // Из предыдущего кода мы знаем положение самой правой секции относительно x. Теперь мы используем циклwhile для добавления новой секции, как только значение положения самой правой секции оказывается меньше ширины сцены. Цикл будет работать, пока у нас Случайное не появятся секции, заполняющие экран до правого края.
            
            
            
            var brickX = farthestRightBrickX + brickSize.width + 1.0 // Строка определяет очередное значение по x для нового спрайта brick, добавляя к текущему значению самой правой секции величину, равную ши- рине одной секции плюс разрыв в один пункт
            
            
            let brickY = brickSize.height / 2.0 // Строка рассчитывает новое значение положения по оси y для спрайта brick, деля высоту секции пополам. В результате секция окажется на нижнем крае экра- на.
            
            
            // Время от времени мы оставляем разрывы, через которые 8 герой должен перепрыгнуть
            
            let randomNumber = arc4random_uniform(99) // В строке с помощью этой функции создаем слу- чайное целое число между 0 и 99. Это напоминает бросок кубика со 100 гранями, когда между 0 и 99 может находиться 100 возможных чисел.
            
            if randomNumber < 5 { // Используем выражение if в строке, чтобы проверить условие, при котором это число меньше 5. Это значит, что код внутри выражения if будет иметь 5-процентный шанс выполнения.
                
                // 5-процентный шанс на то, что у нас возникнет разрыв между секциями
                let gap = 20.0 * scrollSpeed // Строка рассчитывает, насколько большой разрыв надо создать. Желательно, чтобы по мере увеличения скорости скейтбордистки «выбоины» становились больше и больше, поэтому величина разрыва задана на уровне, в 20 раз превышающем скорость прокручивания.
                
                brickX += gap // строка добавляет разрыв к нашей переменной brickX. Мы задали положение секции, при котором она будет располагаться не рядом с предыдущей секцией, а на некотором расстоянии от нее, создавая справа разрыв.
            }
            
            // Добавляем новую секцию и обновляем положение самой правой
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY)) // После определения положения новой секции относительно осей x и y добавляем новую секцию в строке
            
            
            farthestRightBrickX = newBrick.position.x
        }
    }
        
        
        
        // Get label node from scene and store it for use later
    override func update(_ currentTime: TimeInterval) {
        
        // Определяем время, прошедшее с момента последнего вызова 8 update
        var elapsedTime: TimeInterval = 0.0 // Строка создает переменную elapsedTime с типом данных TimeInterval. TimeInterval — это Double, использующийся для отслеживания временны`х интервалов в секундах Точно так же, как при создании CGFloat, нужно уточнить, что речь идет о типе данных TimeInterval. В противном случае Xcode будет использовать вывод типов и предполагать, что это обычный тип Double
        
        
        if let lastTimeStamp = lastUpdateTime { // Строка  распа- ковывает lastUpdateTime, если он существует. Это значение имеет вид опционала, поскольку в начале игры у нас не существует послед- него времени обновления. Таким образом, при первом вызове метода update( _ :) значение lastUpdateTime будет равно nil.
            
            
            elapsedTime = currentTime - lastTimeStamp //Если нам удастся его распаковать, то строка сможет рассчитать elapsedTime, то есть время, прошедшее с момента последнего вызова update( _ :)
        }
        lastUpdateTime = currentTime
        
        let expectedElapsedTime: TimeInterval = 1.0 / 60.0 // Строка рассчитывает ожидаемую задержку времени. Между двумя вызовами update( _ :) должно пройти около 1/60 секунды, поскольку мы можем предположить, что приложение будет работать со скоростью 60 кадров в секунду на реальном устройстве iOS (хотя на симуляторе iOS оно, возможно, будет работать медленнее). Код, который мы добавили, помогает делать так, чтобы скейтбордистка двигалась с одной и той же скоростью независимо от того, какое устрой- ство (или симулятор) используется.
        // Рассчитываем, насколько далеко должны сдвинуться объекты 8 при данном обновлении
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime) // Чтобы рассчитать корректировку смещения, нужно разделить реально прошедшее время на ожидаемое время между вызовами (строка)
        
        
        let currentScrollAmount = scrollSpeed * scrollAdjustment // Строка определяет, чему должна равняться скорость перемещения для очередного обновления. Для этого значение scrollSpeed умножается на корректировку.
        
        updateBricks(withScrollAmount: currentScrollAmount) // Теперь, когда мы рассчитали правильное перемещение для этого обновления, вызываем метод udpateBricks( _ :) и передаем ему это значение.
        
        updateSkater()
    }
            func updateSkater() {
                if !skater.isOnGround {
                    // Устанавливаем новое значение скорости скейтбордистки 8 с учетом влияния гравитации
                    let velocityY = skater.velocity.y - gravitySpeed; skater.velocity = CGPoint(x: skater.velocity.x, y: velocityY) // Устанавливаем новое положение скейтбордистки по оси y на основе ее скорости
                    let newSkaterY: CGFloat = skater.position.y + skater.velocity.y
                    skater.position = CGPoint(x: skater.position.x, y: newSkaterY)
                    
                    // Проверяем, приземлилась ли скейтбордистка
                    if skater.position.y < skater.minimumY {
                        skater.position.y = skater.minimumY
                        skater.velocity = CGPoint.zero
                        skater.isOnGround = true
                        
                        // Определяем, находится ли скейтбордистка на земле
                        if let velocityY = skater.physicsBody?.velocity.dy {
                            if velocityY < -100.0 || velocityY > 100.0 {
                                skater.isOnGround = false
                            }
                        }
                        // Проверяем, должна ли игра закончиться
                        let isOffScreen = skater.position.y < 0.0 || skater.position.x < 0.0
                        let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
                        let isTippedOver = skater.zRotation > maxRotation || skater.zRotation < -maxRotation
                        if isOffScreen || isTippedOver {
                            gameOver()
                            
                        }
                    }
                }
                
                
            }
            
            @objc func handleTap(tapGesture: UITapGestureRecognizer) { // Мы используем @objc, так как селекторы вызываются языком разработки для iOS Objective-C
                
                // Скейтбордистка прыгает, если игрок нажимает на экран, пока 8 она находится на земле
                if skater.isOnGround { // Когда пользователь нажимает на экран, нужно убедиться, что скейтбордистка находится на земле, поэтому проверяем это условие с помощью выраженияif
                    // Задаем для скейтбордистки скорость по оси y, равную ее 8 изначальной скорости прыжка
                    skater.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 260.0)) // Применим импульс к физическому телу спрайтаskater. Когда вы применяете силу к физическому телу, то должны использовать CGVector для определения того, как эта сила действует в направлениях x (dx) и y (dy
                }
                
                
                // MARK: - SKPhysicsContactDelegate Methods
                func didBegin(_ contact: SKPhysicsContact) {
                    // Проверяем, есть ли контакт между скейтбордисткой и секцией
                    if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.brick { // С помощью проверки категории тел (строка) можно понять, произошел ли контакт между скейтбордисткой и секцией
                        skater.isOnGround = true // Если да, то в строке задаем для свойства isOnGround спрайта skater значение true, поскольку знаем, что скейтбордистка находится на земле.
                        
                        // Called before each frame is rendered
                    }
                }
                
            }
}
