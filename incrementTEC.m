function [tecA, tecV] = incrementTEC(tecA, tecV)            
    % Simulate TEC increment due to error
    tecA = tecA + 8; % Attacker increments +8

    % If the attacker is in error passive, error messages are recessive.
    % Hence the victim doesn't increment its TEC
    if(tecA < 127)
        tecV = tecV + 8; % Victim increments +8
    end 