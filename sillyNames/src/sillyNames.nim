import random

const
    FIRST_NAMES = ["Mister"]
    LAST_NAMES = ["Meeseeks"]

proc randomChoice[T](choices: openArray[T]) : T =
    let ix = rand(choices.len()-1)
    choices[ix]

proc randomFirstName() : string =
    randomChoice(FIRST_NAMES)

proc randomLastName() : string =
    randomChoice(LAST_NAMES)

proc generateSillyName*() : string =
    randomFirstName() &  " " & randomLastName()

when isMainModule:
    echo "Silly Name Generator"
    echo "===================="
    while true:
        echo generateSillyName()
        echo "Another one? (Press Enter for another)"
        var input = readLine(stdin)
        if input != "":
            echo "Terminating..."
            break

