% Function to handle TEC recovery and adjustments
function [tecA, tecV] = recoverTEC(tecA, tecV, victim, victimMsg, attacker, attackRatio)
    
    % Now the victim retransmit the message successfully --> decrement tecV
    transmit(victim, victimMsg);
    tecV = tecV - 1; 

    % Attacker sends additional messages and recovers
    for i = 1 : attackRatio
        transmit(attacker, generateRandomMessage());
        tecA = tecA - 1;
    end

   
end