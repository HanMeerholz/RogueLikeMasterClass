// This is just confirmation, remove this line as soon as you
// start making your game
System.print("Wren just got compiled to bytecode")

// The xs module is where the inteface to the engine is
import "xs" for Render, Input, Data
// The xs_math module where you will find the math tools and 
// a handy color class
import "xs_math" for Math, Color

import "xs_containers" for Grid
import "random" for Random

class TileType {
    static none { 0 }
    static floor { 1 }
    static topLeftWall  { 2 }
    static topWall  { 3 }
    static topRightWall  { 4 }
}

class Direction {
    static up    { 0 }
    static down  { 1 }
    static left  { 0 }
    static right { 1 }
}

// The game class it the entry point to your game
class Game {

    // The init method is called when all system have been created.
    // You can initialize you game specific data here.
    static initialize() {
        System.print("init")
        
        __time = 0
        __width = Data.getNumber("Width", Data.system)
        __height = Data.getNumber("Height", Data.system)
        __scale = 8

        __tileSize = 8
        __tileWidth = (__width/(__tileSize * __scale))
        __tileHeight = (__height/(__tileSize * __scale))

        var tileSheetWidth = 5
        var tileSheetHeight = 9
        var image = Render.loadImage("[game]/images/Tileset.png")
        __tiles = {            
            TileType.floor: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 23),
            TileType.topLeftWall: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 5),
            TileType.topWall: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 6),
            TileType.topRightWall: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 7)               
        }

        __playerSize = 32
        var playerSpriteWidth = 4
        var playerSpriteHeight = 4
        image = Render.loadImage("[game]/images/GoblinWalk.png")
        __playerSprites = {
            Direction.up: {
                Direction.left: Render.createGridSprite(image, playerSpriteWidth, playerSpriteHeight, 12),
                Direction.right: Render.createGridSprite(image, playerSpriteWidth, playerSpriteHeight, 8)
            },
            Direction.down: {
                Direction.left: Render.createGridSprite(image, playerSpriteWidth, playerSpriteHeight, 4),
                Direction.right: Render.createGridSprite(image, playerSpriteWidth, playerSpriteHeight, 0)
            }
        }
        __map = Grid.new(__width, __height, TileType.none)

        __playerSpeed = 100
        __playerX = 0
        __playerY = 0
        __directionX = Direction.right
        __directionY = Direction.down
        __moving = false

        var random = Random.new()
    }    

    // The update method is called once per tick.
    // Gameplay code goes here.
    static update(dt) {
        __time = __time + dt

        // Move the player
        if (Input.getKey(Input.keyA) || Input.getKey(Input.keyLeft)) {
            __playerX = __playerX - __playerSpeed * __scale * dt
            __directionX = Direction.left
            __moving = true
        } else if (Input.getKey(Input.keyD) || Input.getKey(Input.keyRight)) {
            __playerX = __playerX + __playerSpeed * __scale * dt
            __directionX = Direction.right
            __moving = true
        } else if (Input.getKey(Input.keyS) || Input.getKey(Input.keyDown)) {
            __playerY = __playerY - __playerSpeed * __scale * dt
            __directionY = Direction.down
            __moving = true
        } else if (Input.getKey(Input.keyW) || Input.getKey(Input.keyUp)) {
            __playerY = __playerY + __playerSpeed * __scale * dt
            __directionY = Direction.up
            __moving = true
        } else {
            __moving = false
        }
    }

    // The render method is called once per tick, right after update.
    static render() {
        var tileXMax = (__width/(__tileSize * __scale))
        var tileYMax = (__height/(__tileSize * __scale))
        for (i in 1 ... tileYMax - 1) {
            for (j in 1 ... tileXMax - 1) {
                var x = -__width / 2 + j * __tileSize * __scale
                var y = -__height / 2 + i * __tileSize * __scale
                Render.sprite(__tiles[TileType.floor], x, y, 0, __scale, 0.0, 0xffffffff, 0x00000000, 0)
            }
        }

        var x = __playerX - __playerSize * __scale / 2
        var y = __playerY - __playerSize * __scale / 2
        Render.sprite(__playerSprites[__directionY][__directionX], x, y, 0, __scale, 0.0, 0xffffffff, 0x00000000, 0)


    }
}