function codeword = RS_sys_enc(m, b, msg)
    % Performs systematic encoding of Reed-Solomon code over GF(2^m)
    % Input arguments:
    % m - field order, integer in range [1 : 16] = number of bits per symbol
    % b - constructive parameter
    % msg - message to encode
    
    arguments
        m (1,1) double {mustBeInteger, mustBeInRange(m, 1, 16)} 
        b (1,1) double {mustBeInteger}
        msg (1,:) {mustBeVector}
    end
    
    n = 2^m - 1; 
    k = length(msg);
    
    generator = rsgenpoly(n, k, [], b);
    [~, remainder] = deconv([msg zeros(1, n - k)], generator);
    codeword = [msg zeros(1, n - k)] + remainder;

end