% Create and configure virtual CAN channels
attacker = canChannel('MathWorks', 'Virtual 1', 1); % Attacker
victim = canChannel('MathWorks', 'Virtual 1', 2);   % Victim

% Start the channels
start(attacker);
start(victim);

% Simulation parameters
idVictim = 100; % Victim's CAN ID

tecA = 0; % TEC for Attacker
tecV = 0; % TEC for Victim

counter = 1; % Total cycles
skipCount = 0; % Skip attack every skipCount-th cycle

attackCounter = 0; % The total effective amount of injections
attackRatio = 5; % The number of messages that attacker can send in a period to recover tecA

% Victim's periodic message
victimMsg = canMessage(idVictim, false, 8);
victimMsg.Data = uint8([22 17 56 34 48 59 67 79]);

% Arrays to store TEC values and cycle numbers
tecA_values = [];
tecV_values = [];
counter_values = [];


disp('WeepingCAN Attack Started...');

%% Main WeepingCAN Simulation Loop
while tecV < 255 && tecA < 255
    disp('------------------------------------------------------')
    disp(['Cycle : ' num2str(counter)]);
   
    % Store TEC values and counter for plotting
    tecA_values = [tecA_values, tecA];
    tecV_values = [tecV_values, tecV];
    counter_values = [counter_values, counter - 1];

    % Victim sends a periodic message
    transmit(victim, victimMsg);

    % Print the victim timestamp
    victimTimestamp = datestr(now, 'HH:MM:SS.FFF');
    disp(['Victim Timestamp: ' victimTimestamp ]);

    %% Attack
    if (skipCount==0) || (skipCount>0 && mod(counter - 1, skipCount+1)==0)
        
        % Create the attack message
        attackMsg = createAttackMessage(victimMsg, idVictim);
        
        if isempty(attackMsg)
            disp('Attack Skipped');
            continue;
        else
            disp('Attack Running...');
            % Transmit attack message
            transmit(attacker, attackMsg);

            % Print the victim timestamp
            attackerTimestamp = datestr(now, 'HH:MM:SS.FFF');
            disp(['Attack Timestamp: ' attackerTimestamp ]);

            [tecA, tecV] = incrementTEC(tecA, tecV);

            % Simulate recovery during skipped or attack cycles
            [tecA, tecV] = recoverTEC(tecA, tecV, victim, victimMsg, attacker, attackRatio);

            % Display current TEC values
            disp(['TEC - Attacker: ' num2str(tecA) ', Victim: ' num2str(tecV)]);

            % Increment cycle counter
            counter = counter + 1;

            attackCounter = attackCounter +1;
            
        end   

    %% Skip cycle
    elseif(skipCount>0 && mod(counter - 1, skipCount+1) > 0)
        disp('Attack Skipped ...');
        
        % Victim sends the message successfully --> decrement tecV
        tecV = tecV-1;

        % Attacker then send random messages --> decrements tecA
        for i=1:attackRatio
            transmit(attacker, generateRandomMessage());
            tecA = tecA-1; % Attacker recovers normally
        end
        disp(['Skip, TEC - Attacker: ' num2str(tecA) , ...
            ' Victim: TEC ='  num2str(tecV)]);
        % Increment cycle counter
        counter = counter + 1;     
    end
   
end

 % Store the last TEC values after the while loop
 tecA_values = [tecA_values, tecA];
 tecV_values = [tecV_values, tecV];
 counter_values = [counter_values, counter - 1];

% Cleanup after attack
stop(attacker);
stop(victim);
clear attacker victim;

%% Display result

disp(['Number of effective attacks: ' num2str(attackCounter)]);

if tecV >= 255
    disp('Victim entered bus-off state. Attack successful! ;)');
else 
    disp('Attacker entered bus-off state. Attack failed! :(');
end

%% Plotting Results
figure;
plot(counter_values, tecA_values, '-r', 'LineWidth', 2); % Attacker TEC in red
hold on;
plot(counter_values, tecV_values, '-b', 'LineWidth', 2); % Victim TEC in blue
xlabel('Cycle Number');
ylabel('TEC Value');
title('TEC Evolution Over Cycles');
legend({sprintf('Attacker TEC (tecA), Attack Ratio = %d', attackRatio), ...
        'Victim TEC (tecV)'}, ...
       'Location', 'best');
grid on;
