import Terminal
import strformat
import random
import tables
import sequtils
import sugar
import ggplotnim

proc printLine(s: string, fg: ForegroundColor = fgDefault, bg: BackgroundColor = bgDefault) =
    setForegroundColor(fg)
    stdout.writeLine s
    resetAttributes()

proc title(s: string) =
    stdout.writeLine "============================="
    setStyle({styleBright, styleUnderscore})
    setForegroundColor(fgCyan)
    stdout.writeLine s
    resetAttributes()

proc printItalic(s: string, fg: ForegroundColor = fgDefault, bg: BackgroundColor = bgDefault) =
    setStyle({styleItalic})
    printLine(s, fg, bg)

type

    ## The Drake Equation
    ## Goal: Estimate the number of civilizations in our galaxy whose electromagnetic emissions are detectable
    DrakeEq* = object
        rStarFormation: float # The average rate of star formation in the galaxy (new stars per year)
        fStarsWithPlanets: float # Fraction of stars with planets
        nGoldyLocks: float # the average number of planets with an enviroment suitable for life (for stars with planets)
        fDevelopLife: float # Fraction of planets that develop life
        fIntelligentLife: float # Fraction of planets that develop intelligent, civilized life
        fDetectableLife: float # Fraction of planets with life that release detectable signs into space
        lYearsOfEmissions: float # Length of time in years that civilizations release detectable signs
        description: string # description of the drake equation values


proc estimate*(drake: DrakeEq): float =
    result = drake.rStarFormation *
             drake.fStarsWithPlanets *
             drake.nGoldyLocks *
             drake.fDevelopLife *
             drake.fIntelligentLife *
             drake.fDetectableLife *
             drake.lYearsOfEmissions

proc drakeEstimateExample() =
    "\tEstimate the number of trasnmitting civilizations using the Drake Equation".printLine()
    let drake1961 = DrakeEq(rStarFormation: 1,
                            fStarsWithPlanets: 0.35,
                            nGoldyLocks: 3,
                            fDevelopLife: 1.0,
                            fIntelligentLife: 1.0,
                            fDetectableLife: 0.15,
                            lYearsOfEmissions: 50_000_000,
                            description: "The Drake Equation Estimate for 1961, given in Table 10-1 of \"Impractical Python Projects\""
                            )
    let msg = fmt"Drake Equation Estimate: {drake1961.estimate():.2f}"
    ("\t\t" & drake1961.description).printItalic(fgYellow)
    ("\t\t" & msg).printLine(fgGreen)

proc probabilityOfDetection() =
    "\tCalculating the Probability of Detection for a Range of Civilizations".printLine()
    const nEquivalentVolumes = 1000 # number of locations in which to place civilizations
    const nMaxCivilizations = 5000 # max number of advanced civilizations
    const nTrials = 10 # number of times to model a given number of civilizations
    const civilizationStepSize = 100 # civilization count step size
    const plotName = "civilizationsPerVolume_vs_probability.pdf"
    var x: seq[float] = @[]
    var y: seq[float] = @[]

    for nCivilzations in countup(2, nMaxCivilizations, civilizationStepSize):
        let civilizationsPerVolume = nCivilzations /
                                     nEquivalentVolumes
        var nSingleCivilizations = 0
        for trial in 0..nTrials:
            var locations: seq[int] = @[]
            while locations.len() < nCivilzations:
                let location: int = rand(1..nEquivalentVolumes)
                locations.add(location)
            var overlapCount = toCountTable(locations)
            var overlapRollup = toCountTable(toSeq(overlapCount.values))
            nSingleCivilizations += overlapRollup[1]

        let probability = 1 - (nSingleCivilizations / (nCivilzations * nTrials))

        x.add(civilizationsPerVolume)
        y.add(probability)

    let df = seqsToDf(x, y)
    ggplot(df, aes("x", "y")) +
        geom_point() +
        ggtitle("CivilizationsPerVolume vs. Probability") +
        xlab("Civilization / Volume") +
        ylab("Probability of 2+ Civilizations per Location") +
        ggsave(plotName)

    echo "Plot saved to ", plotName






when isMainModule:
    "Are we alone? Exploring the Fermi Paradox".title()

    drakeEstimateExample()
    probabilityOfDetection()

