function y = parameterisedAssistance(x, start)

    y = sin((pi/50)*(x - start));
    y(x <= start) = 0;
    y(x > start + 50) = 0;

end