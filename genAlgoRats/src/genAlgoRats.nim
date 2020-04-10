from random import rand, shuffle
from stats import mean
from sequtils import map, filter, zip
from sugar import `=>`
from algorithm import sort
from strformat import fmt, `&`

const
  goalWeight = 50000   # mass in grams
  nRats = 10           # max number of rats
  initMinWeight = 200.0  # min initial mass in grams
  initMaxWeight = 600.0  # max initial mass in grams
  pMutation = 0.01     # probability of mutation occurring during breeding
  modMinMutation = 0.5 # modifier of least beneficial mutation
  modMaxMutation = 1.2 # modifier of most beneficiial mutation
  nRatsInLitter = 8    # number of rats in a litter
  nLittersInYear = 10  # number of litters per year
  nGenerations = 500   # max number of generations

const # TODO Create a gender type
  Female = "Female"
  Male = "Male"

type
  Rat* = object
    weight: float
    gender: string

proc triangular(left, right: float) : float =
  let
    m = left + (right-left)/2
    x = rand(1.0) * (right-left) + left

    p = if left <= x and x <= m:
         2*(x-left)/((right-left)*(m-left))
        elif m <= x and x <= right:
         2*(right-x)/((right-left)*(right-m))
        else: 0.0

  # TODO: Generate weight from `p`
  result = 0.0
# get all weights of the rat population
proc getWeights(rats: seq[Rat]): seq[float] =
  rats.map(r => r.weight)

# Get a random weight between global min, max weights
proc randomWeight(): float =
  triangular(initMinWeight, initMaxWeight)

# Get a random weight between the max and min values
proc randomWeight(first, second: float): float =
  triangular(min(first, second),
             max(first, second))


# Get a random gender - Male or Female
proc randomGender(): string =
  result = Female
  if rand(1.0) < 0.5:
    result = Male

proc maxWeight(rats: seq[Rat]): float =
  rats.getWeights().max()

proc meanWeight(rats: seq[Rat]): float =
  rats.getWeights().mean()

# Create a population size of the global population variable
proc populate(): seq[Rat] =
  var population: seq[Rat] = @[]
  for _ in countup(1, nRats):
    population.add(Rat(weight: randomWeight(),
                       gender: randomGender()))

  return population

# Calculate fitness of rat poulation compared to global goal
proc fitness(rats: seq[Rat]): float =
  mean(getWeights(rats))/goalWeight

# Comparison function between two rats - return -1 if first rat is heavier
# than the second rat
proc cmpRats(rat1, rat2: Rat): int =
  result = if rat1.weight > rat2.weight: -1 else: 1

# Select the highest 50% of weights from each gender of the rat population
# bounded by the global rat population size
proc select(rats: var seq[Rat]): (seq[Rat], seq[Rat]) =
  sort(rats, cmpRats)
  let
    males = rats.filter(r => r.gender == "Male")
    females = rats.filter(r => r.gender == "Female")
    halfPopulation = min(nRats.div(2)-1, nRats.div(2))
    halfMales = min(halfPopulation, males.len().div(2))
    halfFemales = min(halfPopulation, females.len().div(2))

  return (males[0..<halfMales], females[0..<halfFemales])

# Mutate the given rat
proc mutate(rat: Rat) : Rat =
  Rat(weight: rat.weight * rand(modMinMutation..modMaxMutation),
      gender: rat.gender)

# Breed two rats
proc breed(rat1: Rat, rat2: Rat): Rat =
  Rat(weight: randomWeight(rat1.weight, rat2.weight),
      gender: randomGender())

# Breed two sub populations, by gender, of rats to create a new population
# The new population is governed by the global variable for litter size
proc breed(maleRats: var seq[Rat], femaleRats: var seq[Rat]): seq[Rat] =
  shuffle(maleRats)
  shuffle(femaleRats)
  var children: seq[Rat] = @[]
  for (male, female) in zip(maleRats, femaleRats):
    for _ in countup(1, nRatsInLitter):
      var rat = breed(male, female)
      if rand(1.0) > pMutation:
        rat = mutate(rat)

      children.add(rat)

  return children

proc show(rats: seq[Rat]) =
  for rat in rats:
    echo " ", rat

when isMainModule:
  echo "Genetic Algorithm for breeding giant rats"
  echo "========================================="

  var rats = populate()

  for rat in rats:
    echo rat

  echo "Starting Fitness: ", fitness(rats)

  echo "Selecting Largest Rats by gender"
  echo " Males:"
  var (males, females) = select(rats)
  show(males)

  echo " Females:"
  show(females)

  echo "Breeding a new population of rats"
  show(breed(males, females))

  var genCount = 0

  echo "---------------------------------"
  echo "Run the steps above while the"
  echo "fitness level is less than the"
  echo "goal value or number of max"
  echo "generations is reached."
  while (fitness(rats) < 1.0 and
         fitness(rats) > 0.0 and
         genCount < nGenerations):
    (males, females) = select(rats)
    rats = breed(males, females)
    genCount += 1
    echo "..........................."
    echo " Generation - ", genCount
    echo &"""{"   Fitness":<10}:""", fmt"{fitness(rats):>18.3f}"
    echo &"""{"   Max Weight":<10}:""", fmt"{maxWeight(rats):>15.3f}"
    echo &"""{"   Mean Weight":<10}:""", fmt"{meanWeight(rats):>14.3f}"

  echo "Final Generation:"
  echo " Fitness: ", fitness(rats)
  show(rats)
