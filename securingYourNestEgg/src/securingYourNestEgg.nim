import sequtils
from random import rand
import ggplotnim
import tables

proc randomInt(mn, mx: int) : int =
  rand(1) * (mx - mn) + mn

proc randomFloat(mn, mx: float) : float =
  rand(1.0) * (mx - mn) + mn

proc fakeInvestment(t: int) : float =
  const
    m = 1.5
    b = 0.25
    mn = -1
    mx = 2.5

  let behavior = randomFloat(mn, mx)
  result = behavior * ((float t) * m + b)

proc fakeRates(t: int) : float =
  const
    m = 0.5
    b = 0.10
    mn = -0.9
    mx = 0.9

  let behavior = randomFloat(mn, mx)
  result = behavior * ((float t) * m + b)

proc generateRandomReturns(startYear, endYear: int) : seq[float] =
  var output: seq[float] = @[]
  for i in countup(startYear, endYear):
    output.add(fakeInvestment(i))

  result = output

proc generateRandomRates(startYear, endYear: int) : seq[float] =
  var output: seq[float] = @[]
  for i in countup(startYear, endYear):
    output.add(fakeRates(i))

  result = output


type
  Simulation = object
    numCases*: int
    startValue*: int
    minYears*: int
    maxYears*: int
    mostLikelyYears*: int
    inflationRate*: float
    withdrawal*: float

# Run a monte carlo simulation on investment returns
proc simulate(sim: Simulation, returns: seq[float], rates: seq[float]) : (seq[int], int) =
  var
    caseCount = 0
    bankruptCount = 0
    outcome:seq[int] = @[]

    investments = 0
    startYear = 0
    duration = 0.0
    endYear = 0
    bankrupt = false
    lifespan: seq[int]
    lifespanReturns: seq[float]
    lifespanInflationRates: seq[float]
    adjustment = 0

  while caseCount < sim.numCases:
    investments = sim.startValue
    startYear = randomInt(0, returns.len())
    duration = randomFloat((float sim.minYears),(float sim.maxYears))
    endYear = startYear + (int duration)
    lifespan = toSeq(startYear..<endYear)
    bankrupt = false

    lifespanReturns = @[]
    for i in lifespan:
      lifespanReturns.add(returns[i.mod(returns.len())])
      lifespanInflationRates.add(rates[i.mod(rates.len())])

    for ix, (lifespanReturn, lifespanRate) in zip(lifespanReturns, lifespanInflationRates):
      if ix == 0:
        adjustment = if ix == 0:
                      (int sim.withdrawal)
                     else:
                      (int sim.withdrawal * (1.0 + sim.inflationRate))

      investments -= adjustment
      investments = (int (float investments) * (1 + lifespanRate))

      bankrupt = investments < 0

      if bankrupt:
        break

    if bankrupt:
      outcome.add(0)
      bankruptCount += 1
      echo "Gone Bankrupt ", bankruptCount
    else:
      outcome.add(investments)
    echo "Investments: ", investments

    caseCount += 1

  return (outcome, bankruptCount)


proc plotReturns(values: seq[int]) =
  let
    x = toSeq(1..values.len())
    data = seqsToDf(x, values)
  ggplot(data, aes("x", "values")) +
    geom_point() +
    geom_line() +
    ggtitle("Returns per year") +
    xlab("Year") +
    ylab("Return (USD)") +
    ggsave("returns.pdf")

when isMainModule:
  echo "======================"
  echo "Securing Your Nest Egg"
  echo "----------------------"

  echo "Fake Investment at time 1"
  echo fakeInvestment(1)

  let
    returnsFromYears1to20 = generateRandomReturns(1, 20)
    ratesFromYears1to20 = generateRandomRates(1, 20)
  echo "Random returns between year 1 and 20"
  echo returnsFromYears1to20


  echo "Simulation of nest egg between years 1 and 20"
  let returnsSimulation =  Simulation(numCases: 50_000,
                                      startValue: 2_000_000,
                                      minYears: 18,
                                      maxYears: 40,
                                      mostLikelyYears: 25,
                                      inflationRate: 0.04,
                                      withdrawal: 10_000.0)

  let (simulatedReturns, bankruptCount) = returnsSimulation.simulate(returnsFromYears1to20,
                                                                     ratesFromYears1to20)

  echo "Bankrupt count: ", bankruptCount
  plotReturns(simulatedReturns)
