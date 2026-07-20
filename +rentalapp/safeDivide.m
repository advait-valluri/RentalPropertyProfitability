function out = safeDivide(numerator, denominator)
    if abs(denominator) < eps
        out = NaN;
    else
        out = numerator / denominator;
    end
end
