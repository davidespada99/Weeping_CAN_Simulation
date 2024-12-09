function attackMsg = createAttackMessage(victimMsg, idVictim)

    % Helper function --> to convert a byte to an 8-bit binary string
    function binaryByte = byteToBinary(byte)
        binaryByte = dec2bin(byte, 8);  % Convert byte to binary and ensure it's 8 bits
    end

    attackMsg = canMessage(idVictim, false, 8);
    attackMsg.Data = victimMsg.Data; % Copy payload

    % Introduce a bit error at a random position
    byteIndex = ceil(randi([1, 64]) / 8); % Random byte index
    zerosIndeces = getZerosIndeces(attackMsg, byteIndex); % Find zero bits

    if ~isempty(zerosIndeces) % Ensure there are zero bits available
        randomZeroBit = randi(length(zerosIndeces));
        randomZeroBitPosition = zerosIndeces(randomZeroBit);

        % Set the selected bit to 1 (recessive)
        attackMsg.Data(byteIndex) = bitset(attackMsg.Data(byteIndex), ...
                                       9 - randomZeroBitPosition, 1);

        % Display the modified byte in binary format
        disp(['Modified Byte (Binary): ' byteToBinary(attackMsg.Data(byteIndex)) ...
              ', Error in Byte ' num2str(byteIndex) ...
              ', Bit ' num2str(randomZeroBitPosition)]);
    else
        attackMsg = []; % Return empty if no zero bits are available
    end
end



