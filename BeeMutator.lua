speciesA = nil
speciesB = nil
speciesTarget = nil

function isBee( inBeeName )
  if inBeeName == "forestry:bee_drone_ge" or inBeeName == "forestry:bee_princess_ge" then
--    print( inBeeName.. "is a bee!" )
    return true
  else
--    print( inBeeName.." isn't a bee!" )
    return false
  end
end

function analyzeBees()
  chest = peripheral.wrap("right")
  chest_size = chest.size()
  for i=1,chest_size do
    bee = chest.getItemMeta(i)
    if bee and isBee( bee.name ) then
      if not bee.individual.analyzed then
        chest.pushItems("up",i)
        while chest.pullItems("up",9) == 0 do
          os.sleep(12)
        end
      end
    end
  end
end

function enumerateSpecies()
  chest = peripheral.wrap("right")
  chest_size = chest.size()
  for i=1,chest_size do
    bee = chest.getItemMeta(i)
    if bee and isBee( bee.name ) then
      if bee.name == "forestry:bee_drone_ge" then
        if not speciesA then
          genome = bee.individual.genome
          speciesA = genome.active.species.id
        else
          genome = bee.individual.genome
          genotype = genome.active.species.id
          if speciesA ~= genotype then
            speciesB = genotype
            print( "Base species: "..speciesA.." and "..speciesB.."." )
            return          
          end
        end
      end
    end
  end
end

function isPurebred( beeSlot )
--TODO: Handle cmd line arg or use inference.
end

function isDronePurebred()
  chest = peripheral.wrap("right")
  chest_size = chest.size()
  for i=1,chest_size do
    bee = chest.getItemMeta(i)
    if bee and isBee( bee.name ) then
      genome = bee.individual.genome
      genotype = genome.active.species.id
      phenotype = genome.inactive.species.id
      if genotype == speciesTarget and phenotype == speciesTarget then
        return true
      end  
    end
  end
  return false
end

function getPurebredTargetDroneSlot()
  chest = peripheral.wrap("right")
  chest_size = chest.size()
  for i=1,chest_size do
    bee = chest.getItemMeta(i)
    if bee and isBee( bee.name ) then
      if bee.name == "forestry:bee_drone_ge" then
        genome = bee.individual.genome
        genotype = genome.active.species.id
        phenotype = genome.inactive.species.id
        if genotype == speciesTarget and phenotype == speciesTarget then
          return i
        end
      end
    end
  end
  return nil
end

function isPurebred()
  nah, queenSlot = getQueen()
  chest = peripheral.wrap("right")
  queen = chest.getItemMeta(queenSlot)
  genome = queen.individual.genome
  genotype = genome.active.species.id
  phenotype = genome.inactive.species.id
  if genotype == speciesTarget and phenotype == speciesTarget then
    return isDronePurebred()
  end
  return false
end

function getQueen()
  chest = peripheral.wrap("right")
  for i=1,chest.size() do
    bee = chest.getItemMeta(i)
    if bee and isBee( bee.name ) then
      if bee.name == "forestry:bee_princess_ge" then
        return bee, i
      end
    end
  end
  return false
end

function isDroneTarget( inDroneSlot )
  chest = peripheral.wrap("right")
  drone = chest.getItemMeta( inDroneSlot )
  genotype = drone.individual.genome.active.species.id
  phenotype = drone.individual.genome.inactive.species.id
    print( genotype.." VS "..speciesA )
    print( phenotype.." VS "..speciesB )
  if genotype == speciesTarget then
    return true
  end
  if phenotype == speciesTarget then
    return true
  end
  return false
end

function getDrone( inQueen )
--  print( "Choosing drone..." )
  chest = peripheral.wrap("right")
  chest_size = chest.size()
  queenGenome = inQueen.individual.genome
  queenGenotype = queenGenome.active.species.id
--  print( "Looking for target drone." )
  target_purebred_slot = getPurebredTargetDroneSlot()
  if target_purebred_slot then
--    print( "Using purebred target drone "..target_purebred_slot.."." )
    drone = chest.getItemMeta(target_purebred_slot)
    return drone, target_purebred_slot
  end
--  print( "Looking for hybrid drone." )
  for i=1,chest_size do
    drone = chest.getItemMeta(i)
    if drone and isBee( drone.name ) then
      if drone.name == "forestry:bee_drone_ge" then
        if isDroneTarget( i ) then
          print("Using hyrbid drone "..i..".")
          return drone, i
        end
      end
    end
  end
--  print( "Finding drone with opposing genotype." )
  for i=1,chest_size do
    drone = chest.getItemMeta(i)
    if drone and isBee( drone.name ) then
      if drone.name == "forestry:bee_drone_ge" then
        droneGenome = drone.individual.genome.active
        droneGenotype = droneGenome.species.id
        if queenGenotype ~= droneGenotype then
          print("Using input species as drone.")
          return drone, i
        end
      end
    end
  end
  print("ERROR: Needs at least two species of drones.") 
  return drone, slot
end

function wait_for_apiary()
  chest = peripheral.wrap("right")
  while not getQueen() do
    for i=3,8 do
      chest.pullItems("south",i)
    end
    os.sleep(20)
  end
end

function breedPair( queenSlot, droneSlot )
--  print( "Breeding bees..." )
  chest = peripheral.wrap("right")
  chest.pushItems("south",queenSlot)
  chest.pushItems("south",droneSlot,1)
  wait_for_apiary()
--  print( "Bees bred." )
end

function breedBees()
  while not isPurebred() do
    queen, queenSlot = getQueen()
    drone, droneSlot = getDrone( queen )
    print( "Breeding "..queen.displayName.." with "..drone.displayName.."." )
    breedPair( queenSlot, droneSlot )
    analyzeBees()
  end
  print( "Princess and drone purebred." )
end

args = {...}

function start()
  speciesTarget = args[1]
  analyzeBees()
  enumerateSpecies()
  breedBees()
end

start()