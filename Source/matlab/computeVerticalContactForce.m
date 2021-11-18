function fy = computeVerticalContactForce(force, state)

    fy = force.getRecordValues(state).get(1);

end