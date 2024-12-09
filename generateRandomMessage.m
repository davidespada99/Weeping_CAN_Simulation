function [randomMsg] = generateRandomMessage()
    % Generate random CAN message
    fixedID = 100; % Random standard CAN ID (11 bits, range: 1-2047)
    randData = uint8(randi([0, 255], 1, 8)); % Random data for DLC length
    
    % Create the random CAN message
    randomMsg = canMessage(fixedID, false, 8);
    randomMsg.Data = randData;
end