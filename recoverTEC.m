% Function to handle TEC recovery and adjustments
function [tecA, tecV] = recoverTEC(tecA, tecV, victim, victimMsg, attacker, attackRatio)
    % Perform recovery actions only if the victim or the attacker has not entered bus off
    % state
    if(tecV>255 || tecA>255)
        return;
    end
    % Now the victim retransmit the message successfully --> decrement tecV
    transmit(victim, victimMsg);
    tecV = tecV - 1; 
    
   
    % Attacker sends additional messages and recovers
    for i = 1 : attackRatio
        transmit(attacker, generateRandomMessage());
        tecA = tecA - 1;
    end

   
end
