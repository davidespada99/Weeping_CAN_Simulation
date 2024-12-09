function [zerosBitIndexes] = getZerosIndeces(message, byteIndex)
    % Extract the specified byte from the message
    messageDataByte = message.Data(byteIndex);
    
    % Initialize the array to hold indexes of zero bits
    zerosBitIndexes = [];
    
    % Loop through each bit (1 to 8)
    for i = 1:8
        % Check if the i-th bit (from left to right) is zero
        if bitget(messageDataByte, 9 - i) == 0
            % Append the bit position (1-indexed) to the result array
            zerosBitIndexes(end + 1) = i; % Correct syntax
        end
    end
end
