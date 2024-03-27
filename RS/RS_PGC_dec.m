function decoded_codeword =  RS_PGC_dec(k, b, received_word)
    % Performs PGC decoding of Reed-Solomon code over GF(2^m)
    % Input arguments:
    % k - message length
    % b - constructive parameter
    % received_word - message to decode

    arguments
        k (1,1) double {mustBeInteger}
        b (1,1) double {mustBeInteger}
        received_word (1,:) {mustBeVector}
    end

    n = length(received_word);
    m = log2(n + 1);
    
    % -----------------------------------------------------------------------
    % evaluate syndrome vector components
    % -----------------------------------------------------------------------
    t = floor((n - k) / 2);
    alpha = gf(2, m); % Primitive element in GF(2^m)
    s = gf(zeros(1, 2*t), m);
    for i = 1 : 2*t
        evaluation_point = alpha^(i + b - 1);
        evaluation_matrix = gf(zeros(1, n), m);
        for j = 1 : n
            evaluation_matrix(j) = evaluation_point^(j - 1);
        end
        s(i) = fliplr(received_word)*evaluation_matrix';
    end
    % fprintf('Syndrome poly with ascending! powers:'); disp(s.x);
    
    % -----------------------------------------------------------------------
    % construct initial syndrome matrix
    % -----------------------------------------------------------------------
    syndrome_matrix = gf(zeros(t, t), m);
    for i = 1 : t
        for j = 1 : t
            syndrome_matrix(i, j) = s(i + j - 1);
        end
    end
    
    % -----------------------------------------------------------------------
    % find number of error occured
    % -----------------------------------------------------------------------
    while (det(syndrome_matrix) == 0)
        syndrome_matrix = syndrome_matrix(1:end-1, 1:end-1);
        t = t - 1;
        if (t == 0)
            % fprintf('There are no errors in recieved word!\n');
            decoded_codeword = received_word;
            return;
        end
    end
    
    % =======================================================================
    % perform PGC decoding algorithm for current number of errors
    % =======================================================================
    if (t == 1)
        % -----------------------------------------------------------------------
        % find coeff of error-location polynomial
        % -----------------------------------------------------------------------
        A1 = s(2) / s(1);
        if (A1 == 0)
            % fprintf('Uncorrectable error occured\n');
            decoded_codeword = received_word;
            return
        end
    
        % -----------------------------------------------------------------------
        % find root of error-location polynomial
        % -----------------------------------------------------------------------
        root = 1 / A1;
    
        % -----------------------------------------------------------------------
        % evaluate position of error
        % -----------------------------------------------------------------------
        error_position = 1 / root;
        error_location = log(error_position);
        % fprintf('Error location:'); disp(error_location);
    
        % -----------------------------------------------------------------------
        % find error-magnitude polynomial
        % -----------------------------------------------------------------------
        error_value = s(1) / error_position^(b);
        % fprintf('Error value:'); disp(error_value.x);
        error_poly = gf(zeros(1, n), m);
        error_poly(end-error_location) = error_value;
    
        % -----------------------------------------------------------------------
        % perform error correction
        % -----------------------------------------------------------------------
        decoded_codeword = error_poly + received_word;
        % fprintf('Corr codeword with descending powers:'); disp(decoded_codeword.x);
        return;
    elseif (t == 2)
        % -----------------------------------------------------------------------
        % find coeffs of error-location polynomial
        % -----------------------------------------------------------------------
        % for t = 2 error location poly is:
        % [S1 S2][A1]=[S4]
        % [S2 S3][A2]=[S3]
        A2 = (s(2)*s(4) + s(3)*s(3)) / (s(1)*s(3) + s(2)^2);
        A1 = (s(1)*s(4) + s(2)*s(3)) / (s(1)*s(3) + s(2)^2);
    
        % -----------------------------------------------------------------------
        % find roots of error-location polynomial
        % -----------------------------------------------------------------------
        root = gf(zeros(1, 2), m);
        counter = 0;
        for i = 0 : (n - 1)
            try_eval = polyval([A2 A1 1], alpha^i);
            if (try_eval == 0)
                root(counter + 1) = alpha^i;
                counter = counter + 1;
                if (counter == t)
                    break;
                end
            end
        end
        if (counter ~= t) || (length(unique(root.x)) ~= length(root.x))
            % % fprintf('Cannot find t non-zero unique roots of error-location poly\n');
            decoded_codeword = received_word;
            return;
        end
    
        % -----------------------------------------------------------------------
        % evaluate positions of errors
        % -----------------------------------------------------------------------
        loc = 1 ./ root;
        % error_positions = log(loc);
        % fprintf('Error locations are:'); disp(error_positions);
    
        % -----------------------------------------------------------------------
        % find error-magnitude polynomial
        % -----------------------------------------------------------------------
        % for t = 2 error magnitude poly is:
        % [L1 L1^2][E2]=[S2]
        % [L2 L2^2][E1]=[S1]
        err_val_2 = (s(2)*(loc(1)^b) + s(1)*(loc(1)^(b+1))) / ((loc(1)^b)*(loc(2)^(b+1)) + (loc(2)^(b))*(loc(1)^(b+1)));
        err_val_1 = (s(2)*(loc(2)^b) + s(1)*(loc(2)^(b+1))) / ((loc(1)^b)*(loc(2)^(b+1)) + (loc(2)^(b))*(loc(1)^(b+1)));
        error_poly = gf(zeros(1, n), m);
        for j = n : -1 : 1
            check_point = alpha^(j - n - 1);
            if (check_point == loc(1))
                error_poly(n - j + 1) = error_poly(n - j + 1) + err_val_1;
            else 
                if (check_point == loc(2))
                    error_poly(n - j + 1) = error_poly(n - j + 1) + err_val_2;
                end
            end
        end
        % fprintf('Estimat error with descending powers:'); disp(error_poly.x);
    
        % -----------------------------------------------------------------------
        % perform error correction
        % -----------------------------------------------------------------------
        decoded_codeword = error_poly + received_word;
        % fprintf('Corr codeword with descending powers:'); disp(decoded_codeword.x);
        return;
    elseif (t == 3)
        % -----------------------------------------------------------------------
        % find coeffs of error-location polynomial
        % -----------------------------------------------------------------------
        % for t = 3 error location poly is:
        % [S1 S2 S3][A3]=[S4]
        % [S2 S3 S4][A2]=[S5]
        % [S3 S4 S5][A1]=[S6]
        A3 = (s(2)*s(4)*s(6) + s(6)*s(3)^2 + s(2)*s(5)^2 + s(4)^3) / ... 
             (s(1)*s(3)*s(5) + s(5)*s(2)^2 + s(1)*s(4)^2 + s(3)^3);
        A2 = (s(2)*s(3)*s(6) + s(3)*s(4)^2 + s(1)*s(5)^2 + s(5)*s(3)^2 + s(2)*s(4)*s(5) + s(1)*s(4)*s(6)) / ...
             (s(1)*s(3)*s(5) + s(3)^3 + s(5)*s(2)^2 + s(1)*s(4)^2);
        A1 = (s(1)*s(3)*s(6) + s(2)*s(4)^2 + s(4)*s(3)^2 + s(6)*s(2)^2 + s(2)*s(3)*s(5) + s(1)*s(4)*s(5)) / ...
             (s(1)*s(3)*s(5) + s(3)^3 + s(5)*s(2)^2 + s(1)*s(4)^2);
    
        % -----------------------------------------------------------------------
        % find roots of error-location polynomial
        % -----------------------------------------------------------------------
        root = gf(zeros(1, 3), m);
        counter = 0;
        for i = 0 : (n - 1)
            try_eval = polyval([A3 A2 A1 1], alpha^i);
            if (try_eval == 0)
                root(counter + 1) = alpha^i;
                counter = counter + 1;
                if (counter == t)
                    break;
                end
            end
        end
        if (counter ~= t) || (length(unique(root.x)) ~= length(root.x))
            % fprintf('Cannot find t non-zero unique roots of error-location poly\n');
            decoded_codeword = received_word;
            return;
        end
    
        % -----------------------------------------------------------------------
        % evaluate positions of errors
        % -----------------------------------------------------------------------
        loc = 1 ./ root;
        % error_positions = log(loc);
        % fprintf('Error locations are:'); disp(error_positions);
    
        % -----------------------------------------------------------------------
        % find error-magnitude polynomial
        % -----------------------------------------------------------------------
        % for t = 3 error magnitude poly is:
        % [L1   L2   L3  ][E1]=[S1]
        % [L1^2 L2^2 L3^2][E2]=[S2]
        % [L1^3 L2^3 L3^3][E3]=[S3]
        err_values = ([loc(1)^b    , loc(2)^b    , loc(3)^b; ...
                       loc(1)^(b+1), loc(2)^(b+1), loc(3)^(b+1); ...
                       loc(1)^(b+2), loc(2)^(b+2), loc(3)^(b+2)]) \ [s(1); s(2); s(3)];
        error_poly = gf(zeros(1, n), m);
        for j = n : -1 : 1
            check_point = alpha^(j - n - 1);
            if (check_point == loc(1))
                error_poly(n - j + 1) = error_poly(n - j + 1) + err_values(1);
            elseif (check_point == loc(2))
                error_poly(n - j + 1) = error_poly(n - j + 1) + err_values(2);
            elseif (check_point == loc(3))
                error_poly(n - j + 1) = error_poly(n - j + 1) + err_values(3);
            end
        end
        % fprintf('Estimat error with descending powers:'); disp(error_poly.x);
    
        % -----------------------------------------------------------------------
        % perform error correction
        % -----------------------------------------------------------------------
        decoded_codeword = error_poly + received_word;
        % fprintf('Corr codeword with descending powers:'); disp(decoded_codeword.x);
        return
    else 
        % -----------------------------------------------------------------------
        % find coeffs of error-location polynomial
        % -----------------------------------------------------------------------
        B = gf([zeros(t, 1)], m);
        for i = 1 : t
            B(i) = s(t + i);
        end
        sigma = (syndrome_matrix \ B)';
        sigma(t + 1) = 1;
    
        % -----------------------------------------------------------------------
        % find roots of error-location polynomial
        % -----------------------------------------------------------------------
        r = roots(sigma);
        if (isempty(r)) || (length(r) < t) || (length(unique(r.x)) ~= length(r.x))
            % fprintf('Cannot find t non-zero unique roots of error-location poly\n');
            decoded_codeword = received_word;
            return
        end
    
        % -----------------------------------------------------------------------
        % evaluate positions of errors
        % -----------------------------------------------------------------------
        position = 1 ./ r;
        % error_positions = log(position);
        % fprintf('Error locations are:'); disp(error_positions);
        position_matrix = gf(zeros(t, t), m);
        for i = 1 : t
            for j = 1 : t
                position_matrix(i, j) = position(j)^(i + b - 1);
            end
            B(i) = s(i);
        end
    
        % -----------------------------------------------------------------------
        % find error-magnitude polynomial
        % -----------------------------------------------------------------------
        value = (position_matrix \ B);
        est_error = gf([zeros(1, n)], m);
        for i = 1 : t
            for j = 1 : n
                val = alpha^(j - 1);
                if val == position(i)
                    est_error(j) = est_error(j) + value(i);
                end
            end
        end
        est_error = fliplr(est_error);
        % fprintf('Estimat error with descending powers:'); disp(est_error.x);
    
        % -----------------------------------------------------------------------
        % perform error correction
        % -----------------------------------------------------------------------
        decoded_codeword = received_word + est_error;
        % fprintf('Corr codeword with descending powers:'); disp(decoded_codeword.x);
        return
    end
end
