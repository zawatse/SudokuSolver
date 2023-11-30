function result = validateSolution(puzzle)
    result = false;
    [R,C] = size(puzzle);
    % Rule 1: Each row must contain each number once
    for i = 1:R
        for j = 1:9
            if(length(find(puzzle(i,:) == j)) ~= 1)
                return;
            end
        end
    end
    %Rule 2: Each column must contain each number once
    for i = 1:C
        for j = 1:9
            if(length(find(puzzle(:,i) == j)) ~= 1)
                return;
            end
        end
    end
    %Rule 3: Each square must contain each number once
    for x = 0:2
        for y = 0:2
            for j = 1:9
                if(length(find(puzzle((3*x+1):(3*x+3),(3*y+1):(3*y+3)) == j)) ~= 1)
                    return;
                end
            end
        end
    end
    result = true;
end

