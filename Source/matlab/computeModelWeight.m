function weight = computeModelWeight(model, state)

    g = model.getGravity().get(1);
    weight = abs(model.getTotalMass(state) * g);

end