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
    static sideWall { 5 }
    static bottomLeftWall { 6 }
    static bottomWall { 7 }
    static bottomRightWall { 8 }
    static leftWall { 9 }
    static centerWall { 10 }
    static rightWall { 11 }
    static doorTopLeft { 12 }
    static doorTop { 13 }
    static doorTopRight { 14 }
    static doorLeft { 15 }
    static doorRight { 16 }
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
        __tilesWidth = (__width/(__tileSize * __scale)).floor
        __tilesHeight = (__height/(__tileSize * __scale)).floor

        var tileSheetWidth = 5
        var tileSheetHeight = 9
        var image = Render.loadImage("[game]/images/Tileset.png")
        __tiles = {            
            TileType.floor: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 23),
            TileType.topLeftWall: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 5),
            TileType.topWall: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 6),
            TileType.topRightWall: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 7),
            TileType.sideWall: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 4),
            TileType.bottomLeftWall: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 0),
            TileType.bottomWall: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 1),
            TileType.bottomRightWall: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 2),
            TileType.leftWall: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 10),
            TileType.centerWall: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 11),
            TileType.rightWall: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 12),
            TileType.doorTopLeft: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 15),
            TileType.doorTop: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 16),
            TileType.doorTopRight: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 17),
            TileType.doorLeft: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 18),
            TileType.doorRight: Render.createGridSprite(image, tileSheetWidth, tileSheetHeight, 19)                    
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

        __map = Grid.new(__tilesWidth, __tilesHeight, TileType.none)
        
        for (i in 0 ... __tilesHeight) {
            for (j in 0 ... __tilesWidth) {
                var tileType = TileType.floor

                if (i == __tilesHeight - 1) {
                    if (j == 0) {
                        tileType = TileType.topLeftWall
                    } else if (j == __tilesWidth - 1) {
                        tileType = TileType.topRightWall
                    } else {
                        tileType = TileType.topWall
                    }
                } else if (i == __tilesHeight - 2) {
                    if (j == 0 || j == __tilesWidth - 1) {
                        tileType = TileType.sideWall
                    } else {
                        tileType = TileType.centerWall
                    }
                } else if (i == 1) {
                    if (j == 0) {
                        tileType = TileType.bottomLeftWall
                    } else if (j == __tilesWidth - 1) {
                        tileType = TileType.bottomRightWall
                    } else {
                        tileType = TileType.bottomWall
                    }
                } else if (i == 0) {
                    if (j == 0) {
                        tileType = TileType.leftWall
                    } else if (j == __tilesWidth - 1) {
                        tileType = TileType.rightWall
                    } else {
                        tileType = TileType.centerWall
                    }
                } else {
                    if (j == 0 || j == __tilesWidth - 1) {
                        tileType = TileType.sideWall
                    }
                }

                __map[j, i] = tileType
            }
        }


        var random = Random.new()

        var doorWidth = 3
        var doorLeft = random.int(1, __tilesWidth - 1 - doorWidth)

        __map[doorLeft, __tilesHeight - 1] = TileType.doorTopLeft
        __map[doorLeft + 1, __tilesHeight - 1] = TileType.doorTop
        __map[doorLeft + 2, __tilesHeight - 1] = TileType.doorTopRight
        __map[doorLeft, __tilesHeight - 2] = TileType.doorLeft
        __map[doorLeft + 1, __tilesHeight - 2] = TileType.floor
        __map[doorLeft + 2, __tilesHeight - 2] = TileType.doorRight

        __playerX = 2
        __playerY = 2
        __directionX = Direction.right
        __directionY = Direction.down

    }    

    // The update method is called once per tick.
    // Gameplay code goes here.
    static update(dt) {
        __time = __time + dt

        var moving = true
        var newX = __playerX
        var newY = __playerY

        // Move the player
        if (Input.getKeyOnce(Input.keyA) || Input.getKeyOnce(Input.keyLeft)) {
            newX = newX - 1
            __directionX = Direction.left
        } else if (Input.getKeyOnce(Input.keyD) || Input.getKeyOnce(Input.keyRight)) {
            newX = newX + 1
            __directionX = Direction.right
        } else if (Input.getKeyOnce(Input.keyS) || Input.getKeyOnce(Input.keyDown)) {
            newY = newY - 1
            __directionY = Direction.down
        } else if (Input.getKeyOnce(Input.keyW) || Input.getKeyOnce(Input.keyUp)) {
            newY = newY + 1
            __directionY = Direction.up
        } else {
            moving = false
        }

        if (moving && __map[newX, newY] == TileType.floor) {
            __playerX = newX
            __playerY = newY
        }
    }

    // The render method is called once per tick, right after update.
    static render() {
        for (i in 0 ... __tilesHeight) {
            for (j in 0 ... __tilesWidth) {
                var x = -__width / 2 + j * __tileSize * __scale
                var y = -__height / 2 + i * __tileSize * __scale

                var tileType = __map[j, i]

                Render.sprite(__tiles[tileType], x, y, 0, __scale, 0.0, 0xffffffff, 0x00000000, 0)
            }
        }

        var x = -__width/2 + __tileSize * __scale * (__playerX - 1.5)
        var y = -__height/2 + __tileSize * __scale * (__playerY - 1.5)
        Render.sprite(__playerSprites[__directionY][__directionX], x, y, 0, __scale, 0.0, 0xffffffff, 0x00000000, 0)

        // Render.dbgBegin(lines)
        // Render.dbgVertex(__playerX * __tileSize * __scale, __playerY * __tileSize * __scale)
        // Render.dbgVertex((__playerX + 1) * __tileSize * __scale, __playerY * __tileSize * __scale)
        // Render.dbgVertex((__playerX + 1) * __tileSize * __scale, (__playerY + 1) * __tileSize * __scale)
        // Render.dbgVertex(__playerX * __tileSize * __scale, (__playerY + 1) * __tileSize * __scale)
        // Render.dbgEnd()
    }
}