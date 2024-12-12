% Function to handle TEC recovery and adjustments
function [tecA, tecV] = recoverTEC(tecA, tecV, victim, victimMsg, attacker, attackRatio)
    % Perform recovery actions only if the victim or the attacker has not entered bus off
    % state
    if(tecV>255 || tecA>255)
        return;
    end
    % Now the victim retransmit the message successfully --> decrement tecV
    transmit(victim, victimMsg);
        if(tecV-1)<=0
            tecV = 0;
        else    
            tecV = tecV - 1;
        end
    % Attacker sends additional messages and recovers
    for i = 1 : attackRatio
        transmit(attacker, generateRandomMessage());
        if(tecA-1)<=0
            tecA = 0;
        else    
            tecA = tecA - 1;
        end
    end

   
end
