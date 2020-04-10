import sequtils
import strutils
import sugar

const
    VOWELS = "aeiou"
    PUNCT = ",.-'\"?!)("

proc pigLatin(word : string) : string =
    let first = word[0].toLowerAscii()
    let last = word[^1]
    var suffix = "ay"
    var punct = ""
    var end_ix = len(word)
    if first in VOWELS:
        suffix = "way"

    if last in PUNCT:
        punct = "" & last
        end_ix -= 1

    word[1..<end_ix] & first & suffix & punct

proc convertTextToPigLatin(text : string) : string =
    var lines = text.split('\n')
    var output: seq[string] = @[]
    for line in lines:
        output.add(line.splitWhitespace()
                       .map(word => pigLatin(word))
                       .join(" "))

    output.join("\n")

when isMainModule:
    while true:
        echo "=============================="
        echo "Input some text"
        let text = readLine(stdin)
        echo "------------------------------"
        echo "Converting input to Pig Latin"
        echo convertTextToPigLatin(text)

        echo "------------------------------"
        echo "Try again? (Press Enter to try again)"

        let input = readLine(stdin)
        if input != "":
            echo "Terminating..."
            break
