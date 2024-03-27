function [codeword, t] = BCH_sys_enc(m, msg)
    % Performs systematic encoding of BCH code over GF2
    % Input arguments:
    % m - field order, integer in range [1 : 16] = log2(n + 1)
    % msg - message to encode
    
    arguments
        m (1,1) double {mustBeInteger, mustBeInRange(m, 1, 16)} 
        msg (1,:) {mustBeVector}
    end
    
    n = 2^m - 1; 
    k = length(msg);
    
    [generator, t] = bchgenpoly(n, k);
    [~, remainder] = deconv([msg zeros(1, n-k)], generator);
    codeword = [msg zeros(1, n - k)] + remainder;

end

