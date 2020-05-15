--both analysis were made based on 1/4 intervals

--check in a general way if the value is bigger than Lhard can possibly be
-- or smaller than Hhard can possibly be
function AnalysisC(d,Hhard,Lhard,value)
 if Lhard>Hhard then
  print("Hhard must be bigger than Lhard")
 end
 --print("analysis")

 local Havg=(Hhard+Lhard)/2
--"Havg" stands for hardness average,
--it's where the two hardness meet,
--we can control how much overlapping
-- is allowed based on this number

 local meet=(Hhard-Lhard)*2
--how many 4 intervals they have
--until they overlap
 if meet>14 or d<=meet then
--if the number of 4 intervals is bigger than 14,
--therefore even at most distant possible(56) they dont overlap
-- or distance is smaller than the minimal distance for overlapping
  if value>=Havg then
   return true
  else return false end
 end
--if bigger than Lhard can possibly be assing true
--or smaller than Hhard can possibly be assing false
 for i=meet+1,14 do
  if d<=i*4 then
   if(Havg+i/4)<=value then
    return true
   elseif(Havg-i/4)>=value then
    return false
   end
  end
 end
--this function may end with a nill result
end

--check with a 5% chance of being wrong if the average is of the value of interest
--based on normal curve, change Zvalue according to your liking of error
function AnalysisA(d,Vavg,nScan,Hhard)
Zvalue=1.64

--the signal is "-" because I only care if its smaller than a minimum
 if (-Zvalue*d*0.035/math.sqrt(nScan)+Hhard)<Vavg then
  return true
  else return false
 end
 --print("analysis analitical end")
end

function scan(x,y,i)
 local component=require("component")
 local geo=component.geolyzer
 dataT={}
 result={}
--collect the data and store in table
 for c=1,i do
  dataT[c]=geo.scan(x,y)
 end
--do the tests as needed, returning a table with true or false or zero for z axis
 for z=1,64 do
  avg=0
  distance=math.sqrt(x^2+y^2+z^2)
  for c=1,i do
   if dataT[c][z]==0 then
    result[z]=0
    break
   end
   avg=dataT[c][z]/i+avg
   if AnalysisC(distance,3,1.5,dataT[c][z]) then
    result[z]=true
   end
  end
  if result[z]==nill then
   result[z]=AnalysisA(distance,avg,i,3)
  end
 end
 return result
end

--concatenate all the z-axis values, it will return a single giant string(number, but treat it as string)
function writeV(value)
 result=""
 for z=1,64 do
  if value[z]~=0 then
   if value[z] then
    value[z]=1
   else
    value[z]=2
   end
  end
  result=result..value[z]
 -- print(result)
 end
 return result
end

--given that the order of loops are x than y than z,
--the position into the string is fixed, given by the "place" formula
--if you change the order you must change the formula for an equivalent one
function readV(lim,x,y,z, value)
 x=lim+x
 y=lim+y
 z=z-1
 place=x*lim*64+y*64+z
 counter=0
 save=0
 for digit in string.gmatch(value, "%d") do
  if counter==place then
   save=digit
   break
  end
  counter=counter+1
 end
 return save
end

--actually do something
local computer=require("computer")
local time=computer.uptime()
local area=16 --will do -x to x and -y to y with this number
local numberOfTests=6
--really depends on how confident you want to be and how much time to spend, 55s*numberOfTests for time spent
local str="" --where we store position
local value={}
local fileName="result.txt" --name of the file with the string saved in the HD
local io=require("io")
local f=io.open(fileName,"w")
for x=-area,area do
 for y=-area,area do
  value=scan(x,y,numberOfTests)
  str=str..writeV(value)
 end
end
f:write(str)
f:close()
