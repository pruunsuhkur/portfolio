clc; clearvars; close all;

m = 5; k = 11; n = 2^m - 1;

general_counter = 0;
mismatch_counter = 0;

for i = 1 : 10000
    for j = 1 : n
        input_data = randi([0 1], 1, k);
        [encoded, t] = BCH_sys_enc(m, input_data);

        error = gf(randi([0 1], 1, n));
        received = encoded + error;

        decoded_my = BCH_PGC_dec(k, t, received);
        decoded_gm = bchdec(received, n, k);

        if (~isequal(decoded_gm.x, decoded_my.x))
            mismatch_counter = mismatch_counter + 1;
            % return;
        end
        general_counter = general_counter + 1;
    end
end
fprintf('Total procentage of decoding mismatch is %d\n', mismatch_counter/general_counter);