function xcom = computeXCoM(com_p, com_v)

    g = 9.80665;
    xcom = com_p + com_v/sqrt(g/com_p(2));

end