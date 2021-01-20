run once lib.

function main {
    rcountdown().
    until ship:apoapsis >= 80000 {
      doAscentProfile().
    }
    doShutdown().
    doCircularization().
    print "It ran!".
    wait until false.
}

function doAscentProfile {
    lock targetpitch to 88.963 - 1.03287 * alt:radar^0.409511.
    set targetdirection to 90.
    lock steering to heading(targetdirection, targetpitch).
    stageCheck().
    }


function doCircularization {
  local circList is list(time:seconds + 30, 0).
  set circList to improveConverge(circList, eccentricityScore@).
  executeManeuver(list(circList[0], 0, 0, circList[1])).
}

// takes in a list. (a lower number is better)
function eccentricityScore {
  parameter data.
  local mnv is node(data[0], 0, 0, data[1]).
  addManeuverToFlightPlan(mnv).
  local scoreResult is mnv:orbit:eccentricity.
  removeManeuverFromFlightPlan(mnv).
  return scoreResult.
}

function improveConverge {
  parameter data, scoreFunction.
  for stepSize in list(100, 10, 1) {
    until false {
      local oldScore is scoreFunction(data).
      set data to improve(data, stepSize, scoreFunction).
      if oldScore <= scoreFunction(data) {
      break.
    }
  }
 }
 return data.
}

function improve {
  parameter data, stepSize, scoreFunction.
  local scoreToBeat is scoreFunction(data).
  local bestCandidate is data.
  local candidates is list().
  local index is 0.
  until index >= data:length {
    local incCandidate is data:copy().
    local decCandidate is data:copy().
    set incCandidate[index] to incCandidate[index] + stepSize.
    set decCandidate[index] to decCandidate[index] - stepSize.
    candidates:add(incCandidate).
    candidates:add(decCandidate).
    set index to index + 1.
  }
  for candidate in candidates {
    local candidateScore is scoreFunction(candidate).
    if candidateScore < scoreToBeat {
      set scoreToBeat to candidateScore.
      set bestCandidate to candidate.
    }
  }
  return bestCandidate.
}

main().

