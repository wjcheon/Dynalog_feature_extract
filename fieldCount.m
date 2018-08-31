function [N1, N2] = fieldCount(inputStruct)
N1 = 0;
N2 = 0;
for i = 1: numel(inputStruct)
  if(~isempty(getfield(inputStruct(i),'f1')))
      N1 = N1 + 1;
  end
  if(~isempty(getfield(inputStruct(i),'f2'))) 
      N2 = N2 + 1;
  end
end