clc; clearvars; close all;

m = 4; k = 11; b = 1;
n = 2^m - 1;

general_counter = 0;
mismatch_counter = 0;

for i = 1 : 10000
    for j = 1 : n
        input_data = randi([0 n], 1, k);
        
        encoded = RS_sys_enc(m, b, input_data);

        snr = 17; 
        received = gf(fix(awgn(double(encoded.x), snr)), m);
        
        decoded_my = dec_PGC_RS(k, b, received);
        decoded_gm = rsdec(received, n, k);

        general_counter = general_counter + 1;
        
        decoded_right = isequal(decoded_my(1:k), decoded_gm);
        mismatch_word = [];
        if (~decoded_right)
            % fprintf('Encoded word   '); disp(encoded.x);
            % fprintf('Received word  '); disp(received.x);
            % fprintf('Decoded word my'); disp(decoded_my.x);
            % fprintf('Decoded word gm'); disp(decoded_gm.x);
            mismatch_counter = mismatch_counter + 1;
            mismatch_word = [received mismatch_word];
            % return;
        end
    end
end
fprintf('Total procentage of decoding mismatch is %d\n', mismatch_counter/general_counter);