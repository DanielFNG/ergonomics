%% Inputs
osim = '';
reference_states = '';

%% Define bounds for both the tracking & prediction problems
DefineBounds;

%% Produce reference coordinates for the tracking problem from input data
ProduceReferenceCoordinates;

name, w_states, w_controls, osim, input)
solution = produceTrackingGuess('TrackingGuess', );