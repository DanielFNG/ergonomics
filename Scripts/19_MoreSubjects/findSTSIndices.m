function indices = findSTSIndices(ik)
    hip = ik.getColumn('hip_flexion_r');
    hip_d = ZeroLagButtFiltfilt(1/100, 6, 4, 'lp', diff(hip));
    lumbar = ik.getColumn('lumbar');
    lumbar_d = ZeroLagButtFiltfilt(1/100, 6, 4, 'lp', diff(lumbar));
    mid = round(length(hip_d)/2);
    hip_d(1:mid) = 0.1;
    finish = find(abs(hip_d) < 0.1, 1, 'first');
    start = find(abs(lumbar_d) > 0.1, 1, 'first');
    indices = start:finish;
end